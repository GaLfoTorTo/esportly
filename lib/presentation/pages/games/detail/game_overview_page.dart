import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:esportly/data/models/team_model.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/core/providers/game/game_stream_provider.dart';
import 'package:esportly/core/helpers/event_helper.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:esportly/core/helpers/user_helper.dart';
import 'package:esportly/core/providers/game/game_config_provider.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_votes_provider.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/presentation/widget/bottomSheet/bottomsheet_votes.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';
import 'package:esportly/presentation/widget/charts/chart_pie_widget.dart';
import 'package:esportly/presentation/widget/cards/card_player_game_widget.dart';
import 'package:esportly/presentation/widget/skeletons/skeleton_game_overview_widget.dart';

class GameOverviewPage extends ConsumerWidget {
  const GameOverviewPage({super.key});

  //FUNÇÃO DE LEGENDA DE GRAFICOS
  Widget _legendItem(BuildContext context, Color color, String label) {
    return Row(
      spacing: 4,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dimensions = MediaQuery.of(context).size;
    final eventSession = ref.watch(eventSessionProvider);
    final gameSession = ref.watch(gameSessionProvider);
    final gameConfig = ref.watch(gameConfigProvider);
    final votesSession = ref.watch(gameVotesProvider);
    final liveSession = ref.watch(gameStreamProvider);

    //LOADING
    if (gameSession.event == null || gameSession.currentGame == null) {
      return const SkeletonGameOverviewWidget();
    }

    final event = gameSession.event!;
    final modalityColor = eventSession.modalityColor;
    final teams = gameSession.currentGame!.teams;

    final TeamModel teamA = teams!.first;
    final TeamModel teamB = teams.last;

    final double team1Value = votesSession.gamePercent('team1');
    final double team2Value = votesSession.gamePercent('team2');
    final double drawValue  = votesSession.gamePercent('draw');

    final List<Map<String, dynamic>> infoGame = EventHelper.getDetailGame(gameConfig.config ?? event.gameConfig!);

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
              spacing: 20,
              children: [
                if(gameSession.ready && !liveSession.live)...[
                  ButtonTextWidget(
                    text: "Iniciar Partida",
                    icon: Icons.play_arrow,
                    width: dimensions.width,
                    backgroundColor: modalityColor,
                    height: 40,
                    action: () => {},
                  ),
                ],
                Text(
                  "Detalhes da Partida",
                  style: Theme.of(context).textTheme.titleSmall
                ),
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
                            ModalityHelper.getCategoryCourt(event.gameConfig!.category),
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
                if (gameConfig.config?.config?["hasRefereer"] == true) ...[
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
                                gameSession.currentGame!.refereeId!,
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
                                  gameSession.currentGame!.refereeId!,
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
                    Text(
                      "Quem Vencerá a Partida ?",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      "${votesSession.votesGameCount} votos",
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      spacing: 4,
                      children: [
                        Text(
                          teamA.name!,
                          style: Theme.of(context).textTheme.labelMedium!.copyWith(
                            color: AppColors.green_300
                          ),
                        ),
                        Text(
                          "${team1Value.toStringAsFixed(0)}%",
                          style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: AppColors.green_300
                          ),
                        ),
                      ],
                    ),
                    ChartPieWidget(
                      team1Value: team1Value,
                      drawValue: drawValue,
                      team2Value: team2Value,
                      team1Color: AppColors.green_300,
                      team2Color: AppColors.red_300,
                    ),
                    Column(
                      spacing: 4,
                      children: [
                        Text(
                          teamB.name!,
                          style: Theme.of(context).textTheme.labelMedium!
                              .copyWith(color: AppColors.red_300),
                        ),
                        Text(
                          "${team2Value.toStringAsFixed(0)}%",
                          style: Theme.of(context).textTheme.titleSmall!
                              .copyWith(color: AppColors.red_300),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 16,
                  children: [
                    _legendItem(context, AppColors.grey_300, "Empate  ${drawValue.toStringAsFixed(0)}%"),
                  ],
                ),
                if(teamA.players.isNotEmpty && teamB.players.isNotEmpty)...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Quem será o MVP ?",
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(
                        "Total de Votos: ${votesSession.votesMVPCount}",
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: (votesSession.votesMVP.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value)))
                          .take(3).map((item) {
                        final allPlayers = [...teamA.players, ...teamB.players];
                        final user = allPlayers.firstWhere((u) => u.uuid == item.key);
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
                  if(gameSession.ready)...[
                    ButtonTextWidget(
                      backgroundColor: modalityColor,
                      text: "Votar",
                      icon: Icons.how_to_vote_rounded,
                      width: dimensions.width,
                      action: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
                        builder: (_) => const BottomSheetVotes(),
                      ),
                    ),
                  ]
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
