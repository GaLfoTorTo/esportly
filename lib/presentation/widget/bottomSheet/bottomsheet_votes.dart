import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/presentation/widget/cards/card_player_present_widget.dart';
import 'package:flutter/material.dart';
import 'package:esportly/data/models/rule_model.dart';
import 'package:esportly/data/models/team_model.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
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
    final eventSession    = ref.watch(eventSessionProvider);
    final votesSession    = ref.watch(gameVotesProvider);
    final votesNotifier = ref.read(gameVotesProvider.notifier);
    final gameSession = ref.watch(gameSessionProvider);
    final matchSession = ref.watch(gameMatchProvider);

    final TeamModel teamA = matchSession.teamA;
    final TeamModel teamB = matchSession.teamB;

    final List<Map<String, dynamic>> resultOpt = [
      {'key': 'team1', 'label': teamA.name ?? 'Time A', 'icon': Icons.shield,   'color': AppColors.green_300},
      {'key': 'draw',  'label': 'Empate',               'icon': Icons.handshake,'color': AppColors.grey_300},
      {'key': 'team2', 'label': teamB.name ?? 'Time B', 'icon': Icons.shield,   'color': AppColors.red_300}
    ];

    final players = [...teamA.players, ...teamB.players];

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
                      backgroundColor: item['color']!.withAlpha(votesSession.selectedGame == item['key'] ? 180 : 10),
                      action: (){
                        votesNotifier.setGameVote(item['key']);
                        final voteSession = ref.read(gameVotesProvider);
                        if(voteSession.votedGame && voteSession.votedMVP){
                          Navigator.of(context).pop();
                        }
                      }
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
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: players.map((item){
                UserModel user = item;
                return InkWell(
                  onTap: (){
                    votesNotifier.setMVPVote(user.uuid!);
                    final voteSession = ref.read(gameVotesProvider);
                    if(voteSession.votedGame && voteSession.votedMVP){
                      Navigator.of(context).pop();
                    }
                  },
                  child: CardPlayerPresentWidget(
                    user: user,
                    modality: gameSession.event!.modality!.name,
                    present: true,
                    active: user.uuid == votesSession.selectedMVP,
                    color: eventSession.modalityColor.withAlpha(100)
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}