import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:esportly/core/theme/app_size.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/core/helpers/user_helper.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:esportly/data/models/game_model.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/core/providers/game/game_config_provider.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
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
  // Informações da partida (read-only)
  late TextEditingController numberController;
  late TextEditingController categoryController;
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;

  // Comuns
  late TextEditingController durationController;
  late int qtdPlayers;
  late int minPlayers;
  late int maxPlayers;
  late int divisions;

  // Football
  bool hasTwoHalves = false;
  bool hasExtraTime = false;
  late TextEditingController extraTimeController;
  bool hasPenalty = false;
  bool hasGoalLimit = false;
  late TextEditingController goalLimitController;
  bool hasRefereer = false;
  UserModel? refereer;

  // Volleyball
  late TextEditingController setsController;
  bool hasPointsLimit = false;
  late TextEditingController pointsController;
  bool hasTieBreak = false;
  late TextEditingController tieBreakPointsController;

  // Basketball
  late TextEditingController quartersController;

  String get category => categoryController.text;

  String _sportType(String cat) {
    switch (cat) {
      case 'Futebol':
      case 'Fut7':
      case 'Futsal':
        return 'Football';
      case 'Volei':
      case 'Volei de praia':
      case 'Fut Volei':
        return 'Volleyball';
      case 'Basquete':
      case 'Streetball':
        return 'Basketball';
      default:
        return 'Football';
    }
  }

  @override
  void initState() {
    super.initState();
    final gameSession = ref.read(gameSessionProvider);
    final config = ref.read(gameConfigProvider).config!;
    final game = gameSession.currentGame!;
    final event = gameSession.event!;
    final cfg = config.config ?? {};

    numberController = TextEditingController(text: game.number.toString());
    categoryController = TextEditingController(text: config.category);
    startTimeController = TextEditingController(
      text: game.startTime != null ? DateFormat.Hm().format(game.startTime!) : '--:--',
    );
    endTimeController = TextEditingController(
      text: game.endTime != null ? DateFormat.Hm().format(game.endTime!) : '--:--',
    );
    durationController = TextEditingController(text: config.duration?.toString() ?? '');

    extraTimeController = TextEditingController(text: (cfg['extraTime'] ?? '').toString());
    goalLimitController = TextEditingController(text: (cfg['goalLimit'] ?? '').toString());
    setsController = TextEditingController(text: (cfg['sets'] ?? '').toString());
    pointsController = TextEditingController(text: (cfg['points'] ?? '').toString());
    tieBreakPointsController = TextEditingController(text: (cfg['tieBreakPoints'] ?? '').toString());
    quartersController = TextEditingController(text: (cfg['quarters'] ?? '').toString());

    hasTwoHalves = cfg['hasTwoHalves'] == true;
    hasExtraTime = cfg['hasExtraTime'] == true;
    hasPenalty = cfg['hasPenalty'] == true;
    hasGoalLimit = cfg['hasGoalLimit'] == true;
    hasRefereer = cfg['hasRefereer'] == true;
    hasPointsLimit = cfg['hasPointsLimit'] == true;
    hasTieBreak = cfg['hasTieBreak'] == true;

    refereer = game.refereeId != null
        ? event.participants?.firstWhere(
            (u) => u.id == game.refereeId,
            orElse: () => event.participants!.first,
          )
        : null;

    final qtd = ModalityHelper.getQtdPlayers(config.category);
    minPlayers = qtd['minPlayers']!;
    maxPlayers = qtd['maxPlayers']!;
    divisions = qtd['divisions']!;
    qtdPlayers = (config.playersPerTeam ?? minPlayers).clamp(minPlayers, maxPlayers);

    _recalcEndTime();
  }

  @override
  void dispose() {
    numberController.dispose();
    categoryController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    durationController.dispose();
    extraTimeController.dispose();
    goalLimitController.dispose();
    setsController.dispose();
    pointsController.dispose();
    tieBreakPointsController.dispose();
    quartersController.dispose();
    super.dispose();
  }

  //FUNÇÃO DE CALCULO DE FIM DA PARTIDA
  void _recalcEndTime() {
    final start = ref.read(gameSessionProvider).currentGame?.startTime;
    if (start == null) return;
    final dur = int.tryParse(durationController.text) ?? 0;
    int total;
    switch (_sportType(category)) {
      case 'Football':
        total = dur * (hasTwoHalves ? 2 : 1);
        break;
      case 'Basketball':
        total = dur * (int.tryParse(quartersController.text) ?? 4);
        break;
      default:
        total = dur;
    }
    setState(() {
      endTimeController.text = DateFormat.Hm().format(start.add(Duration(minutes: total)));
    });
  }

  //FUNÇÃO DE CONSTRUÇÃO DE MAP DE CONFIGURAÇÕES POR MODALIDADE
  Map<String, dynamic> _buildConfigMap() {
    switch (_sportType(category)) {
      case 'Football':
        return {
          'hasTwoHalves': hasTwoHalves,
          'hasExtraTime': hasExtraTime,
          'hasPenalty': hasPenalty,
          'hasGoalLimit': hasGoalLimit,
          'hasRefereer': hasRefereer,
          'extraTime': hasExtraTime ? int.tryParse(extraTimeController.text) : null,
          'goalLimit': hasGoalLimit ? int.tryParse(goalLimitController.text) : null,
        };
      case 'Volleyball':
        return {
          'sets': int.tryParse(setsController.text),
          'hasPointsLimit': hasPointsLimit,
          'points': hasPointsLimit ? int.tryParse(pointsController.text) : null,
          'hasTieBreak': hasTieBreak,
          'tieBreakPoints': hasTieBreak ? int.tryParse(tieBreakPointsController.text) : null,
        };
      case 'Basketball':
        return {
          'quarters': int.tryParse(quartersController.text),
          'hasExtraTime': hasExtraTime,
          'extraTime': hasExtraTime ? int.tryParse(extraTimeController.text) : null,
          'hasPointsLimit': hasPointsLimit,
          'points': hasPointsLimit ? int.tryParse(pointsController.text) : null,
        };
      default:
        return {};
    }
  }

  //FUNÇÃO DE DEFINIÇÃO DE HEADER DE SEÇÕES
  Widget _sectionHeader(BuildContext context, String label, IconData icon, Color modalityColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: modalityColor),
          const SizedBox(width: 6),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              color: modalityColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(thickness: 1, color: modalityColor)),
        ],
      ),
    );
  }

  List<Widget> _buildFootballConfig(BuildContext context) {
    return [
      InputSwitchWidget(
        name: "dois_tempos",
        label: "Dois Tempos",
        prefixIcon: Icons.safety_divider_rounded,
        value: hasTwoHalves,
        textController: TextEditingController(text: hasTwoHalves.toString()),
        onChanged: (v) => setState(() {
          hasTwoHalves = v;
          _recalcEndTime();
        }),
      ),
      InputSwitchWidget(
        name: "prorrogacao",
        label: "Prorrogação",
        prefixIcon: Icons.more_time_rounded,
        value: hasExtraTime,
        textController: TextEditingController(text: hasExtraTime.toString()),
        onChanged: (v) => setState(() => hasExtraTime = v),
      ),
      if (hasExtraTime)
        InputTextWidget(
          name: 'extra_time',
          label: 'Duração da Prorrogação (min.)',
          prefixIcon: Icons.timer_outlined,
          textController: extraTimeController,
          type: TextInputType.number,
        ),
      InputSwitchWidget(
        name: "penaltis",
        label: "Pênaltis",
        prefixIcon: Icons.sports,
        value: hasPenalty,
        textController: TextEditingController(text: hasPenalty.toString()),
        onChanged: (v) => setState(() => hasPenalty = v),
      ),
      InputSwitchWidget(
        name: "limit_goals",
        label: "Limite de Gols",
        prefixIcon: Icons.scoreboard_outlined,
        value: hasGoalLimit,
        textController: TextEditingController(text: hasGoalLimit.toString()),
        onChanged: (v) => setState(() => hasGoalLimit = v),
      ),
      if (hasGoalLimit)
        InputTextWidget(
          name: 'goalLimit',
          label: 'Quantidade de Gols',
          prefixIcon: Icons.sports_soccer_rounded,
          textController: goalLimitController,
          type: TextInputType.number,
        ),
    ];
  }

  List<Widget> _buildVolleyballConfig(BuildContext context) {
    return [
      InputTextWidget(
        name: 'sets',
        label: 'Número de Sets',
        prefixIcon: Icons.format_list_numbered_rounded,
        textController: setsController,
        type: TextInputType.number,
      ),
      InputSwitchWidget(
        name: "has_points_limit",
        label: "Limite de Pontos",
        prefixIcon: Icons.scoreboard_outlined,
        value: hasPointsLimit,
        textController: TextEditingController(text: hasPointsLimit.toString()),
        onChanged: (v) => setState(() => hasPointsLimit = v),
      ),
      if (hasPointsLimit)
        InputTextWidget(
          name: 'points',
          label: 'Pontos por Set',
          prefixIcon: Icons.plus_one_rounded,
          textController: pointsController,
          type: TextInputType.number,
        ),
      InputSwitchWidget(
        name: "tie_break",
        label: "Tie-Break",
        prefixIcon: Icons.sports_volleyball_rounded,
        value: hasTieBreak,
        textController: TextEditingController(text: hasTieBreak.toString()),
        onChanged: (v) => setState(() => hasTieBreak = v),
      ),
      if (hasTieBreak)
        InputTextWidget(
          name: 'tieBreakPoints',
          label: 'Pontos no Tie-Break',
          prefixIcon: Icons.plus_one_rounded,
          textController: tieBreakPointsController,
          type: TextInputType.number,
        ),
    ];
  }

  List<Widget> _buildBasketballConfig(BuildContext context) {
    return [
      InputTextWidget(
        name: 'quarters',
        label: 'Número de Quartos',
        prefixIcon: Icons.format_list_numbered_rounded,
        textController: quartersController,
        type: TextInputType.number,
        onChanged: (_) => _recalcEndTime(),
      ),
      InputSwitchWidget(
        name: "prorrogacao",
        label: "Prorrogação",
        prefixIcon: Icons.more_time_rounded,
        value: hasExtraTime,
        textController: TextEditingController(text: hasExtraTime.toString()),
        onChanged: (v) => setState(() => hasExtraTime = v),
      ),
      if (hasExtraTime)
        InputTextWidget(
          name: 'extra_time',
          label: 'Duração da Prorrogação (min.)',
          prefixIcon: Icons.timer_outlined,
          textController: extraTimeController,
          type: TextInputType.number,
        ),
      InputSwitchWidget(
        name: "has_points_limit",
        label: "Limite de Pontos",
        prefixIcon: Icons.scoreboard_outlined,
        value: hasPointsLimit,
        textController: TextEditingController(text: hasPointsLimit.toString()),
        onChanged: (v) => setState(() => hasPointsLimit = v),
      ),
      if (hasPointsLimit)
        InputTextWidget(
          name: 'points',
          label: 'Pontos por Quarto',
          prefixIcon: Icons.plus_one_rounded,
          textController: pointsController,
          type: TextInputType.number,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = MediaQuery.of(context).size;
    final eventSession = ref.read(eventSessionProvider);
    final event = ref.read(gameSessionProvider).event;
    final modalityColor = eventSession.modalityColor;
    final sportType = _sportType(category);
    final hasDuration = sportType == 'Football' || sportType == 'Basketball';

    return Scaffold(
      appBar: HeaderWidget(
        title: "Configurações da Partida",
        backgroundColor: modalityColor,
        leftAction: () => context.pop(),
        shadow: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Banner topo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: modalityColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dark_500.withAlpha(50),
                      spreadRadius: 0.5,
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  "Defina as regras desta partida: duração, configurações de ${sportType == 'Football' ? 'tempos, gols e arbitragem' : sportType == 'Volleyball' ? 'sets e pontuação' : 'quartos e pontuação'}. Essas configurações valem apenas para esta partida.",
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppColors.blue_500),
                  textAlign: TextAlign.center,
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [

                    // SEÇÃO: Informações
                    _sectionHeader(context, "Informações pré-definidas", Icons.info_outline_rounded, modalityColor),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InputTextWidget(
                              name: 'number',
                              label: 'Nº',
                              textController: numberController,
                              enable: false,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: InputTextWidget(
                            name: 'category',
                            label: 'Modalidade',
                            textController: categoryController,
                            enable: false,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: InputTextWidget(
                              name: 'startTime',
                              label: 'Início',
                              prefixIcon: Icons.access_time_rounded,
                              textController: startTimeController,
                              enable: false,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: InputTextWidget(
                            name: 'endTime',
                            label: 'Fim (estimado)',
                            prefixIcon: Icons.access_time_rounded,
                            textController: endTimeController,
                            enable: false,
                          ),
                        ),
                      ],
                    ),

                    // SEÇÃO: Duração e Jogadores
                    _sectionHeader(
                      context, 
                      sportType == 'Football' ? "Duração & Jogadores" : "Nº de Jogadores", 
                      Icons.timer_outlined, 
                      modalityColor
                    ),
                    if (hasDuration)
                      InputTextWidget(
                        name: 'duration',
                        label: sportType == 'Football'
                            ? "Duração por Tempo (min.)"
                            : "Duração por Quarto (min.)",
                        prefixIcon: Icons.timer_outlined,
                        textController: durationController,
                        type: TextInputType.number,
                        onChanged: (_) => _recalcEndTime(),
                      ),
                    SilderPlayersWidget(
                      qtdPlayers: qtdPlayers.toDouble(),
                      minPlayers: minPlayers.toDouble(),
                      maxPlayers: maxPlayers.toDouble(),
                      divisions: divisions,
                      onChange: (value) {
                        setState(() => qtdPlayers = value.floor());
                      },
                    ),

                    // SEÇÃO: Regras (dinâmico por modalidade)
                    _sectionHeader(
                      context,
                      sportType == 'Football'
                          ? "Regras de Futebol"
                          : sportType == 'Volleyball'
                              ? "Regras de Vôlei"
                              : "Regras de Basquete",
                      Icons.rule_rounded,
                      modalityColor
                    ),
                    if (sportType == 'Football') ..._buildFootballConfig(context),
                    if (sportType == 'Volleyball') ..._buildVolleyballConfig(context),
                    if (sportType == 'Basketball') ..._buildBasketballConfig(context),

                    _sectionHeader(context, "Arbitragem", Icons.sports_rounded, modalityColor),
                    InputSwitchWidget(
                      name: "refeer",
                      label: "Árbitro",
                      prefixIcon: Icons.sports,
                      value: hasRefereer,
                      textController: TextEditingController(text: hasRefereer.toString()),
                      onChanged: (v) => setState(() => hasRefereer = v),
                    ),
                    if (hasRefereer && event != null && (event.participants?.isNotEmpty ?? false))
                      ButtonDropdownIconWidget<UserModel>(
                        width: dimensions.width,
                        menuWidth: dimensions.width - 32,
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

                    const SizedBox(height: 8),

                    // Botões
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ButtonOutlineWidget(
                          text: "Voltar",
                          width: 110,
                          action: () => context.pop(),
                        ),
                        ButtonTextWidget(
                          text: "Salvar",
                          icon: Icons.save_rounded,
                          backgroundColor: modalityColor,
                          width: 110,
                          action: () {
                            ref.read(gameConfigProvider.notifier).applyConfig(
                              category: category,
                              duration: int.tryParse(durationController.text),
                              playersPerTeam: qtdPlayers,
                              configMap: _buildConfigMap(),
                              refereer: refereer,
                            );
                            context.pop();
                          },
                        ),
                      ],
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
