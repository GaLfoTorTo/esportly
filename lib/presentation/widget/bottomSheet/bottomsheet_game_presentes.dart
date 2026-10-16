import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/providers/game/game_day_provider.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/presentation/widget/cards/card_player_team_widget.dart';

class BottomSheetGamePresentes extends ConsumerWidget {
  const BottomSheetGamePresentes({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final participants = ref.watch(gameDayProvider.select((s) => s.participantsPresent));
    final modality = ref.watch(eventSessionProvider.select((s) => s.event?.modality?.name ?? ''));

    return SizedBox(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                const BackButton(),
                Padding(
                  padding: const EdgeInsets.only(left: 60),
                  child: Text(
                    'Jogadores Presentes',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.green_300.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 5,
                    children: [
                      const Icon(Icons.circle, size: 10, color: AppColors.green_300),
                      Text(
                        '${participants.length}',
                        style: const TextStyle(
                          color: AppColors.green_300,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
          if (participants.isEmpty)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  const Icon(
                    Icons.groups_rounded, 
                    size: 48, 
                    color: AppColors.grey_300
                  ),
                  Text(
                    'Nenhum participante presente',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.grey_500),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ListView(
                  children: participants.map((user) {
                    if (user.player != null) {
                      return CardPlayerTeamWidget(
                        user: user,
                        modality: modality,
                        onPressed: () {},
                      );
                    }
                    return const SizedBox.shrink();
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
