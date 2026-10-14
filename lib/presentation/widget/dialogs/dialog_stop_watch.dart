import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/helpers/loading_overlay.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/providers/game/game_config_provider.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_stopwatch_provider.dart';
import 'package:esportly/presentation/widget/overlays/stopwatch_overlay_widget.dart';

class StopWatchDialog extends ConsumerStatefulWidget {
  const StopWatchDialog({super.key});

  @override
  ConsumerState<StopWatchDialog> createState() => _StopWatchDialogState();
}

class _StopWatchDialogState extends ConsumerState<StopWatchDialog> {
  @override
  Widget build(BuildContext context) {
    final stopwatch = ref.watch(gameStopwatchProvider);
    final session = ref.read(gameSessionProvider);
    final gameConfig = ref.read(gameConfigProvider);

    void showOverlay(BuildContext ctx, VoidCallback function, String action) {
      Future.delayed(const Duration(milliseconds: 300), () async {
        if (ctx.mounted) {
          await LoadingOverlay.show(
            ctx,
            () async {
              await Future.delayed(const Duration(seconds: 5));
              function();
            },
            loadingWidget: Material(
              color: Colors.transparent,
              child: StopWatchOverlayWidget(
                seconds: 5,
                action: action,
              ),
            ),
            barrierColor: AppColors.dark_700.withAlpha(178),
          );
        }
      });
    }

    Future<bool> handleStopWatch(String action) async {
      switch (action) {
        case "pause":
          ref.read(gameStopwatchProvider.notifier).pauseGame();
          break;
        case "start":
          final rootCtx = Navigator.of(context, rootNavigator: true).context;
          Navigator.of(context).pop();
          showOverlay(rootCtx, ref.read(gameStopwatchProvider.notifier).startGame, action);
          break;
        case "stop":
          final rootCtxStop = Navigator.of(context, rootNavigator: true).context;
          Navigator.of(context).pop();
          showOverlay(rootCtxStop, ref.read(gameStopwatchProvider.notifier).stopGame, action);
          break;
        case "reset":
          final rootCtxReset = Navigator.of(context, rootNavigator: true).context;
          Navigator.of(context).pop();
          showOverlay(rootCtxReset, ref.read(gameStopwatchProvider.notifier).resetGame, action);
          break;
      }
      setState(() {});
      return true;
    }

    Duration getDuration() {
      final config = gameConfig.config;
      final game = session.currentGame;
      if (config?.duration != null) return Duration(minutes: config!.duration!);
      if (game?.duration != null) return Duration(minutes: game!.duration!);
      return const Duration(minutes: 10);
    }

    final duration = getDuration();
    final minutesDuration = duration.inMinutes.toString().padLeft(2, '0');
    final currentTime = stopwatch.currentTime;
    final isRunning = stopwatch.isGameRunning;
    final parts = currentTime.split(':');
    final minutes = int.tryParse(parts[0]) ?? 0;
    final seconds = int.tryParse(parts[1]) ?? 0;
    final totalElapsedSeconds = minutes * 60 + seconds;
    final totalDurationSeconds = duration.inSeconds;
    final progress = totalDurationSeconds > 0 ? totalElapsedSeconds / totalDurationSeconds : 0.0;

    return Dialog(
      backgroundColor: AppColors.green_300,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      alignment: Alignment.bottomCenter,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: AppColors.dark_300,
      child: SizedBox(
        height: 150,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.green_500.withAlpha(100),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => handleStopWatch("reset"),
                    icon: const Icon(Icons.restart_alt_rounded, color: AppColors.blue_500, size: 40),
                    tooltip: "Reiniciar",
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: IconButton(
                      onPressed: () async => handleStopWatch(isRunning ? "pause" : "start"),
                      alignment: Alignment.center,
                      icon: Icon(
                        isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: AppColors.blue_500,
                        size: 70,
                      ),
                      tooltip: isRunning ? "Pausar" : "Iniciar",
                    ),
                  ),
                  IconButton(
                    onPressed: () => handleStopWatch("stop"),
                    icon: const Icon(Icons.stop_rounded, color: AppColors.blue_500, size: 50),
                    tooltip: "Finalizar",
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentTime,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.blue_500),
                  ),
                  Text(
                    "$minutesDuration:00",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.blue_500),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.green_500,
                color: AppColors.blue_500,
                borderRadius: BorderRadius.circular(5),
                minHeight: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
