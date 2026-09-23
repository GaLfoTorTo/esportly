import 'package:esportly/core/helpers/app_helper.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/core/providers/event/event_news_provider.dart';
import 'package:esportly/core/providers/event/event_overview_provider.dart';
import 'package:esportly/core/providers/event/event_participants_provider.dart';
import 'package:esportly/core/providers/event/event_rank_provider.dart';
import 'package:esportly/core/providers/event/event_rules_provider.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/data/repositories/event_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:go_router/go_router.dart';

//ESTADO - SESSÃO DO EVENTO
class EventSessionState {
  final bool ready;
  final bool error;
  final bool loading;
  final UserModel? user;
  final EventModel? event;
  final List<EventModel> events;
  final bool participant;
  final String privacy;
  //ESTILO - derivado da modalidade e imagem do evento
  final Color modalityColor;
  final Color modalityTextColor;
  final ImageProvider? modalityImage;
  final bool heroBrightness;
  final Color heroTextColor;

  const EventSessionState({
    this.ready = false,
    this.error = false,
    this.loading = false,
    this.user,
    this.event,
    this.events = const [],
    this.participant = false,
    this.privacy = 'Public',
    this.modalityColor = AppColors.green_300,
    this.modalityTextColor = AppColors.blue_500,
    this.modalityImage,
    this.heroBrightness = false,
    this.heroTextColor = AppColors.white,
  });

  EventSessionState copyWith({
    bool? ready,
    bool? error,
    bool? loading,
    UserModel? user,
    EventModel? event,
    List<EventModel>? events,
    bool? participant,
    String? privacy,
    Color? modalityColor,
    Color? modalityTextColor,
    ImageProvider? modalityImage,
    bool? heroBrightness,
    Color? heroTextColor,
  }) => EventSessionState(
    ready: ready ?? this.ready,
    error: error ?? this.error,
    loading: loading ?? this.loading,
    user: user ?? this.user,
    event: event ?? this.event,
    events: events ?? this.events,
    participant: participant ?? this.participant,
    privacy: privacy ?? this.privacy,
    modalityColor: modalityColor ?? this.modalityColor,
    modalityTextColor: modalityTextColor ?? this.modalityTextColor,
    modalityImage: modalityImage ?? this.modalityImage,
    heroBrightness: heroBrightness ?? this.heroBrightness,
    heroTextColor: heroTextColor ?? this.heroTextColor,
  );
}

//NOTIFICADOR - SESSÃO DO EVENTO
class EventSessionNotifier extends Notifier<EventSessionState> {
  EventRepository get _eventRepository => EventRepository();
  
  @override
  EventSessionState build() => const EventSessionState();

  //FUNÇÃO DE RESET COMPLETO — limpa estado próprio e invalida providers dependentes
  void dispose() {
    ref.invalidate(eventRankProvider);
    ref.invalidate(eventOverviewProvider);
    ref.invalidate(eventParticipantsProvider);
    state = const EventSessionState();
  }

  //FUNÇÃO DE INICIALIZAÇÃO DE PROVIDER DE ESCALÇÃO
  Future<void> init(List<EventModel>? events, UserModel user) async {
    //ENCERRAR PROVIDER NA MEMORIA
    dispose();
    try {
      state = state.copyWith(loading: true, user: user);
      //VERIFICAR SE USUARIO ESTA REGISTRADO EM ALGUM EVENTO
      if((events?.isEmpty ?? false)){
        state = state.copyWith(
          loading: false, 
          error: true
        );
        return;
      }
      state = state.copyWith(events: events!);
    } catch (e) {
      state = state.copyWith(error: true);
      final ctx = sl<GoRouter>().routerDelegate.navigatorKey.currentContext;
      if (ctx != null) AppHelper.feedbackMessage(ctx, AppHelper.extractErrorMessage(e));
    }
    state = state.copyWith(loading: false);
  }

  //FUNÇÃO DE SELEÇÃO DE EVENTO DE EVENTO
  Future<void> setEvent(EventModel event) async {
    state = state.copyWith(loading: true);
    try {
      final newEvent = await _eventRepository.getEvent(event.uuid!);
      final styleMap = ModalityHelper.getEventModalityColor(newEvent!.gameConfig?.category ?? newEvent.modality!.name);
      final img = ImgHelper.getEventImg(newEvent);
      final isDark = await AppHelper.isImageDark(img);
      state = state.copyWith(
        event: newEvent,
        participant: event.participants?.where((p) => p.id == state.user!.id).firstOrNull != null,
        privacy: event.privacy!.name,
        modalityColor: styleMap['color'],
        modalityTextColor: styleMap['textColor'],
        modalityImage: img,
        heroBrightness: isDark,
        heroTextColor: isDark ? AppColors.blue_500 : AppColors.white,
      );
      //INICIALIZAR PROVIDERS SECUNDARIOS DE EVENTO
      ref.read(eventOverviewProvider.notifier).init(event);
      ref.read(eventParticipantsProvider.notifier).init(event);
      ref.read(eventRankProvider.notifier).init(event);
      ref.read(eventRulesProvider.notifier).init(event);
      ref.read(eventNewsProvider.notifier).init(event);
      //INICIALIZAR PROVIDER DE PARTIDAS
      if(state.participant) ref.read(gameSessionProvider.notifier).init(event);
    } catch (e) {
      state = state.copyWith(error: true);
      final ctx = sl<GoRouter>().routerDelegate.navigatorKey.currentContext;
      if (ctx != null) AppHelper.feedbackMessage(ctx, AppHelper.extractErrorMessage(e));
    }
    state = state.copyWith(loading: false);
  }
}

//PROVIDER - SESSÃO DO EVENTO
final eventSessionProvider = NotifierProvider<EventSessionNotifier, EventSessionState>(EventSessionNotifier.new);
