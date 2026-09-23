import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/core/helpers/user_helper.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:esportly/core/theme/app_size.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/data/models/game_model.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
import 'package:esportly/presentation/widget/bars/header_widget.dart';
import 'package:esportly/presentation/widget/inputs/input_text_widget.dart';
import 'package:esportly/presentation/widget/inputs/input_switch_widget.dart';
import 'package:esportly/presentation/widget/inputs/silder_players_widget.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';
import 'package:esportly/presentation/widget/buttons/button_outline_widget.dart';
import 'package:esportly/presentation/widget/buttons/button_dropdown_icon_widget.dart';

class GameConfigPage extends ConsumerStatefulWidget {
  final GameModel? game;
  const GameConfigPage({super.key, this.game});

  @override
  ConsumerState<GameConfigPage> createState() => _GameConfigPageState();
}

class _GameConfigPageState extends ConsumerState<GameConfigPage> {
  late TextEditingController numberController;
  late TextEditingController categoryController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  late TextEditingController durationController;
  late TextEditingController hasTwoHalvesController;
  late TextEditingController hasExtraTimeController;
  late TextEditingController hasPenaltyController;
  late TextEditingController hasGoalLimitController;
  late TextEditingController hasRefereerController;
  late TextEditingController playersPerTeamController;
  late TextEditingController extraTimeController;
  late TextEditingController goalLimitController;
  UserModel? refereer;
  bool hasRefereerSwitch = false;
  bool hasGoalLimit = false;
  bool hasExtraTime = false;
  late int qtdPlayers;
  late int minPlayers;
  late int maxPlayers;
  late int divisions;

  @override
  void initState() {
    super.initState();
    final session = ref.read(gameSessionProvider);
    final config = session.config!;
    final game = session.currentGame!;
    final event = session.event!;

    numberController = TextEditingController(text: game.number.toString());
    categoryController = TextEditingController(text: event.gameConfig!.category);
    startTimeController = TextEditingController(text: DateFormat.Hm().format(game.startTime!));
    endTimeController = TextEditingController(text: DateFormat.Hm().format(game.endTime!));
    durationController = TextEditingController(text: event.gameConfig?.duration.toString() ?? '');
    playersPerTeamController = TextEditingController(text: config.playersPerTeam.toString());
    hasTwoHalvesController = TextEditingController(text: config.config!['hasTwoHalves'].toString());
    hasExtraTimeController = TextEditingController(text: config.config!['hasExtraTime'].toString());
    hasPenaltyController = TextEditingController(text: config.config!['hasPenalty'].toString());
    hasGoalLimitController = TextEditingController(text: config.config!['hasGoalLimit'].toString());
    hasRefereerController = TextEditingController(text: config.config!['hasRefereer'].toString());
    extraTimeController = TextEditingController(text: (config.config!['extraTime'] ?? '').toString());
    goalLimitController = TextEditingController(text: (config.config!['goalLimit'] ?? '').toString());

    refereer = game.refereeId != null
        ? event.participants?.firstWhere(
            (u) => u.id == game.refereeId,
            orElse: () => event.participants!.first,
          )
        : null;

    setDuration(durationController.text);
    hasRefereerSwitch = bool.tryParse(hasRefereerController.text) ?? false;
    hasGoalLimit = bool.tryParse(hasGoalLimitController.text) ?? false;
    hasExtraTime = bool.tryParse(hasExtraTimeController.text) ?? false;

    qtdPlayers = playersPerTeamController.text.isNotEmpty
        ? int.parse(playersPerTeamController.text)
        : ModalityHelper.getQtdPlayers(categoryController.text)['minPlayers']!;
    minPlayers = ModalityHelper.getQtdPlayers(categoryController.text)['minPlayers']!;
    maxPlayers = ModalityHelper.getQtdPlayers(categoryController.text)['maxPlayers']!;
    divisions = ModalityHelper.getQtdPlayers(categoryController.text)['divisions']!;
  }

  @override
  void dispose() {
    numberController.dispose();
    categoryController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    durationController.dispose();
    hasTwoHalvesController.dispose();
    hasExtraTimeController.dispose();
    hasPenaltyController.dispose();
    hasGoalLimitController.dispose();
    hasRefereerController.dispose();
    playersPerTeamController.dispose();
    extraTimeController.dispose();
    goalLimitController.dispose();
    super.dispose();
  }

