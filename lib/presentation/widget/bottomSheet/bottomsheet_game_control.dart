import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/enum/enums.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/helpers/loading_overlay.dart';
import 'package:esportly/core/helpers/game_action_helper.dart';
import 'package:esportly/core/providers/game/game_config_provider.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
import 'package:esportly/core/providers/game/game_session_provider.dart';
import 'package:esportly/core/providers/game/game_control_provider.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/presentation/widget/cards/card_score_widget.dart';
import 'package:esportly/presentation/widget/bottomSheet/bottomsheet_player_picker.dart';
import 'package:esportly/presentation/widget/overlays/stopwatch_overlay_widget.dart';

class BottomsheetGameControl extends ConsumerStatefulWidget {
  const BottomsheetGameControl({super.key});

  @override
  ConsumerState<BottomsheetGameControl> createState() => _BottomsheetGameControlState();
}

class _BottomsheetGameControlState extends ConsumerState<BottomsheetGameControl> {
  String _selectedTeam = 'A';

  void _showOverlay(BuildContext ctx, VoidCallback fn, String action, {String? periodName}) {
    Future.delayed(const Duration(milliseconds: 200), () async {
      if (!ctx.mounted) return;
      await LoadingOverlay.show(
        ctx,
        () async {
          await Future.delayed(const Duration(seconds: 5));
          fn();
        },
        loadingWidget: Material(
          color: Colors.transparent,
          child: StopWatchOverlayWidget(seconds: 5, action: action, periodName: periodName),
        ),
        barrierColor: AppColors.dark_700.withAlpha(178),
      );
    });
  }

  void _handleControl(String action) {
    final rootCtx = Navigator.of(context, rootNavigator: true).context;
    final controlSession = ref.read(gameControlProvider.notifier);
    final controlState = ref.read(gameControlProvider);
    final configSession = ref.read(gameConfigProvider);
    final periodConfig = GameActionHelper.getPeriodConfig(configSession.config?.category);
    final currentPeriod = controlState.currentPeriod;
    final periodLabel = periodConfig.label;

    switch (action) {
      case 'pause':
        controlSession.pauseGame();
        setState(() {});
        return;
      case 'start':
        Navigator.of(context).pop();
        _showOverlay(rootCtx, controlSession.startGame, action);
        return;
      case 'stop':
        Navigator.of(context).pop();
        _showOverlay(rootCtx, controlSession.stopGame, action,
            periodName: '$currentPeriod° $periodLabel');
        return;
      case 'reset':
        Navigator.of(context).pop();
        _showOverlay(rootCtx, controlSession.resetGame, action);
        return;
      case 'next_period':
        Navigator.of(context).pop();
        _showOverlay(rootCtx, controlSession.nextPeriod, action,
            periodName: '$currentPeriod° $periodLabel');
        return;
    }
  }

  void _registerEventForPlayer(GameEvent gameEvent, int? userId) {
    if (!ref.read(gameControlProvider).isGameRunning) return;
    ref.read(gameMatchProvider.notifier).applyStreamAction({
      'action': gameEvent.index,
      'team': _selectedTeam,
      if (userId != null) 'userId': userId,
    });
  }

