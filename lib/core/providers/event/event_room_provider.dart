import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/core/enum/enums.dart';
import 'package:esportly/core/helpers/app_helper.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/room_event_model.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/data/repositories/event_repository.dart';
import 'package:esportly/core/providers/stream_service_provider.dart';

//ESTADO - EVENT ROOM
class EventRoomState {
  final bool ready;
  final bool error;
  final bool loading;
  final bool room;
  final List<UserModel> participantsClone;
  final List<UserModel> participantsPresent;
  final ConnectionState connectionState;

  const EventRoomState({
    this.ready = false,
    this.error = false,
    this.loading = false,
    this.room = false,
    this.participantsClone = const [],
    this.participantsPresent = const [],
    this.connectionState = ConnectionState.disconnected,
  });

  EventRoomState copyWith({
    bool? ready,
    bool? error,
    bool? loading,
    bool? room,
    List<UserModel>? participantsClone,
    List<UserModel>? participantsPresent,
    ConnectionState? connectionState,
  }) => EventRoomState(
    ready: ready ?? this.ready,
    error: error ?? this.error,
    loading: loading ?? this.loading,
    room: room ?? this.room,
    participantsClone: participantsClone ?? this.participantsClone,
    participantsPresent: participantsPresent ?? this.participantsPresent,
    connectionState: connectionState ?? this.connectionState,
  );
}

//NOTIFICADOR - EVENT ROOM
class EventRoomNotifier extends Notifier<EventRoomState> {
  StreamSubscription<RoomEventModel>? _roomSub;
  String? _eventUuid;
  List<UserModel> _allParticipants = [];
  EventRepository get _eventRepository => EventRepository();

  @override
  EventRoomState build() => const EventRoomState();

  //FUNÇÃO DE INICIALIZAÇÃO — assina o stream de sala e armazena UUID do evento
  void init(EventModel event) {
    _roomSub?.cancel();
    _eventUuid = event.uuid;
    _allParticipants = event.participants ?? [];
    state = const EventRoomState(loading: true, connectionState: ConnectionState.connecting);
    try {
      final service = ref.read(streamServiceProvider);
      _roomSub = service.roomMessages.listen(_handleRoomEvent);
      state = state.copyWith(
        ready: true,
        loading: false,
        connectionState: ConnectionState.connected,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: true);
      final ctx = sl<GoRouter>().routerDelegate.navigatorKey.currentContext;
      if (ctx != null) AppHelper.feedbackMessage(ctx, AppHelper.extractErrorMessage(e));
    }
  }

  //FUNÇÃO DE RESET COMPLETO
  void dispose() {
    _roomSub?.cancel();
    _roomSub = null;
    _eventUuid = null;
    _allParticipants = [];
    state = const EventRoomState();
  }

  //FUNÇÃO DE ABERTURA DA SALA (ação do organizador) — emite ao backend; estado atualizado via WS
  Future<void> openRoom() async {
    if (_eventUuid == null) return;
    try {
      await _eventRepository.openRoom(_eventUuid!);
    } catch (e) {
      final ctx = sl<GoRouter>().routerDelegate.navigatorKey.currentContext;
      if (ctx != null) AppHelper.feedbackMessage(ctx, AppHelper.extractErrorMessage(e));
    }
  }

  //FUNÇÃO DE FECHAMENTO DA SALA (ação do organizador) — emite ao backend; estado atualizado via WS
  Future<void> closeRoom() async {
    if (_eventUuid == null) return;
    try {
      await _eventRepository.closeRoom(_eventUuid!);
    } catch (e) {
      final ctx = sl<GoRouter>().routerDelegate.navigatorKey.currentContext;
      if (ctx != null) AppHelper.feedbackMessage(ctx, AppHelper.extractErrorMessage(e));
    }
  }

  //FUNÇÃO DE ENTRADA DO USUARIO NA SALA — emite ao backend; presença atualizada via WS
  Future<void> enterRoom() async {
    if (_eventUuid == null) return;
    try {
      await _eventRepository.enterRoom(_eventUuid!);
    } catch (e) {
      final ctx = sl<GoRouter>().routerDelegate.navigatorKey.currentContext;
      if (ctx != null) AppHelper.feedbackMessage(ctx, AppHelper.extractErrorMessage(e));
    }
  }

  //FUNÇÃO DE SAIDA DO USUARIO DA SALA — emite ao backend; presença atualizada via WS
  Future<void> leaveRoom() async {
    if (_eventUuid == null) return;
    try {
      await _eventRepository.leaveRoom(_eventUuid!);
    } catch (e) {
      final ctx = sl<GoRouter>().routerDelegate.navigatorKey.currentContext;
      if (ctx != null) AppHelper.feedbackMessage(ctx, AppHelper.extractErrorMessage(e));
    }
  }

  //FUNÇÃO DE DEFINIÇÃO MANUAL DE PARTICIPANTES PRESENTES
  void setParticipantsPresent(List<UserModel> list) {
    state = state.copyWith(participantsPresent: list);
  }

  //FUNÇÃO DE REORDENAÇÃO DE PARTICIPANTES PRESENTES
  void reorderParticipants(int oldIndex, int newIndex) {
    final list = [...state.participantsPresent];
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final item = list.removeAt(oldIndex);
    list.insert(adjusted, item);
    state = state.copyWith(participantsPresent: list);
  }

  //FUNÇÃO DE MANIPULAÇÃO DE EVENTOS DE SALA RECEBIDOS VIA WEBSOCKET
  void _handleRoomEvent(RoomEventModel roomEvent) {
    switch (roomEvent.type) {
      case RoomEventType.open:
        final openUpdated = _allParticipants
            .where((u) => u.id != null && roomEvent.participants.contains(u.id))
            .toList();
        state = state.copyWith(
          room: true,
          participantsPresent: openUpdated,
          participantsClone: [...openUpdated],
        );
      case RoomEventType.close:
        state = state.copyWith(room: false);

      case RoomEventType.join:
      case RoomEventType.exit:
        if (roomEvent.participants.isEmpty) break;
        final updated = _allParticipants
            .where((u) => u.id != null && roomEvent.participants.contains(u.id))
            .toList();
        state = state.copyWith(
          participantsPresent: updated,
          participantsClone: [...updated],
        );
    }
  }
}

//PROVIDER - EVENT ROOM
final eventRoomProvider = NotifierProvider<EventRoomNotifier, EventRoomState>(EventRoomNotifier.new);
