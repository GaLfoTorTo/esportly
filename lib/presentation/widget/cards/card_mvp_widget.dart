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

    final info = ModalityHelper.getEventModalityColor(
      widget.event.gameConfig?.category ?? widget.event.modality?.name ?? 'Football',
    );
    final Color modalityColor = info['color'];
    final Color textColor = info['textColor'];
    final String modalityImage = info['image'];

    final player = widget.mvp ??
        (widget.event.participants?.isNotEmpty == true
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

    final stats = _buildStats(rating, goals, assists);

    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.yellow_500.withAlpha((_glow.value * 70).round()),
              blurRadius: 24,
              spreadRadius: 3,
            ),
            BoxShadow(
              color: AppColors.dark_500.withAlpha(35),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: child,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: modalityColor,
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
              _Header(textColor: textColor, rating: rating?.avarage),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: _PlayerInfo(
                        player: player,
                        textColor: textColor,
                        mainPosAlias: mainPos?.alias,
                        stats: stats,
                      ),
                    ),
                    const SizedBox(width: 20),
                    _AvatarRing(player: player),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_StatItem> _buildStats(dynamic rating, int goals, int assists) {
    final items = <_StatItem>[];

    if (rating != null && (rating.games ?? 0) > 0) {
      items.add(_StatItem(Icons.sports_rounded, 'Jogos', '${rating.games}'));
    }
    if (rating != null && (rating.avarage ?? 0.0) > 0) {
      items.add(_StatItem(Icons.star_rounded, 'Média', (rating.avarage as double).toStringAsFixed(1)));
    }
    if (rating != null && (rating.points ?? 0.0) > 0) {
      items.add(_StatItem(Icons.bolt_rounded, 'Pontos', (rating.points as double).toStringAsFixed(0)));
    }
    if (goals > 0) {
      items.add(_StatItem(Icons.sports_soccer_rounded, 'Gols', '$goals'));
    }
    if (assists > 0) {
      items.add(_StatItem(Icons.handshake_rounded, 'Assist.', '$assists'));
    }
    if (items.isEmpty) {
      items.add(_StatItem(Icons.sports_rounded, 'Jogos', '—'));
      items.add(_StatItem(Icons.star_rounded, 'Média', '—'));
    }
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

// ─── HEADER ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final Color textColor;
  final double? rating;

  const _Header({required this.textColor, this.rating});

  @override
  Widget build(BuildContext context) {
    final stars = rating != null ? (rating! / 2).clamp(0.0, 5.0) : 0.0;
    final fullStars = stars.floor();
    final hasHalf = (stars - fullStars) >= 0.5;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      color: AppColors.dark_700.withAlpha(45),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded, color: AppColors.yellow_400, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 1,
              children: [
                Text(
                  'MVP DO DIA',
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: AppColors.yellow_400,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Melhor atuação da rodada',
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: textColor.withAlpha(150),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 1,
            children: List.generate(5, (i) {
              if (i < fullStars) {
                return const Icon(Icons.star_rounded, size: 15, color: AppColors.yellow_400);
              } else if (i == fullStars && hasHalf) {
                return const Icon(Icons.star_half_rounded, size: 15, color: AppColors.yellow_400);
              } else {
                return Icon(Icons.star_outline_rounded, size: 15, color: AppColors.yellow_400.withAlpha(100));
              }
            }),
          ),
        ],
      ),
    );
  }
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
                color: textColor.withAlpha(170),
              ),
            ),
          ],
        ),
        Row(
          spacing: 8,
          children: [
            if (mainPosAlias != null)
              PositionWidget(
                position: mainPosAlias!,
                mainPosition: true,
                width: 40,
                height: 27,
                textSide: 10,
              ),
            if (player.level != null)
              _TierBadge(tier: player.level!.tier, textColor: textColor),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: stats
              .map((s) => _StatChip(stat: s, textColor: textColor))
              .toList(),
        ),
      ],
    );
  }
}

// ─── AVATAR RING ─────────────────────────────────────────────────────────────

class _AvatarRing extends StatelessWidget {
  final UserModel player;
  const _AvatarRing({required this.player});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      height: 118,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // glow ring
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
          Positioned(
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.yellow_400,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dark_700.withAlpha(60),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text('👑', style: TextStyle(fontSize: 13)),
            ),
          ),
          // number badge (if player has shirt number)
          if (player.player?.number != null)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.yellow_400,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '#${player.player!.number}',
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark_700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── STAT CHIP ───────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final _StatItem stat;
  final Color textColor;

  const _StatChip({required this.stat, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha(28),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withAlpha(50), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          Icon(stat.icon, size: 14, color: textColor),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.value,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  height: 1.1,
                ),
              ),
              Text(
                stat.label,
                style: TextStyle(
                  color: textColor.withAlpha(170),
                  fontSize: 9,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── TIER BADGE ──────────────────────────────────────────────────────────────

class _TierBadge extends StatelessWidget {
  final String tier;
  final Color textColor;

  const _TierBadge({required this.tier, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white.withAlpha(22),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withAlpha(60), width: 0.8),
      ),
      child: Text(
        tier,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
