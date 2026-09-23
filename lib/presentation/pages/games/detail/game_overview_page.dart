import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/presentation/widget/skeletons/skeleton_game_overview_widget.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/core/helpers/event_helper.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:esportly/core/helpers/user_helper.dart';
import 'package:esportly/data/models/team_model.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
import 'package:esportly/core/providers/game/game_votes_provider.dart';
import 'package:esportly/presentation/widget/buttons/button_vote_widget.dart';
import 'package:esportly/presentation/widget/cards/card_player_game_widget.dart';

class GameOverviewPage extends ConsumerWidget {
  const GameOverviewPage({super.key});

  String _getOption(String key, double team1Value, double team2Value) {
    if (key == 'team1') return team1Value > team2Value ? "Win" : "Lose";
    if (key == 'team2') return team2Value > team1Value ? "Win" : "Lose";
    return "Draw";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dimensions = MediaQuery.of(context).size;
    final session = ref.watch(gameSessionProvider);
    final match = ref.watch(gameMatchProvider);
    final votes = ref.watch(gameVotesProvider);

    if (session.event == null || session.currentGame == null) {
      return const SkeletonGameOverviewWidget();
    }

    final event = session.event!;
    final modalityColor = ModalityHelper.getEventModalityColor(
      event.gameConfig?.category ?? event.modality!.name,
    )['color'] as Color;

    final teams = session.currentGame!.teams;
    if (teams == null || teams.length < 2) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            Icon(Icons.groups, size: 60, color: modalityColor),
            Text(
              "Equipes ainda não definidas",
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.grey_500),
            ),
            Text(
              "Configure as equipes para visualizar o resumo da partida.",
              style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.grey_500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final TeamModel teamA = teams.first;
    final TeamModel teamB = teams.last;
    final double team1Value = votes.votesGame['team1'] ?? 0.0;
    final double team2Value = votes.votesGame['team2'] ?? 0.0;

    final List<Map<String, dynamic>> infoGame = EventHelper.getDetailGame(event);

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: dimensions.width,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 15,
              children: [
                Text("Detalhes da Partida",
                    style: Theme.of(context).textTheme.titleSmall),
                Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    SizedBox(width: dimensions.width, height: 150),
                    Positioned(
                      bottom: -100,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateZ(pi / 2)
                          ..rotateY(0.9),
                        child: Container(
                          width: 200,
                          height: 350,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.white, width: 5),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.dark_300.withAlpha(50),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(5, 0),
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            ModalityHelper.getCategoryCourt(
                                event.gameConfig!.category),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: dimensions.width,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.spaceEvenly,
                    children: infoGame.map((item) {
                      return SizedBox(
                        width: dimensions.width * 0.4,
                        child: Column(
                          spacing: 10,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 10,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: modalityColor.withAlpha(50),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(item['icon'], size: 30, color: modalityColor),
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      child: Text(
                                        item['label'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(color: AppColors.grey_500),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Text(
                                      item['value'],
                                      style: Theme.of(context).textTheme.titleSmall,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (session.config?.config!["hasRefereer"] ?? false) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Row(
                      spacing: 10,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: CircleAvatar(
                            backgroundImage: ImgHelper.getUserImg(
                              EventHelper.getUserEvent(
                                event,
                                session.currentGame!.refereeId!,
                              )?.photo,
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 5,
                              children: [
                                Text(
                                  "Árbitro",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(color: AppColors.grey_500),
                                ),
                                Icon(Icons.sports, size: 20, color: modalityColor),
                              ],
                            ),
                            Text(
                              UserHelper.getFullName(
                                EventHelper.getUserEvent(
                                  event,
                                  session.currentGame!.refereeId!,
                                )!,
                              ),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Quem Vencerá a Partida ?",
                        style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      "Total de Votos: ${votes.votesGameCount}",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: votes.votesGame.entries.map((item) {
                    final String option =
                        _getOption(item.key, team1Value, team2Value);
                    final double value = item.value;
                    final String team = item.key == 'team1'
                        ? teamA.name!
                        : item.key == 'team2'
                            ? teamB.name!
                            : "Empate";
                    final String status = option == "Win"
                        ? "Vitória"
                        : option == "Lose"
                            ? "Derrota"
                            : "Empate";
                    final Color statusColor = option == "Win"
                        ? modalityColor
                        : option == "Lose"
                            ? AppColors.red_300
                            : AppColors.grey_300;
                    return Column(
                      spacing: 10,
                      children: [
                        Text(
                          team,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(color: statusColor),
                        ),
                        ButtonVoteWidget(
                          option: option,
                          value: value,
                          action: () {},
                        ),
                        Text(
                          "$status ${value.toStringAsFixed(0)}%",
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium!
                              .copyWith(color: statusColor),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Quem será o MVP ?",
                        style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      "Total de Votos: ${votes.votesMVPCount}",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: votes.votesMVP.entries.take(3).map((item) {
                      UserModel user =
                          teamA.players.firstWhere((u) => u.uuid == item.key);
                      int value = item.value;
                      return Column(
                        spacing: 10,
                        children: [
                          CardPlayerGameWidget(user: user),
                          Text(
                            "${value.toStringAsFixed(0)} votos",
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
