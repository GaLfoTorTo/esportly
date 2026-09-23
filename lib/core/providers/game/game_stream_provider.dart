import 'dart:async';
import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/core/helpers/app_helper.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/enum/enums.dart';
import 'package:esportly/data/models/snapshot_model.dart';
import 'package:esportly/data/services/game_stream_service.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
import 'package:go_router/go_router.dart';

//ESTADO - GAME STREAM
class GameStreamState {
  final bool ready;
  final bool error;
  final bool loading;
  final EventModel? event;
  final ConnectionState streamState;
  
  const GameStreamState({
    this.ready = false,
    this.error = false,
    this.loading = false,
    this.event,
    this.streamState = ConnectionState.disconnected
  });

  GameStreamState copyWith({
    bool? ready,
    bool? error,
    bool? loading,
    EventModel? event,
    ConnectionState? streamState
  }) => GameStreamState(
    ready: ready ?? this.ready,
    error: error ?? this.error,
    loading: loading ?? this.loading,
    event: event ?? this.event,
    streamState: streamState ?? this.streamState
  );
}

//NOTIFICADOR - GAME STREAM
class GameStreamNotifier extends Notifier<GameStreamState> {
  final GameStreamService _streamService = GameStreamService();
  StreamSubscription<SnapshotModel>? _streamSub;

  @override
  GameStreamState build() => const GameStreamState();

  //FUNÇÃO INICIALIZAÇÃO
  void init(EventModel event) {
    //ENCERRAR PROVIDER NA MEMORIA
    //dispose();
    try {
      state = state.copyWith(loading: true);
      state = state.copyWith(
        event: event,
      );
      _streamService.init();
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
    ref.invalidate(gameStreamProvider);
    state = const GameStreamState();
  }

  //FUNÇÃO DE CONEXÃO NO CANAL DO EVENTO
  Future<void> connectChannel({required String uuid}) async{
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
  Future<void> disconnectChannel() async{
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

  //FUNÇÃO DE MANIPULAÇÃO DE STREAM
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

//PROVIDER - GAME STREAM
final gameStreamProvider = NotifierProvider<GameStreamNotifier, GameStreamState>(GameStreamNotifier.new);
