import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_schedule_provider.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/presentation/widget/images/img_circle_widget.dart';
import 'package:intl/intl.dart';

class BottomSheetEventGames extends ConsumerWidget {
  const BottomSheetEventGames({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventSessionProvider.select((s) => s.event));
    final nextGames = ref.watch(gameScheduleProvider.select((s) => s.nextGames));

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).dialogTheme.backgroundColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const BackButton(),
              Padding(
                padding: const EdgeInsets.only(left: 60),
                child: Text(
                  'Iniciar uma Partida',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Escolha a partida que vc deseja iniciar agora',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.grey_500),
              textAlign: TextAlign.center,
            ),
          ),
          const Divider(color: AppColors.grey_300),
          Expanded(
            child: ListView(
              children: nextGames.map((game) {
                var gameTime = "${DateFormat.Hm().format(game!.startTime!)} - ${DateFormat.Hm().format(game.endTime!)}";
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(gameSessionProvider.notifier).setGame(game);
                      final router = GoRouter.of(context);
                      Navigator.of(context).pop();
                      router.push('/games/overview');
                    },
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: ImgCircularWidget(
                                size: 70,
                                image: event?.photo,
                                element: "event",
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Partida #${game.number}",
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(overflow: TextOverflow.ellipsis),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                  child: Row(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(right: 5),
                                        child: Icon(AppIcones.marker_solid, size: 20, color: AppColors.grey_300),
                                      ),
                                      Text(
                                        "${event?.address?.state}",
                                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                          color: AppColors.grey_500,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Icon(AppIcones.clock_solid, size: 15, color: AppColors.grey_300),
                                    ),
                                    Text(
                                      "Hoje: $gameTime",
                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                        color: AppColors.grey_500,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
