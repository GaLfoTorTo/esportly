import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/enum/enums.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/helpers/event_helper.dart';
import 'package:esportly/core/helpers/user_helper.dart';
import 'package:esportly/data/models/game_event_model.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
import 'package:esportly/core/providers/game/game_control_provider.dart';

class CardScoreWidget extends ConsumerWidget {
  const CardScoreWidget({super.key});

  Map<int, List<int>> _groupGoalsByPlayer(List<GameEventModel> events, gameSession) {
    final Map<int, List<int>> grouped = {};
    for (final e in events) {
      final user = EventHelper.getUserEvent(gameSession.event!, e.userId!);
      if (user == null) continue;
      grouped.putIfAbsent(user.id!, () => []);
      grouped[user.id]?.add(e.minute ?? 0);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dimensions = MediaQuery.of(context).size;

    final eventSession = ref.watch(eventSessionProvider);
    final gameSession  = ref.watch(gameSessionProvider);
    final currentGame  = gameSession.currentGame;
    final teamAScore   = ref.watch(gameMatchProvider.select((s) => s.teamAScore));
    final teamBScore   = ref.watch(gameMatchProvider.select((s) => s.teamBScore));
    final gameEvents   = ref.watch(gameMatchProvider.select((s) => s.gameEvents));
    final currentTime  = ref.watch(gameControlProvider.select((s) => s.currentTime));

    final modalityColor     = eventSession.modalityColor;
    final modalityTextColor = eventSession.modalityTextColor;
    final modalityImage     = eventSession.modalityImage;

    final extraMinutes = ref.watch(gameControlProvider.select((s) => s.extraMinutes));
    final parts        = currentTime.split(':');
    final minutes      = int.tryParse(parts[0]) ?? 0;
    final isExtraTime  = minutes > (currentGame?.duration ?? 0) + extraMinutes;

    return Container(
      width: dimensions.width,
      margin: const EdgeInsets.only(top: 20, left: 10, right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.dark_500
            : AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
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
        spacing: 10,
        children: [
          Text(
            eventSession.event?.title ?? '',
            style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(color: AppColors.grey_500),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: modalityColor,
              image: modalityImage != null
                  ? DecorationImage(
                      image: modalityImage,
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          modalityColor.withAlpha(200), BlendMode.srcATop),
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Time A
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        currentGame?.teams?.isNotEmpty == true
                            ? currentGame!.teams!.first.name ?? ''
                            : '',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: modalityTextColor),
                      ),
                      SvgPicture.asset(
                        AppIcones.emblemas[currentGame?.teams?.isNotEmpty == true
                                ? currentGame!.teams!.first.emblem
                                : null] ??
                            AppIcones.emblemas['emblema_1']!,
                        width: 100,
                        height: 100,
                        colorFilter:
                            ColorFilter.mode(modalityTextColor, BlendMode.srcIn),
                      ),
                      Text(
                        'Home',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: modalityTextColor),
                      ),
                    ],
                  ),
                ),

                // Placar central
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (currentGame?.status == GameStatus.InProgress)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.red_300,
                        ),
                        child: const Icon(Icons.sensors,
                            size: 15, color: AppColors.white),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          Text(
                            '$teamAScore',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .copyWith(
                                    color: modalityTextColor, fontSize: 60),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'X',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(color: modalityTextColor),
                            ),
                          ),
                          Text(
                            '$teamBScore',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .copyWith(
                                    color: modalityTextColor, fontSize: 60),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          decoration: const BoxDecoration(
                            color: AppColors.dark_300,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                          ),
                          child: Text(
                            currentTime,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'DS-DIGITAL',
                              color: isExtraTime
                                  ? AppColors.red_300
                                  : AppColors.green_300,
                            ),
                          ),
                        ),
                        if (isExtraTime)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text('Tempo Extra',
                                style:
                                    TextStyle(color: AppColors.red_300)),
                          ),
                      ],
                    ),
                  ],
                ),

                // Time B
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        (currentGame?.teams?.length ?? 0) >= 2
                            ? currentGame!.teams!.last.name ?? ''
                            : '',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(color: modalityTextColor),
                      ),
                      SvgPicture.asset(
                        AppIcones.emblemas[(currentGame?.teams?.length ?? 0) >= 2
                                ? currentGame!.teams!.last.emblem
                                : null] ??
                            AppIcones.emblemas['emblema_2']!,
                        width: 100,
                        height: 100,
                        colorFilter:
                            ColorFilter.mode(modalityTextColor, BlendMode.srcIn),
                      ),
                      Text(
                        'Away',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: modalityTextColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Artilheiros
          if (currentGame != null && (currentGame.teams?.length ?? 0) >= 2)
            Builder(builder: (_) {
              final hasTeams = (currentGame.teams?.length ?? 0) >= 2;
              final teamAEvents = hasTeams
                  ? gameEvents
                      .where((t) => t.teamId == currentGame.teams!.first.id)
                      .toList()
                  : <GameEventModel>[];
              final teamBEvents = hasTeams
                  ? gameEvents
                      .where((t) => t.teamId == currentGame.teams!.last.id)
                      .toList()
                  : <GameEventModel>[];

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(2, (i) {
                  final teamEvents = i == 0 ? teamAEvents : teamBEvents;
                  if (teamEvents.isEmpty) return const SizedBox.shrink();
                  final grouped = _groupGoalsByPlayer(
                    teamEvents
                        .where((e) => e.type?.name == 'Goal')
                        .toList(),
                    gameSession,
                  );
                  if (grouped.isEmpty) return const SizedBox.shrink();
                  return SizedBox(
                    width: dimensions.width * 0.37,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 5,
                      children: grouped.entries.map((entry) {
                        final goalMinutes = entry.value..sort();
                        final evt = teamEvents.firstWhere(
                          (e) =>
                              EventHelper.getUserEvent(
                                      gameSession.event!, e.userId!)
                                  ?.id ==
                              entry.key,
                        );
                        final user = EventHelper.getUserEvent(
                            gameSession.event!, evt.userId!)!;
                        return Row(
                          spacing: 5,
                          children: [
                            if (i == 0) ...[
                              const Icon(AppIcones.futebol_ball_solid,
                                  size: 12, color: AppColors.grey_500),
                              Text(UserHelper.getFullName(user),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(
                                          color: AppColors.grey_500)),
                              Flexible(
                                child: Text(
                                  goalMinutes.map((m) => "$m'").join(', '),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(color: AppColors.grey_500),
                                  softWrap: true,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                            if (i == 1) ...[
                              Flexible(
                                child: Text(
                                  goalMinutes.map((m) => "$m'").join(', '),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(color: AppColors.grey_500),
                                  softWrap: true,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Text(
                                '${user.firstName} ${user.lastName}',
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .copyWith(color: AppColors.grey_500),
                              ),
                              const Icon(AppIcones.futebol_ball_solid,
                                  size: 12, color: AppColors.grey_500),
                            ],
                          ],
                        );
                      }).toList(),
                    ),
                  );
                }),
              );
            }),
        ],
      ),
    );
  }
}
