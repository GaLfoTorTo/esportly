import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/core/providers/game/game_config_provider.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
import 'package:esportly/presentation/widget/indicators/stats_game_widget.dart';

class GameStatisticsPage extends ConsumerWidget {
  const GameStatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dimensions = MediaQuery.of(context).size;
    final match = ref.watch(gameMatchProvider);
    final config = ref.watch(gameConfigProvider);

    final teamA = match.teamA;
    final teamB = match.teamB;
    final category = config.config?.category;
    final stats = ModalityHelper.getStatsConfig(category, match);

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.dark_500
              : AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.dark_500.withAlpha(30),
              spreadRadius: 0.5,
              blurRadius: 5,
              offset: const Offset(2, 5),
            ),
          ],
        ),
        child: Column(
          spacing: 15,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  width: dimensions.width * 0.4,
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.blue_300, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      teamA.name ?? 'Time A',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: AppColors.blue_300),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  width: dimensions.width * 0.4,
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.red_300, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      teamB.name ?? 'Time B',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: AppColors.red_300),
                    ),
                  ),
                ),
              ],
            ),
            ...stats.map(
              (stat) => StatsGameWidget(
                title: stat.title,
                teamAValue: stat.teamAValue,
                teamBValue: stat.teamBValue,
                isPercentage: stat.isPercentage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
