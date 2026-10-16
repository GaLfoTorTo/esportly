import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/enum/enums.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/core/helpers/img_helper.dart';
import 'package:esportly/core/helpers/user_helper.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
import 'package:esportly/data/models/event_model.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/presentation/widget/badges/position_widget.dart';

class CardMvpWidget extends ConsumerStatefulWidget {
  final EventModel event;
  final UserModel? mvp;

  const CardMvpWidget({
    super.key,
    required this.event,
    this.mvp,
  });

  @override
  ConsumerState<CardMvpWidget> createState() => _CardMvpWidgetState();
}

class _CardMvpWidgetState extends ConsumerState<CardMvpWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameEvents = ref.watch(gameMatchProvider.select((s) => s.gameEvents));

    final info = ModalityHelper.getEventModalityColor(widget.event.gameConfig?.category ?? widget.event.modality?.name ?? 'Football');
    final Color modalityColor = info['color'];
    final Color textColor = info['textColor'];
    final String modalityImage = info['image'];

    final player = widget.mvp ?? (widget.event.participants?.isNotEmpty == true
      ? widget.event.participants!.first
      : null);

    if (player == null) return const SizedBox.shrink();

    final mainPos = player.player?.getMainPosition(widget.event.modality?.name ?? '');
    final rating = player.player?.ratings
        ?.where((r) => r.eventId == widget.event.id)
        .firstOrNull ??
        player.player?.ratings?.firstOrNull;

    final goals = player.id != null
        ? gameEvents
            .where((e) => e.userId == player.id && e.type == GameEvent.Goal)
            .length
        : 0;
    final assists = player.id != null
        ? gameEvents
            .where((e) => e.userId == player.id && e.type == GameEvent.Assist)
            .length
        : 0;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: modalityColor,
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage(modalityImage),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              modalityColor.withAlpha(205),
              BlendMode.srcATop,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: AppColors.dark_500.withAlpha(50),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))
              ),
              child: Row(
                spacing: 10,
                children: [
                  const Icon(
                    Icons.emoji_events_rounded, 
                    color: AppColors.yellow_400, 
                    size: 22
                  ),
                  Text(
                    'MVP DO DIA',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: AppColors.yellow_400,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _PlayerInfo(
                      player: player,
                      textColor: AppColors.white,
                      mainPosAlias: mainPos?.alias,
                      stats: _buildStats(rating, goals, assists),
                    ),
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 118,
                          height: 118,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.yellow_400, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.yellow_400.withAlpha(90),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        // avatar
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: ImgHelper.getUserImg(player.photo),
                        ),
                        // crown
                        const Positioned(
                          top: -5,
                          child: Text('👑', style: TextStyle(fontSize: 20))
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_StatItem> _buildStats(dynamic rating, int goals, int assists) {
    final items = <_StatItem>[];
    
    items.add(_StatItem(Icons.sports_soccer_rounded, 'Gols', '$goals'));
    items.add(_StatItem(Icons.handshake_rounded, 'Assist.', '$assists'));
    items.add(_StatItem(Icons.sports_rounded, 'Partidas', "${rating.games ?? 0}"));
    items.add(_StatItem(Icons.bar_chart_rounded, 'Média', "${rating.avarage ?? 0}"));
    return items;
  }
}

// ─── DATA ────────────────────────────────────────────────────────────────────

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  const _StatItem(this.icon, this.label, this.value);
}

// ─── PLAYER INFO ─────────────────────────────────────────────────────────────

class _PlayerInfo extends StatelessWidget {
  final UserModel player;
  final Color textColor;
  final String? mainPosAlias;
  final List<_StatItem> stats;

  const _PlayerInfo({
    required this.player,
    required this.textColor,
    required this.mainPosAlias,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        Row(
          spacing: 10,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  UserHelper.getFullName(player),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '@${player.userName ?? ''}',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: textColor.withAlpha(200),
                  ),
                ),
              ],
            ),
            if (mainPosAlias != null)...[
              PositionWidget(
                position: mainPosAlias!,
                mainPosition: true,
                width: 40,
                height: 27,
                textSide: 10,
              ),
            ]
          ],
        ),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: stats.map((s){
            return Container(
              width: 70,
              height: 70,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [
                  Icon(
                    s.icon, 
                    size: 15, 
                    color: AppColors.white
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.value,
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: AppColors.white
                        )
                      ),
                      Text(
                        s.label,
                        style: Theme.of(context).textTheme.displaySmall!.copyWith(
                          color: AppColors.white
                        )
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}