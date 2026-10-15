import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/enum/enums.dart';
import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/data/services/timer_service.dart';
import 'package:esportly/data/services/game_notification_service.dart';
import 'package:esportly/core/helpers/game_action_helper.dart';
import 'package:esportly/core/providers/game/game_config_provider.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_schedule_provider.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
//ESTADO - GAME CONTROL
class GameControlState {
  final String currentTime;
  final int minutesElapsed;
  final int remainingElapsed;
  final bool isGameRunning;
  final int extraMinutes;
  final int currentPeriod;

  const GameControlState({
    this.currentTime = '00:00',
    this.minutesElapsed = 0,
    this.remainingElapsed = 0,
    this.isGameRunning = false,
    this.extraMinutes = 0,
    this.currentPeriod = 1,
  });

  GameControlState copyWith({
    String? currentTime,
    int? minutesElapsed,
    int? remainingElapsed,
    bool? isGameRunning,
    int? extraMinutes,
    int? currentPeriod,
  }) => GameControlState(
    currentTime: currentTime ?? this.currentTime,
    minutesElapsed: minutesElapsed ?? this.minutesElapsed,
    remainingElapsed: remainingElapsed ?? this.remainingElapsed,
    isGameRunning: isGameRunning ?? this.isGameRunning,
    extraMinutes: extraMinutes ?? this.extraMinutes,
    currentPeriod: currentPeriod ?? this.currentPeriod,
  );
}

//NOTIFICADOR - GAME CONTROL
class GameControlNotifier extends Notifier<GameControlState> {
  late final TimerService _timerService;
  late final GameNotificationService _notificationService;
  StreamSubscription<dynamic>? _clockSub;
  StreamSubscription<dynamic>? _elapsedSub;
  String _lastNotifTime = '';

  @override
  GameControlState build() {
    _timerService = sl<TimerService>();
    _notificationService = sl<GameNotificationService>();
    ref.onDispose(_cleanup);
    return const GameControlState();
  }

  //FUNÇÃO DE INICIALIZAÇÃO DE PARTIDA
  void startGame() {
    final gameSession = ref.read(gameSessionProvider);
    final game = gameSession.currentGame;
    if (game == null) return;

    final currentGame = game.copyWith(status: GameStatus.InProgress, startTime: DateTime.now());

    _timerService.startStopwatch(game.number!, Duration(minutes: game.duration ?? 10));
    ref.read(gameScheduleProvider.notifier).moveToInProgress(currentGame);

    state = state.copyWith(isGameRunning: true);
    _setupTimeListener(game.number!);
    _sendNotification(isRunning: true);
  }

  //FUNÇÃO DE ENCERRAMENTO DA PARTIDA
  void stopGame() {
    final gameSession = ref.read(gameSessionProvider);
    final game = gameSession.currentGame;
    if (game == null) return;

    _timerService.stopStopwatch(game.number!);
    _cleanup();

    final currentGame = game.copyWith(status: GameStatus.Completed, endTime: DateTime.now());
    ref.read(gameScheduleProvider.notifier).removeFromInProgress(game);
    ref.read(gameScheduleProvider.notifier).addGameHistoric(currentGame);

    state = state.copyWith(isGameRunning: false, currentPeriod: 1);
    _notificationService.cancelGameNotification();
  }

  //FUNÇÃO DE PAUSA DA PARTIDA
  void pauseGame() {
    final game = ref.read(gameSessionProvider).currentGame;
    if (game == null) return;
    _timerService.pauseStopwatch(game.number!);
    state = state.copyWith(isGameRunning: false);
    _sendNotification(isRunning: false);
  }

  //FUNÇÃO DE REINICIO DA PARTIDA
  void resetGame() {
    final gameSession = ref.read(gameSessionProvider);
    final game = gameSession.currentGame;
    if (game == null) return;

    _timerService.resetStopwatch(game.number!);
    _cleanup();

    state = state.copyWith(
      isGameRunning: false,
      extraMinutes: 0,
      currentPeriod: 1,
      currentTime: '00:00',
      minutesElapsed: 0,
    );
    _notificationService.cancelGameNotification();
  }

