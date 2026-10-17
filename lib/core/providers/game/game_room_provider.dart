import 'dart:async';
import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/core/helpers/app_helper.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/enum/enums.dart';
import 'package:esportly/data/models/snapshot_model.dart';
import 'package:esportly/data/services/stream_service.dart';
import 'package:esportly/core/providers/stream_service_provider.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
import 'package:go_router/go_router.dart';

//ESTADO - GAME ROOM
class GameRoomState {
  final bool ready;
  final bool error;
  final bool loading;
  final bool live;
  final EventModel? event;
  final ConnectionState streamState;

  const GameRoomState({
    this.ready = false,
    this.error = false,
    this.loading = false,
    this.live = false,
    this.event,
    this.streamState = ConnectionState.disconnected
  });

  GameRoomState copyWith({
    bool? ready,
    bool? error,
    bool? loading,
    bool? live,
    EventModel? event,
    ConnectionState? streamState
  }) => GameRoomState(
    ready: ready ?? this.ready,
    error: error ?? this.error,
    loading: loading ?? this.loading,
    live: live ?? this.live,
    event: event ?? this.event,
    streamState: streamState ?? this.streamState
  );
}

//NOTIFICADOR - GAME ROOM
class GameRoomNotifier extends Notifier<GameRoomState> {
  StreamService get _streamService => ref.read(streamServiceProvider);
  StreamSubscription<SnapshotModel>? _streamSub;

  @override
  GameRoomState build() => const GameRoomState();

  //FUNÇÃO INICIALIZAÇÃO
  void init(EventModel event) {
    try {
      state = state.copyWith(loading: true, event: event);
      _streamService.init();
      if (event.uuid != null) connectChannel(uuid: event.uuid!);
    } catch (e) {
      state = state.copyWith(error: true);
      final ctx = sl<GoRouter>().routerDelegate.navigatorKey.currentContext;
      if (ctx != null) AppHelper.feedbackMessage(ctx, AppHelper.extractErrorMessage(e));
    }
    state = state.copyWith(loading: false);
  }

  //FUNÇÃO DE RESET COMPLETO
  void dispose() {
    ref.onDispose(disconnectChannel);
    ref.invalidate(gameMatchProvider);
    ref.invalidate(gameRoomProvider);
    state = const GameRoomState();
  }

  //FUNÇÃO DE CONEXÃO NO CANAL DO EVENTO
  Future<void> connectChannel({required String uuid}) async {
    try {
      _streamService.connect(uuid: uuid);
      _streamSub?.cancel();
      _streamSub = _streamService.messages.listen(handleStream);
      state = state.copyWith(streamState: ConnectionState.connected);
    } catch (e) {
      state = state.copyWith(error: true);
      final ctx = sl<GoRouter>().routerDelegate.navigatorKey.currentContext;
      if (ctx != null) AppHelper.feedbackMessage(ctx, AppHelper.extractErrorMessage(e));
    }
  }

  //FUNÇÃO PARA DESCONECTAR DO CANAL DO EVENTO
  Future<void> disconnectChannel() async {
    try {
      _streamSub?.cancel();
      _streamSub = null;
      _streamService.disconnect();
      state = state.copyWith(streamState: ConnectionState.disconnected);
    } catch (e) {
      state = state.copyWith(error: true);
      final ctx = sl<GoRouter>().routerDelegate.navigatorKey.currentContext;
      if (ctx != null) AppHelper.feedbackMessage(ctx, AppHelper.extractErrorMessage(e));
    }
  }

  //FUNÇÃO DE MANIPULAÇÃO DE STREAM — APENAS EVENTOS DE PARTIDA
  void handleStream(SnapshotModel message) {
    if (message.type == SnapshotType.unknown) return;
    final session = ref.read(gameSessionProvider);
    if (session.currentGame == null) return;
    if (message.gameId != session.currentGame!.id) return;
    if (message.type == SnapshotType.action) {
      ref.read(gameMatchProvider.notifier).applyStreamAction(message.payload);
    }
  }
}

//PROVIDER - GAME ROOM
final gameRoomProvider = NotifierProvider<GameRoomNotifier, GameRoomState>(GameRoomNotifier.new);
