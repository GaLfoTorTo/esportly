import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/enum/enums.dart';
import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/data/services/timer_service.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_schedule_provider.dart';

//ESTADO - GAME STOPWATCH
class GameStopwatchState {
  final String currentTime;
  final int minutesElapsed;
  final int remainingElapsed;
  final bool isGameRunning;

  const GameStopwatchState({
    this.currentTime = '00:00',
    this.minutesElapsed = 0,
    this.remainingElapsed = 0,
    this.isGameRunning = false,
  });

  GameStopwatchState copyWith({
    String? currentTime,
    int? minutesElapsed,
    int? remainingElapsed,
    bool? isGameRunning,
  }) => GameStopwatchState(
    currentTime: currentTime ?? this.currentTime,
    minutesElapsed: minutesElapsed ?? this.minutesElapsed,
    remainingElapsed: remainingElapsed ?? this.remainingElapsed,
    isGameRunning: isGameRunning ?? this.isGameRunning,
  );
}

//NOTIFICADOR - GAME STOPWATCH
class GameStopwatchNotifier extends Notifier<GameStopwatchState> {
  late final TimerService _timerService;
  StreamSubscription<dynamic>? _clockSub;
  StreamSubscription<dynamic>? _elapsedSub;

  @override
  GameStopwatchState build() {
    _timerService = sl<TimerService>();
    ref.onDispose(_cleanup);
    return const GameStopwatchState();
  }

  //FUNÇÃO DE INICIALIZAÇÃO DE PARTIDA
  void startGame() {
    final session = ref.read(gameSessionProvider);
    final game = session.currentGame;
    if (game == null) return;

    final updatedGame = game.status != GameStatus.InProgress
        ? game.copyWith(status: GameStatus.InProgress, startTime: DateTime.now())
        : game;

    _timerService.startStopwatch(game.id!, Duration(minutes: game.duration ?? 10));

    ref.read(gameSessionProvider.notifier).setGame(updatedGame);
    ref.read(gameScheduleProvider.notifier).moveToInProgress(updatedGame);

    state = state.copyWith(isGameRunning: true);
    _setupTimeListener(game.id!);
  }

  //FUNÇÃO DE PAUSA DA PARTIDA
  void pauseGame() {
    final game = ref.read(gameSessionProvider).currentGame;
    if (game == null) return;
    _timerService.pauseStopwatch(game.id!);
    state = state.copyWith(isGameRunning: false);
  }

  //FUNÇÃO DE ENCERRAMENTO DA PARITDA
  void stopGame() {
    final session = ref.read(gameSessionProvider);
    final game = session.currentGame;
    if (game == null) return;

    _timerService.stopStopwatch(game.id!);
    _cleanup();

    final finished = game.copyWith(status: GameStatus.Completed, endTime: DateTime.now());
    ref.read(gameSessionProvider.notifier).setGame(finished);
    ref.read(gameScheduleProvider.notifier).removeFromInProgress(game);
    ref.read(gameScheduleProvider.notifier).addGameHistoric(finished);

    state = state.copyWith(isGameRunning: false);
  }

  //FUNÇÃO DE REINICIO DA PARITDA
  void resetGame() {
    final session = ref.read(gameSessionProvider);
    final game = session.currentGame;
    if (game == null) return;

    _timerService.resetStopwatch(game.id!);
    _cleanup();

    final reset = game.copyWith(status: GameStatus.Scheduled);
    ref.read(gameSessionProvider.notifier).setGame(reset);
    ref.read(gameScheduleProvider.notifier).backToNext(reset);

    state = state.copyWith(isGameRunning: false);
  }

  //FUNÇÃO DE DEFINIÇÃO DE LISTENER DE TEMPORIZADOR
  void _setupTimeListener(int gameId) {
    _clockSub?.cancel();
    _elapsedSub?.cancel();
    _clockSub = _timerService.clockStream(gameId).listen((clock) {
      state = state.copyWith(currentTime: clock);
    });
    _elapsedSub = _timerService.elapsedStream(gameId).listen((elapsed) {
      state = state.copyWith(minutesElapsed: elapsed);
    });
  }

  //FUNÇÃO DE LIMPEZA DE TEMPORIZADOR
  void _cleanup() {
    _clockSub?.cancel();
    _elapsedSub?.cancel();
    _clockSub = null;
    _elapsedSub = null;
  }
}

//PROVIDER - GAME STOPWATCH
final gameStopwatchProvider = NotifierProvider<GameStopwatchNotifier, GameStopwatchState>(GameStopwatchNotifier.new);