  //FUNÇÃO DE AVANÇO PARA O PRÓXIMO PERÍODO (TEMPO/QUARTO/SET)
  void nextPeriod() {
    final game = ref.read(gameSessionProvider).currentGame;
    if (game == null) return;

    final category = ref.read(gameConfigProvider).config?.category;
    final periodConfig = GameActionHelper.getPeriodConfig(category);
    if (state.currentPeriod >= periodConfig.total) return;

    _timerService.resetStopwatch(game.number!);
    _cleanup();

    final nextPeriodNum = state.currentPeriod + 1;
    state = state.copyWith(
      isGameRunning: false,
      currentPeriod: nextPeriodNum,
      extraMinutes: 0,
      currentTime: '00:00',
      minutesElapsed: 0,
    );
    _sendNotification(isRunning: false, periodOverride: nextPeriodNum);
  }

  //FUNÇÃO DE ADIÇÃO DE ACRÉSCIMOS
  void addExtraTime(int minutes) {
    state = state.copyWith(extraMinutes: state.extraMinutes + minutes);
  }

  //FUNÇÃO DE DEFINIÇÃO DE LISTENER DE TEMPORIZADOR
  void _setupTimeListener(int gameId) {
    _clockSub?.cancel();
    _elapsedSub?.cancel();
    _clockSub = _timerService.clockStream(gameId).listen((clock) {
      state = state.copyWith(currentTime: clock);
      _checkAutoEnd(clock);
      if (clock != _lastNotifTime) {
        _lastNotifTime = clock;
        _sendNotification(isRunning: true);
      }
    });
    _elapsedSub = _timerService.elapsedStream(gameId).listen((elapsed) {
      state = state.copyWith(minutesElapsed: elapsed);
    });
  }

  //FUNÇÃO DE ENCERRAMENTO AUTOMÁTICO AO ATINGIR DURAÇÃO DO PERÍODO
  void _checkAutoEnd(String clock) {
    if (!state.isGameRunning) return;

    final config = ref.read(gameConfigProvider).config;
    final game   = ref.read(gameSessionProvider).currentGame;
    final totalDurationMin = (config?.duration ?? game?.duration ?? 10) + state.extraMinutes;

    final parts      = clock.split(':');
    final elapsedMin = int.tryParse(parts[0]) ?? 0;
    final elapsedSec = int.tryParse(parts[1]) ?? 0;
    final elapsedTotal = elapsedMin * 60 + elapsedSec;

    if (elapsedTotal < totalDurationMin * 60) return;

    final periodConfig = GameActionHelper.getPeriodConfig(
      ref.read(gameConfigProvider).config?.category,
    );
    if (state.currentPeriod >= periodConfig.total) {
      stopGame();
    } else {
      nextPeriod();
    }
  }

  //FUNÇÃO AUXILIAR PARA DISPARAR NOTIFICAÇÃO (unificada)
  void _sendNotification({required bool isRunning, int? periodOverride}) {
    final matchState  = ref.read(gameMatchProvider);
    final config      = ref.read(gameConfigProvider).config;
    final game        = ref.read(gameSessionProvider).currentGame;
    final category    = config?.category;
    final periodConfig = GameActionHelper.getPeriodConfig(category);
    final period      = periodOverride ?? state.currentPeriod;
    final isLastPeriod = period >= periodConfig.total;

    final baseDuration = config?.duration ?? game?.duration ?? 10;
    final totalSec     = (baseDuration + state.extraMinutes) * 60;
    final parts        = state.currentTime.split(':');
    final elapsedMin   = int.tryParse(parts[0]) ?? 0;
    final elapsedSec   = int.tryParse(parts[1]) ?? 0;
    final elapsedTotal = elapsedMin * 60 + elapsedSec;
    final progressPct  = totalSec > 0
        ? ((elapsedTotal / totalSec) * 100).clamp(0, 100).round()
        : 0;

    _notificationService.showGameNotification(
      showControls: true,
      teamAName: matchState.teamA.name ?? 'Time A',
      teamBName: matchState.teamB.name ?? 'Time B',
      numero: game?.number ?? 0,
      isRunning: isRunning,
      time: state.currentTime,
      period: period,
      periodLabel: periodConfig.label,
      teamAScore: matchState.teamAScore,
      teamBScore: matchState.teamBScore,
      isLastPeriod: isLastPeriod,
      progress: progressPct,
    );
  }

  //FUNÇÃO DE LIMPEZA DE TEMPORIZADOR
  void _cleanup() {
    _clockSub?.cancel();
    _elapsedSub?.cancel();
    _clockSub = null;
    _elapsedSub = null;
    _lastNotifTime = '';
  }
}

//PROVIDER - GAME CONTROL
final gameControlProvider = NotifierProvider<GameControlNotifier, GameControlState>(GameControlNotifier.new);
