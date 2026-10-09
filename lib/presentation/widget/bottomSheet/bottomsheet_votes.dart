import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/presentation/widget/cards/card_player_present_widget.dart';
import 'package:flutter/material.dart';
import 'package:esportly/data/models/rule_model.dart';
import 'package:esportly/data/models/team_model.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_votes_provider.dart';
import 'package:esportly/presentation/widget/buttons/button_icon_widget.dart';

class BottomSheetVotes extends ConsumerWidget {
  final RuleModel? rule;
  const BottomSheetVotes({
    super.key,
    this.rule,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //RESGATAR DIMENSÕES DO DISPOSITIVO
    var dimensions = MediaQuery.of(context).size;
    final votesState    = ref.watch(gameVotesProvider);
    final votesNotifier = ref.read(gameVotesProvider.notifier);
    final gameSession = ref.watch(gameSessionProvider);
    final teams = gameSession.currentGame!.teams;

    final TeamModel teamA = teams!.first;
    final TeamModel teamB = teams.last;

    final List<Map<String, dynamic>> resultOpt = [
      {'label': teamA.name!, 'icon': Icons.shield,   'color': AppColors.green_300},
      {'label': 'Empate',    'icon': Icons.handshake,'color': AppColors.grey_300}, 
      {'label': teamB.name!, 'icon': Icons.shield,   'color': AppColors.red_300}
    ];

    final players = List.from([teamA.players, teamB.players]);

    return Container(
      height: dimensions.height,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).dialogTheme.backgroundColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))
      ),
      child: SingleChildScrollView(
        child: Column(
          spacing: 10,
          children: [
            Text(
              "Quem Vencerá a Partida ?",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: resultOpt.map((item){
                return Column(
                  spacing: 10,
                  children: [
                    ButtonIconWidget(
                      icon: item['icon'], 
                      iconSize: 80,
                      padding: 20,
                      iconColor: item['color'],
                      backgroundColor: item['color']!.withAlpha(votesState.selectedGame == item['label'] ? 50 : 10),
                      action: () => votesNotifier.setGameVote(item['label'])
                    ),
                    Text(
                      item['label'],
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: item['color']
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            const Divider(),
            Text(
              "Quem Será o MVP da Partida ?",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            ListView(
              children: players.map((item){
                UserModel user = item;
                return CardPlayerPresentWidget(
                  user: user,
                  modality: gameSession.event!.modality!.name,
                  present: true
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}