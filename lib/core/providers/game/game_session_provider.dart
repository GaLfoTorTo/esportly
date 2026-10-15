import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/core/helpers/app_helper.dart';
import 'package:esportly/core/providers/game/game_config_provider.dart';
import 'package:esportly/core/providers/game/game_day_provider.dart';
import 'package:esportly/core/providers/game/game_control_provider.dart';
import 'package:esportly/core/providers/game/game_stream_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/game_model.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
import 'package:esportly/core/providers/game/game_schedule_provider.dart';
import 'package:esportly/core/providers/game/game_votes_provider.dart';
import 'package:go_router/go_router.dart';

//ESTADO - GAME SESSION
class GameSessionState {
  final bool ready;
  final bool error;
  final bool loading;
  final EventModel? event;
  final GameModel? currentGame;

  const GameSessionState({
    this.ready = false,
    this.error = false,
    this.loading = false,
    this.event,
    this.currentGame,
  });

  GameSessionState copyWith({
    bool? ready,
    bool? error,
    bool? loading,
    EventModel? event,
    GameModel? currentGame,
  }) => GameSessionState(
    ready: ready ?? this.ready,
    error: error ?? this.error,
    loading: loading ?? this.loading,
    event: event ?? this.event,
    currentGame: currentGame ?? this.currentGame,
  );
}

//NOTIFICADOR - GAME SESSION
class GameSessionNotifier extends Notifier<GameSessionState> {
  @override
  GameSessionState build() => const GameSessionState();

  //FUNÇÃO INICIALIZAÇÃO
  void init(EventModel event) {
    try {
      state = state.copyWith(loading: true);
      state = state.copyWith(event: event);
      ref.read(gameConfigProvider.notifier).init(event.gameConfig);
      ref.read(gameScheduleProvider.notifier).init(event);
      ref.read(gameStreamProvider.notifier).init(event);
    } catch (e) {
      state = state.copyWith(error: true);
      final ctx = sl<GoRouter>().routerDelegate.navigatorKey.currentContext;
      if (ctx != null) AppHelper.feedbackMessage(ctx, AppHelper.extractErrorMessage(e));
    }
    state = state.copyWith(loading: false);
  }

  //FUNÇÃO DE RESET COMPLETO
  void dispose() {
    ref.invalidate(gameDayProvider);
    ref.invalidate(gameMatchProvider);
    ref.invalidate(gameScheduleProvider);
    ref.invalidate(gameVotesProvider);
    ref.invalidate(gameControlProvider);
    ref.invalidate(gameStreamProvider);
    ref.invalidate(gameConfigProvider);
    state = const GameSessionState();
  }

  //FUNÇÃO DE DEFINIÇÃO DE PARTIDA ATUAL
  void setGame(GameModel game, bool ready) {
    state = state.copyWith(ready: ready, currentGame: game);
    ref.read(gameMatchProvider.notifier).setTeamsFromGame(game);
    final teamPlayers = [
      ...?game.teams?.firstOrNull?.players,
      ...?game.teams?.lastOrNull?.players,
    ];
    final participantIds = teamPlayers.map((p) => p.uuid!).toList();
    ref.read(gameVotesProvider.notifier).init(participantIds);
  }

  //FUNÇÃO DE VERIFICAÇÃO DE PARTIDA OK
  bool checkGame(GameModel? game) {
    if (ref.read(gameConfigProvider).config != null) return false;
    if (game?.teams?.length == 2) {
      final a = game!.teams![0].players;
      final b = game.teams![1].players;
      return a.isNotEmpty && b.isNotEmpty && a.length == b.length;
    }
    return false;
  }
}

//PROVIDER - GAME SESSION
final gameSessionProvider = NotifierProvider<GameSessionNotifier, GameSessionState>(GameSessionNotifier.new);