  void setDuration(String? duration) {
    if (duration != null && duration.isNotEmpty) {
      final startTime = ref.read(gameSessionProvider).currentGame?.startTime;
      if (startTime == null) return;
      setState(() {
        final hasTwoHalves = bool.tryParse(hasTwoHalvesController.text) ?? false;
        final totalDuration = hasTwoHalves ? int.parse(duration) * 2 : int.parse(duration);
        final endTime = startTime.add(Duration(minutes: totalDuration));
        endTimeController.text = DateFormat.Hm().format(endTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var dimensions = MediaQuery.of(context).size;
    final event = ref.read(gameSessionProvider).event;
    final match = ref.read(gameMatchProvider);

    return Scaffold(
      appBar: HeaderWidget(
        title: "Configurações da Partida",
        leftAction: () => context.pop(),
        shadow: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: AppColors.green_300,
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
                        "As configurações da partida determinam como as partidas da pelada funcionam, duração de tempos, limites de gols, arbitragem, dentre outros. Essas configurações podem ser ajustadas antes do início de uma nova partida.",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.blue_500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  spacing: 10,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InputTextWidget(name: 'number', label: 'Nº', textController: numberController, enable: false),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: InputTextWidget(name: 'category', label: 'Categoria', textController: categoryController, enable: false),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InputTextWidget(
                              name: 'startTime', label: 'Início',
                              prefixIcon: Icons.access_time_rounded,
                              textController: startTimeController, enable: false,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: InputTextWidget(
                            name: 'endTime', label: 'Fim',
                            prefixIcon: Icons.access_time_rounded,
                            textController: endTimeController,
                            type: TextInputType.text, enable: false,
                          ),
                        ),
                      ],
                    ),
                    InputTextWidget(
                      name: 'duration',
                      label: bool.tryParse(hasTwoHalvesController.text) == true
                          ? "Duração (min. por tempo)"
                          : "Duração (min.)",
                      prefixIcon: Icons.timer_outlined,
                      textController: durationController,
                      type: TextInputType.number,
                      onChanged: (value) => setDuration(value),
                    ),
                    InputSwitchWidget(
                      name: "dois_tempos", label: "Dois Tempos",
                      prefixIcon: Icons.safety_divider_rounded,
                      value: bool.tryParse(hasTwoHalvesController.text) ?? false,
                      textController: hasTwoHalvesController,
                      onChanged: (value) {
                        setState(() { hasTwoHalvesController.text = value.toString(); });
                      },
                    ),
                    InputSwitchWidget(
                      name: "prorrogacao", label: "Prorrogação",
                      prefixIcon: Icons.more_time_rounded,
                      value: bool.tryParse(hasExtraTimeController.text) ?? false,
                      textController: hasExtraTimeController,
                      onChanged: (value) {
                        setState(() {
                          hasExtraTime = value;
                          hasExtraTimeController.text = value.toString();
                        });
                      },
                    ),
                    if (hasExtraTime) ...[
                      InputTextWidget(
                        name: 'extra_time', label: 'Tempo Prorrogação',
                        prefixIcon: Icons.timer_outlined,
                        textController: extraTimeController,
                        type: TextInputType.number,
                      ),
                    ],
                    InputSwitchWidget(
                      name: "penaltis", label: "Pênaltis",
                      prefixIcon: Icons.sports,
                      value: bool.tryParse(hasPenaltyController.text) ?? false,
                      textController: hasPenaltyController,
                      onChanged: (value) {
                        setState(() { hasPenaltyController.text = value.toString(); });
                      },
                    ),
                    InputSwitchWidget(
                      name: "limit_goals", label: "Limite de Gols",
                      prefixIcon: Icons.scoreboard_outlined,
                      value: bool.tryParse(hasGoalLimitController.text) ?? false,
                      textController: hasGoalLimitController,
                      onChanged: (value) {
                        setState(() {
                          hasGoalLimit = value;
                          hasGoalLimitController.text = value.toString();
                        });
                      },
                    ),
                    if (hasGoalLimit) ...[
                      InputTextWidget(
                        name: 'limitGols', label: 'Qtd. Gols',
                        prefixIcon: Icons.sports_soccer_rounded,
                        textController: goalLimitController,
                        type: TextInputType.number,
                      ),
                    ],
                    SilderPlayersWidget(
                      qtdPlayers: qtdPlayers.toDouble(),
                      minPlayers: minPlayers.toDouble(),
                      maxPlayers: maxPlayers.toDouble(),
                      divisions: divisions,
                      onChange: (value) {
                        setState(() {
                          qtdPlayers = value.floor();
                          playersPerTeamController.text = value.floor().toString();
                        });
                      },
                    ),
                    InputSwitchWidget(
                      name: "refeer", label: "Árbitro",
                      prefixIcon: Icons.sports,
                      value: bool.tryParse(hasRefereerController.text) ?? false,
                      textController: hasRefereerController,
                      onChanged: (value) {
                        setState(() {
                          hasRefereerSwitch = value;
                          hasRefereerController.text = value.toString();
                        });
                      },
                    ),
                    if (hasRefereerSwitch && event != null) ...[
                      ButtonDropdownIconWidget<UserModel>(
                        width: dimensions.width,
                        menuWidth: dimensions.width - 20,
                        menuHeight: 200,
                        backgroundColor: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.dark_300
                            : AppColors.white,
                        iconAfter: false,
                        iconSize: 30,
                        textSize: AppSize.fontMd,
                        onChange: (u) => setState(() => refereer = u),
                        selectedItem: refereer,
                        items: event.participants!,
                        labelBuilder: (u) => UserHelper.getFullName(u),
                        iconBuilder: (u) => CircleAvatar(
                          backgroundImage: ImgHelper.getUserImg(u.photo),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ButtonOutlineWidget(text: "Voltar", width: 100, action: () => context.pop()),
                    ButtonTextWidget(
                      text: "Salvar",
                      icon: Icons.save,
                      width: 100,
                      action: () {
                        ref.read(gameSessionProvider.notifier).applyGameConfig(
                          categoryText: categoryController.text,
                          durationText: durationController.text,
                          playersPerTeamText: playersPerTeamController.text,
                          hasTwoHalvesText: hasTwoHalvesController.text,
                          hasExtraTimeText: hasExtraTimeController.text,
                          hasPenaltyText: hasPenaltyController.text,
                          hasGoalLimitText: hasGoalLimitController.text,
                          hasRefereerText: hasRefereerController.text,
                          extraTimeText: extraTimeController.text,
                          goalLimitText: goalLimitController.text,
                          teamAName: match.teamA.name ?? 'Time 1',
                          teamAEmblem: match.teamA.emblem ?? 'emblema_1',
                          teamBName: match.teamB.name ?? 'Time 2',
                          teamBEmblem: match.teamB.emblem ?? 'emblema_2',
                          startTimeMinutes: 0,
                          refereer: refereer,
                        );
                        context.pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
