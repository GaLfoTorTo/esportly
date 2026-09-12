import 'package:esportly/data/repositories/event_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/data/models/event_model.dart';

//ESTADO - RANKING DO EVENTO
class EventRankState {
  final bool ready;
  final bool error;
  final bool loading;
  final EventModel? event;
  final String type;
  final List<UserModel>? participants;

  const EventRankState({
    this.ready = false,
    this.error = false,
    this.loading = false,
    this.event,
    this.type = 'Artilheiros',
    this.participants = const [],
  });

  EventRankState copyWith({
    bool? ready,
    bool? error,
    bool? loading,
    EventModel? event,
    String? type,
    List<UserModel>? participants,
  }) => EventRankState(
    ready: ready ?? this.ready,
    error: error ?? this.error,
    loading: loading ?? this.loading,
    event: event ?? this.event,
    type: type ?? this.type,
    participants: participants ?? this.participants,
  );
}

//NOTIFICADOR - RANKING DO EVENTO
class EventRankNotifier extends Notifier<EventRankState> {
  EventRepository get _eventRepository => EventRepository();

  @override
  EventRankState build() => const EventRankState();

  //FUNÇÃO DE INICIALIZAÇÃO
  void init(EventModel event){
    state = state.copyWith(event: event);
  }

  //FUNÇÃO DE DEFINIÇÃO DE RANKING
  Future<void> setRanking(String type) async{
    final participants = await _eventRepository.getRankEvent(state.event!.uuid!, state.type);
    state = state.copyWith(participants: participants);
  }
}

//PROVIDER - RANKING DO EVENTO
final eventRankProvider = NotifierProvider<EventRankNotifier, EventRankState>(EventRankNotifier.new);