  void _showPlayerPicker(BuildContext context, GameActionConfig action) {
    if (!ref.read(gameControlProvider).isGameRunning) return;

    final currentGame = ref.read(gameSessionProvider).currentGame;
    if (currentGame == null || (currentGame.teams?.length ?? 0) < 2) return;

    final team = _selectedTeam == 'A'
        ? currentGame.teams!.first
        : currentGame.teams!.last;
    final teamColor =
        _selectedTeam == 'A' ? AppColors.blue_300 : AppColors.red_300;

    if (!action.requiresPlayer) {
      _registerEventForPlayer(action.event, null);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BottomsheetPlayerPicker(
        actionLabel: action.label,
        actionIcon: action.icon,
        actionColor: action.color,
        players: team.players,
        modality: ref.read(eventSessionProvider).event!.modality!.name,
        teamName: team.name ?? (_selectedTeam == 'A' ? 'Time A' : 'Time B'),
        teamColor: teamColor,
        onPlayerSelected: (userId) {
          Navigator.of(context, rootNavigator: true).pop();
          _registerEventForPlayer(action.event, userId);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dimensions = MediaQuery.of(context).size;
    final controlSession = ref.watch(gameControlProvider);
    final matchSession = ref.watch(gameMatchProvider);
    final configSession = ref.watch(gameConfigProvider);
    final eventSession = ref.watch(eventSessionProvider);
    final gameSession = ref.read(gameSessionProvider);

    final modalityColor = eventSession.modalityColor;
    final category = configSession.config?.category;
    final actions = GameActionHelper.getActions(category);
    final periodConfig = GameActionHelper.getPeriodConfig(category);
    final isRunning = controlSession.isGameRunning;
    final currentPeriod = controlSession.currentPeriod;
    final totalPeriods = periodConfig.total;
    final periodLabel = periodConfig.label;
    final isLastPeriod = currentPeriod >= totalPeriods;

    final duration = configSession.config?.duration != null
      ? Duration(minutes: configSession.config!.duration!)
      : gameSession.currentGame?.duration != null
        ? Duration(minutes: gameSession.currentGame!.duration!)
        : const Duration(minutes: 10);

    final extraMinutes   = controlSession.extraMinutes;
    final totalMinutes   = duration.inMinutes + extraMinutes;
    final totalSec       = totalMinutes * 60;
    final parts          = controlSession.currentTime.split(':');
    final elapsedMin     = int.tryParse(parts[0]) ?? 0;
    final elapsedSec     = int.tryParse(parts[1]) ?? 0;
    final elapsedTotal   = elapsedMin * 60 + elapsedSec;
    final remainingMin   = totalMinutes - elapsedMin;
    final progress       = totalSec > 0 ? (elapsedTotal / totalSec).clamp(0.0, 1.0) : 0.0;
    final showExtraPanel = periodConfig.hasExtraTime && controlSession.isGameRunning && remainingMin <= 2 && remainingMin >= 0;

    return Container(
      width: dimensions.width,
      constraints: BoxConstraints(maxHeight: dimensions.height * 0.85),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.dark_500
          : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey_300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 16,
                  children: [
                    //PLACAR
                    const CardScoreWidget(),

                    //BARRA DE ANDAMENTO DA PARTIDA
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                        spacing: 6,
                        children: [
                          // INDICADOR DE PERÍODO
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                spacing: 6,
                                children: List.generate(totalPeriods, (i) {
                                  final periodNum = i + 1;
                                  final isActive = periodNum == currentPeriod;
                                  final isDone = periodNum < currentPeriod;
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? modalityColor.withAlpha(30)
                                          : isDone
                                              ? modalityColor.withAlpha(15)
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isActive
                                            ? modalityColor
                                            : isDone
                                                ? modalityColor.withAlpha(60)
                                                : AppColors.grey_300,
                                        width: isActive ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      '$periodNum° $periodLabel',
                                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                        color: isActive
                                            ? modalityColor
                                            : isDone
                                                ? modalityColor.withAlpha(140)
                                                : AppColors.grey_500,
                                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              Text(
                                controlSession.currentTime,
                                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                  color: modalityColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: modalityColor.withAlpha(40),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(modalityColor),
                            borderRadius: BorderRadius.circular(4),
                            minHeight: 6,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('00:00',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(color: AppColors.grey_500)),
                              Text(
                                '${duration.inMinutes.toString().padLeft(2, '0')}:00',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall!
                                    .copyWith(color: AppColors.grey_500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    //BOTÕES DE CONTROLE
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      margin: const EdgeInsets.symmetric(horizontal: 20.0),
                      decoration: BoxDecoration(
                        color: modalityColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _controlButton(context,
                              icon: Icons.restart_alt_rounded,
                              label: 'Reiniciar',
                              color: AppColors.grey_500,
                              size: 36,
                              onTap: () => _handleControl('reset')),
                          _controlButton(context,
                              icon: isRunning
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              label: isRunning ? 'Pausar' : 'Iniciar',
                              color: modalityColor,
                              size: 64,
                              onTap: () => _handleControl(isRunning ? 'pause' : 'start')),
                          _controlButton(context,
                              icon: Icons.stop_rounded,
                              label: 'Fim ${controlSession.currentPeriod} $periodLabel',
                              color: AppColors.red_300,
                              size: 36,
                              onTap: () => _handleControl(isLastPeriod ? 'stop' : 'next_period'))],
                      ),
                    ),

                    // PAINEL DE ACRÉSCIMOS
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => SizeTransition(
                        sizeFactor: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: showExtraPanel
                          ? Container(
                              key: const ValueKey('extra_panel'),
                              margin: const EdgeInsets.symmetric(horizontal: 15.0),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.orange_300.withAlpha(15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.orange_300.withAlpha(80)),
                              ),
                              child: Column(
                                spacing: 10,
                                children: [
                                  Row(
                                    spacing: 8,
                                    children: [
                                      const Icon(Icons.timer_outlined,
                                          color: AppColors.orange_300, size: 18),
                                      Expanded(
                                        child: Text(
                                          extraMinutes > 0
                                              ? 'Acréscimos: +$extraMinutes min'
                                              : 'Adicionar acréscimos',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .copyWith(
                                                  color: AppColors.orange_300,
                                                  fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [1, 2, 3, 4, 5].map((min) {
                                      return Material(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                        clipBehavior: Clip.antiAlias,
                                        child: InkWell(
                                          onTap: () => ref
                                              .read(gameControlProvider.notifier)
                                              .addExtraTime(min),
                                          splashColor: AppColors.orange_300
                                              .withAlpha(60),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 14),
                                            decoration: BoxDecoration(
                                              color: AppColors.orange_300
                                                  .withAlpha(20),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: AppColors.orange_300
                                                      .withAlpha(60)),
                                            ),
                                            child: Text(
                                              '+$min',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium!
                                                  .copyWith(
                                                      color:
                                                          AppColors.orange_300,
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(key: ValueKey('no_extra')),
                    ),

                    const Divider(),

                    //SELETOR DE EQUIPE
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15.0),
                      decoration: BoxDecoration(
                        color: modalityColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _tabTeam(context,
                              label: matchSession.teamA.name ?? 'Time A',
                              selected: _selectedTeam == 'A',
                              color: AppColors.blue_300,
                              onTap: () => setState(() => _selectedTeam = 'A')),
                          _tabTeam(context,
                              label: matchSession.teamB.name ?? 'Time B',
                              selected: _selectedTeam == 'B',
                              color: AppColors.red_300,
                              onTap: () => setState(() => _selectedTeam = 'B')),
                        ],
                      ),
                    ),

                    //BOTÕES DE AÇÕES
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.spaceEvenly,
                        children: actions.map((a) => _actionButton(context, a, isRunning)).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }

  //WIDGET BOTÕES DE CONTROLE
  Widget _controlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required double size,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: color.withAlpha(60),
        highlightColor: color.withAlpha(30),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            spacing: 4,
            children: [
              Icon(
                icon, 
                color: color, 
                size: size
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: color
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  //WIDGET TABS DE EQUIPES
  Widget _tabTeam(
    BuildContext context, {
    required String label,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: color.withAlpha(80),
          highlightColor: color.withAlpha(40),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: selected ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                color: selected ? AppColors.white : AppColors.grey_500,
                fontWeight:selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  //WIDGET BOTÕES DE AÇÕES
  Widget _actionButton(
      BuildContext context, GameActionConfig action, bool enabled) {
    final dimensions = MediaQuery.of(context).size;
    final teamColor =
        _selectedTeam == 'A' ? AppColors.blue_300 : AppColors.red_300;
    final chipColor = enabled ? action.color : AppColors.grey_500;
    return Container(
      width: dimensions.width / 4,
      decoration: BoxDecoration(
        color: chipColor.withAlpha(enabled ? 20 : 10),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? () => _showPlayerPicker(context, action) : null,
        splashColor: chipColor.withAlpha(80),
        highlightColor: chipColor.withAlpha(40),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: chipColor.withAlpha(enabled ? 80 : 30), width: 1),
          ),
          child: Column(
            spacing: 4,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(action.icon, color: chipColor, size: 26),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      color: chipColor,
                      fontSize: 10,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (action.scoreLabel.isNotEmpty)
                Text(
                  action.scoreLabel,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: enabled
                      ? action.scoreColor(chipColor)
                      : AppColors.grey_300,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: enabled ? teamColor : AppColors.grey_300,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
