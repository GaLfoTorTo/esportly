import 'dart:math';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/presentation/widget/indicators/indicator_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/helpers/loading_overlay.dart';
import 'package:go_router/go_router.dart';
import 'package:esportly/core/helpers/user_helper.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/theme/app_icones.dart';
import 'package:esportly/core/helpers/app_helper.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
import 'package:esportly/core/providers/game/game_day_event_provider.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/presentation/widget/bars/header_widget.dart';
import 'package:esportly/presentation/widget/images/img_circle_widget.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';
import 'package:esportly/presentation/widget/buttons/float_button_widget.dart';
import 'package:esportly/presentation/widget/buttons/button_outline_widget.dart';
import 'package:esportly/presentation/widget/dialogs/dialog_alert_team.dart';
import 'package:esportly/presentation/widget/dialogs/dialog_random_team.dart';
import 'package:esportly/presentation/widget/bottomSheet/bottomsheet_game_players.dart';
import 'package:esportly/presentation/widget/cards/card_player_game_widget.dart';
import 'package:esportly/presentation/widget/cards/card_player_present_widget.dart';

class GameRandomTeamsPage extends ConsumerStatefulWidget {
  const GameRandomTeamsPage({super.key});

  @override
  ConsumerState<GameRandomTeamsPage> createState() => _GameRandomTeamsPageState();
}

class _GameRandomTeamsPageState extends ConsumerState<GameRandomTeamsPage> {
  late Color modalityColor;
  List<UserModel> participantsPresentClone = [];
  bool teamDefined = false;
  bool reorderList = false;
  late int qtdPlayers;
  late TextEditingController teamANameController;
  late TextEditingController teamBNameController;

