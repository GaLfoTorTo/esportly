import 'package:esportly/core/enum/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/data/models/game_model.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_control_provider.dart';

class TimerCounterWidget extends ConsumerWidget {
  final GameModel game;
  final Color? color;

  const TimerCounterWidget({
    super.key,
    required this.game,
    this.color = AppColors.grey_300
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentGame = ref.watch(gameSessionProvider.select((s) => s.currentGame));
    final minutesElapsed = ref.watch(gameControlProvider.select((s) => s.minutesElapsed));

    String timeElapsedText(int elapsed) {
      if (elapsed >= (currentGame?.duration ?? 0)) {
        return "Tempo Extra";
      } else if (DateTime.now().isBefore(game.startTime!)) {
        return "Aguardando Inicio";
      } else if (currentGame?.status == GameStatus.Completed || currentGame?.status == GameStatus.Cancelled) {
        return "Finalizado";
      } else {
        return "$elapsed'";
      }
    }

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha(100),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: color!,
          width: 2
        )
      ),
      child: Text(
        timeElapsedText(minutesElapsed),
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
          color: color,
        ),
      ),
    );
  }
}
