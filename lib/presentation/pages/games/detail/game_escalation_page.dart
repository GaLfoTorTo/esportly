import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/core/providers/game/game_control_provider.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_room_provider.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/helpers/user_helper.dart';
import 'package:esportly/core/providers/game/game_config_provider.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
import 'package:esportly/presentation/widget/images/img_circle_widget.dart';
import 'package:esportly/presentation/widget/others/lineup_widget.dart';
import 'package:esportly/presentation/widget/others/players_lineup_widget.dart';
import 'package:go_router/go_router.dart';

class GameEscalationPage extends ConsumerWidget {
  const GameEscalationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dimensions = MediaQuery.of(context).size;
    final eventSession = ref.watch(eventSessionProvider);
    final gameSession = ref.watch(gameSessionProvider);
    final gameConfig = ref.watch(gameConfigProvider);
    final gameControl = ref.watch(gameControlProvider);
    final matchSession = ref.watch(gameMatchProvider);
    final liveSession = ref.watch(gameRoomProvider);

    final teamA = matchSession.teamA;
    final teamB = matchSession.teamB;

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 20),
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
          spacing: 10,
          children: [
            if(gameSession.ready && !gameControl.isGameRunning)...[
              ButtonTextWidget(
                text: "Definir Equipes",
                icon: Icons.safety_divider_rounded,
                width: dimensions.width,
                backgroundColor: eventSession.modalityColor,
                height: 40,
                action: () => GoRouter.of(context).push('/games/teams'),
              ),
            ],
            if(!gameSession.ready)...[
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Text(
                        "As Informações dos elencos serão exibidas assim que as equipes forem definidas pelos organizadores e colaboradores!",
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const Icon(AppIcones.escalacao_outline, size: 50),
                    ],
                  ),
                ),
            ]else...[
              Stack(
                alignment: Alignment.center,
                children: [
                  LineupWidget(category: gameConfig.config!.category),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 400,
                        child: PlayersLineupWidget(
                          category: gameConfig.config!.category,
                          players: teamA.players,
                          command: "Home",
                          showPlayerName: true,
                        ),
                      ),
                      SizedBox(
                        height: 400,
                        child: PlayersLineupWidget(
                          category: gameConfig.config!.category,
                          players: teamB.players,
                          command: "Away",
                          showPlayerName: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: AppColors.grey_300),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(2, (i) {
                  final team = i == 0 ? teamA : teamB;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    width: dimensions.width * 0.4,
                    height: 45,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: i == 0 ? AppColors.blue_300 : AppColors.red_300,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        team.name ?? (i == 0 ? 'Time A' : 'Time B'),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: i == 0 ? AppColors.blue_300 : AppColors.red_300,
                            ),
                      ),
                    ),
                  );
                }),
              ),
              Row(
                spacing: 2,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (i) {
                  final teamLength = i == 0 ? matchSession.teamAlength : matchSession.teamBlength;
                  final players = i == 0 ? teamA.players : teamB.players;

                  return Expanded(
                    child: Column(
                      children: List.generate(players.length, (item) {
                        String name = "Jogador";
                        String userName = "jogador";
                        dynamic photo;
                        if (item < teamLength) {
                          final user = players[item];
                          name = UserHelper.getFullName(user);
                          userName = user.userName!;
                          photo = user.photo;
                        }
                        return Container(
                          width: dimensions.width * 0.45,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppColors.dark_300
                                : AppColors.white,
                            border: const Border(
                              bottom: BorderSide(width: 1, color: AppColors.grey_300),
                            ),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if (i == 0)
                                ImgCircularWidget(
                                  size: 40,
                                  borderColor: AppColors.blue_300,
                                  image: photo,
                                ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    crossAxisAlignment: i == 0
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        name,
                                        style: Theme.of(context).textTheme.titleSmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "@$userName",
                                        style: Theme.of(context)
                                            .textTheme
                                            .displayMedium!
                                            .copyWith(color: AppColors.grey_300),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (i == 1)
                                ImgCircularWidget(
                                  size: 40,
                                  borderColor: AppColors.red_300,
                                  image: photo,
                                ),
                            ],
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