  @override
  void initState() {
    super.initState();
    final session = ref.read(gameSessionProvider);
    final match = ref.read(gameMatchProvider);
    final event = session.event!;

    modalityColor = ModalityHelper.getEventModalityColor(
      event.gameConfig?.category ?? event.modality!.name,
    )['color'];
    qtdPlayers = session.config?.playersPerTeam ?? 0;

    teamANameController = TextEditingController(text: match.teamA.name ?? 'Time 1');
    teamBNameController = TextEditingController(text: match.teamB.name ?? 'Time 2');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final participantsPresent = ref.read(gameDayEventProvider).participantsPresent;
      if (participantsPresent.length < qtdPlayers * 2) {
        showDialog(context: context, builder: (_) => const DialogAlertTeam());
      } else {
        final m = ref.read(gameMatchProvider);
        if (m.teamA.players.isNotEmpty && m.teamB.players.isNotEmpty) {
          setState(() { teamDefined = true; });
        }
      }
    });
  }

  @override
  void dispose() {
    teamANameController.dispose();
    teamBNameController.dispose();
    super.dispose();
  }

  Future<void> assignPlayersToTeams(bool randomize) async {
    await Future.delayed(const Duration(seconds: 2));
    final present = ref.read(gameDayEventProvider).participantsPresent;
    var players = present.take(qtdPlayers * 2).toList();
    final remaining = present.skip(qtdPlayers * 2).toList();
    if (randomize) players = [...players]..shuffle(Random());
    ref.read(gameDayEventProvider.notifier).setParticipantsPresent(remaining);
    ref.read(gameMatchProvider.notifier).setTeamPlayers(0, players.take(qtdPlayers).toList());
    ref.read(gameMatchProvider.notifier).setTeamPlayers(1, players.skip(qtdPlayers).take(qtdPlayers).toList());
  }

  Future<void> resetTeams() async {
    await Future.delayed(const Duration(seconds: 2));
    final match = ref.read(gameMatchProvider);
    final current = ref.read(gameDayEventProvider).participantsPresent;
    final allPresent = [...current, ...match.teamA.players, ...match.teamB.players];
    ref.read(gameDayEventProvider.notifier).setParticipantsPresent(allPresent);
    ref.read(gameMatchProvider.notifier).setTeamPlayers(0, []);
    ref.read(gameMatchProvider.notifier).setTeamPlayers(1, []);
  }

  void setTeams() {
    final match = ref.read(gameMatchProvider);
    if (match.teamA.players.length == qtdPlayers && match.teamB.players.length == qtdPlayers) {
      ref.read(gameMatchProvider.notifier).setIsGameReady(true);
      context.pop();
    } else {
      AppHelper.feedbackMessage(context, "Os times não tem jogadores suficientes para continuar");
    }
  }

  void setOrderParticipants(String action) {
    switch (action) {
      case "accept":
        participantsPresentClone = [];
        break;
      case "cancel":
        ref.read(gameDayEventProvider.notifier).setParticipantsPresent(participantsPresentClone.toList());
        break;
      case "reset":
        ref.read(gameDayEventProvider.notifier).setParticipantsPresent(
          ref.read(gameDayEventProvider).participantsClone.toList(),
        );
        break;
    }
    participantsPresentClone = [];
    setState(() { reorderList = !reorderList; });
  }

  @override
  Widget build(BuildContext context) {
    var dimensions = MediaQuery.of(context).size;
    final match = ref.watch(gameMatchProvider);
    final dayEvent = ref.watch(gameDayEventProvider);
    final participantsPresent = dayEvent.participantsPresent;
    final session = ref.read(gameSessionProvider);
    final event = session.event!;
    final modality = event.modality?.name ?? '';

    return Scaffold(
      appBar: HeaderWidget(
        title: "Definição de Equipes",
        backgroundColor: modalityColor,
        leftAction: () => context.pop(),
        rightIcon: AppIcones.cog_solid,
        rightAction: () { context.push('/games/config'); },
        shadow: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: modalityColor,
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dark_500.withAlpha(50),
                      spreadRadius: 0.5, blurRadius: 5,
                      offset: const Offset(2, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        "Defina as equipes que irão disputar a partida. A escolha dos jogadores das equipes pode ser feita por sorteio, ordem de chegada ou manualmente.",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.blue_500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  spacing: 10,
                  children: [
                    Text("Elencos", style: Theme.of(context).textTheme.titleLarge),
                    Row(
                      spacing: 5,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: List.generate(2, (i) {
                        final teamPlayers = i == 0 ? match.teamA.players : match.teamB.players;
                        final teamLength = i == 0 ? match.teamAlength : match.teamBlength;
                        final teamName = i == 0 ? teamANameController.text : teamBNameController.text;

                        return Expanded(
                          child: Column(
                            spacing: 20,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: dimensions.width * 0.37,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        if (qtdPlayers == teamLength) ...[
                                          BoxShadow(
                                            color: modalityColor.withAlpha(70),
                                            spreadRadius: 5, blurRadius: 1,
                                            offset: const Offset(0, 0),
                                          ),
                                        ],
                                      ],
                                    ),
                                    child: ButtonTextWidget(
                                      width: dimensions.width,
                                      height: 30,
                                      backgroundColor: qtdPlayers == teamLength
                                          ? modalityColor
                                          : Theme.of(context).inputDecorationTheme.fillColor,
                                      textColor: qtdPlayers == teamLength
                                          ? AppColors.blue_500
                                          : Theme.of(context).textTheme.bodyLarge!.color,
                                      text: teamName,
                                      icon: AppIcones.users_solid,
                                      iconSize: 15,
                                      iconAfter: i == 0,
                                      action: () => showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
                                        builder: (_) => BottomSheetGamePlayers(team: i, qtdPlayers: qtdPlayers),
                                      ).then((_) => setState(() {})),
                                    ),
                                  ),
                                  if (qtdPlayers > teamPlayers.length) ...[
                                    Positioned(
                                      right: i == 0 ? 5 : null,
                                      left: i == 1 ? 5 : null,
                                      bottom: 0,
                                      child: Container(
                                        width: 25,
                                        height: 25,
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(25),
                                          color: AppColors.yellow_500,
                                        ),
                                        child: const Icon(AppIcones.exclamation_solid, color: AppColors.dark_700, size: 15),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Column(
                                spacing: 2,
                                children: List.generate(qtdPlayers, (item) {
                                  String name = "Jogador";
                                  String userName = "jogador";
                                  dynamic photo;
                                  if (item < teamLength) {
                                    final user = teamPlayers[item];
                                    name = UserHelper.getFullName(user);
                                    userName = user.userName!;
                                    photo = user.photo;
                                  }
                                  return Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? AppColors.dark_300
                                          : AppColors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        if (i == 0) ...[
                                          ImgCircularWidget(size: 40, borderColor: AppColors.blue_300, image: photo),
                                        ],
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 5),
                                            child: Column(
                                              crossAxisAlignment: i == 0 ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                                              children: [
                                                Text(name, style: Theme.of(context).textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                                Text(
                                                  "@$userName",
                                                  style: Theme.of(context).textTheme.displayMedium!.copyWith(color: AppColors.grey_300),
                                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (i == 1) ...[
                                          ImgCircularWidget(size: 40, borderColor: AppColors.red_300, image: photo),
                                        ],
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    if (teamDefined) ...[
                      ButtonTextWidget(
                        text: "Definir Equipes",
                        width: dimensions.width,
                        backgroundColor: modalityColor,
                        height: 30,
                        action: () => setTeams(),
                      ),
                      ButtonOutlineWidget(
                        text: "Resetar",
                        width: dimensions.width,
                        icon: Icons.restart_alt_rounded,
                        iconSize: 30,
                        action: () async {
                          await LoadingOverlay.show(
                            context,
                            () async {
                              setState(() { teamDefined = false; });
                              await resetTeams();
                            },
                            loadingWidget: const Center(child: IndicatorLoadingWidget()),
                            barrierColor: AppColors.dark_700.withAlpha(179),
                          );
                        },
                      ),
                    ],
                    const Divider(),
                    if (participantsPresent.isNotEmpty) ...[
                      Column(
                        spacing: 10,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Jogadores de proxima", style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.start),
                              if (!reorderList) ...[
                                ButtonTextWidget(
                                  text: "Reordenar",
                                  icon: Icons.reorder_rounded,
                                  width: 100, height: 20,
                                  textColor: modalityColor,
                                  backgroundColor: Colors.transparent,
                                  action: () {
                                    participantsPresentClone = participantsPresent.toList();
                                    setState(() { reorderList = !reorderList; });
                                  },
                                ),
                              ],
                            ],
                          ),
                          if (reorderList) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ButtonTextWidget(
                                  text: "Cancelar", icon: Icons.close,
                                  width: 100, height: 20,
                                  textColor: AppColors.red_300, backgroundColor: Colors.transparent,
                                  action: () => setOrderParticipants("cancel"),
                                ),
                                ButtonTextWidget(
                                  text: "Resetar", icon: Icons.restart_alt_rounded,
                                  width: 100, height: 20,
                                  textColor: AppColors.grey_300, backgroundColor: Colors.transparent,
                                  action: () => setOrderParticipants("reset"),
                                ),
                                ButtonTextWidget(
                                  text: "Definir", icon: Icons.check,
                                  width: 100, height: 20,
                                  textColor: AppColors.green_300, backgroundColor: Colors.transparent,
                                  action: () => setOrderParticipants("accept"),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 110.0 * (qtdPlayers * 2),
                              child: ReorderableListView(
                                physics: const NeverScrollableScrollPhysics(),
                                onReorder: (oldIndex, newIndex) =>
                                    ref.read(gameDayEventProvider.notifier).reorderParticipants(oldIndex, newIndex),
                                proxyDecorator: (child, index, animation) {
                                  return AnimatedBuilder(
                                    animation: animation,
                                    builder: (context, _) {
                                      final scale = Tween<double>(begin: 1, end: 1.03).animate(
                                        CurvedAnimation(parent: animation, curve: Curves.easeOut),
                                      );
                                      return Transform.scale(
                                        scale: scale.value,
                                        child: Material(
                                          elevation: 6,
                                          borderRadius: BorderRadius.circular(10),
                                          color: Theme.of(context).primaryColor.withAlpha(50),
                                          child: child,
                                        ),
                                      );
                                    },
                                  );
                                },
                                children: participantsPresent
                                    .where((p) => UserHelper.getParticipant(p.participants, event.id!)?.roles?.contains("Player") == true)
                                    .take(qtdPlayers * 2)
                                    .map((user) {
                                  return Row(
                                    key: ValueKey(user.id),
                                    spacing: 10,
                                    children: [
                                      const Icon(Icons.drag_indicator_rounded, color: AppColors.grey_300),
                                      Expanded(
                                        child: CardPlayerPresentWidget(
                                          user: user,
                                          modality: modality,
                                          present: participantsPresent.contains(user),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ] else ...[
                            Column(
                              spacing: 5,
                              children: participantsPresent
                                  .take(qtdPlayers * 2)
                                  .map((user) {
                                return CardPlayerPresentWidget(
                                  key: ValueKey(user.id),
                                  user: user,
                                  modality: modality,
                                  present: participantsPresent.contains(user),
                                );
                              }).toList(),
                            ),
                          ],
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Mais jogadores presentes", style: Theme.of(context).textTheme.titleLarge),
                              ButtonTextWidget(
                                text: "Ver Mais", icon: Icons.add_rounded,
                                width: 100, height: 20,
                                textColor: modalityColor, backgroundColor: Colors.transparent,
                                action: () {},
                              ),
                            ],
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: participantsPresent
                                  .skip(qtdPlayers * 2)
                                  .take(qtdPlayers)
                                  .map((user) {
                                return CardPlayerGameWidget(key: ValueKey(user.id), user: user);
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Builder(builder: (_) {
        if (!teamDefined && participantsPresent.length >= qtdPlayers * 2) {
          return FloatButtonWidget(
            floatKey: "escalation_game",
            icon: Icons.content_paste_go_rounded,
            backgroundColor: modalityColor,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => DialogRandomTeam(
                actionRandom: () async {
                  await assignPlayersToTeams(true);
                  setState(() { teamDefined = true; });
                },
                actionOrder: () async {
                  await assignPlayersToTeams(false);
                  setState(() { teamDefined = true; });
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }
}
