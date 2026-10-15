import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/di/service_locator.dart';
import 'package:esportly/core/helpers/user_helper.dart';
import 'package:esportly/core/enum/enums.dart';
import 'package:esportly/core/helpers/player_helper.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/data/models/rating_model.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/core/providers/event/event_session_provider.dart';
import 'package:esportly/core/providers/game/game_match_provider.dart';
import 'package:esportly/core/providers/game/game_schedule_provider.dart';
import 'package:esportly/presentation/widget/badges/position_widget.dart';
import 'package:esportly/presentation/widget/images/img_circle_widget.dart';
import 'package:esportly/presentation/widget/buttons/button_dropdown_icon_widget.dart';

// ─── HELPERS DE STATUS ────────────────────────────────────────────────────────

({Color color, String label, IconData icon}) _statusMeta(PlayerStatus s) {
  return switch (s) {
    PlayerStatus.Avaliable => (color: AppColors.green_300,  label: 'Disponível', icon: Icons.check_circle_rounded),
    PlayerStatus.Doubt     => (color: AppColors.yellow_500, label: 'Dúvida',     icon: Icons.help_rounded),
    PlayerStatus.Out       => (color: AppColors.red_300,    label: 'Fora',       icon: Icons.cancel_rounded),
    _                      => (color: AppColors.grey_500,   label: 'Inativo',    icon: Icons.remove_circle_outline_rounded),
  };
}

// ─── CARD PERFORMANCE ────────────────────────────────────────────────────────

class CardPerformanceWidget extends ConsumerStatefulWidget {
  final void Function(PlayerStatus)? onStatusChanged;

  const CardPerformanceWidget({super.key, this.onStatusChanged});

  @override
  ConsumerState<CardPerformanceWidget> createState() => _CardPerformanceWidgetState();
}

class _CardPerformanceWidgetState extends ConsumerState<CardPerformanceWidget> {
  late PlayerStatus _status;

  @override
  void initState() {
    super.initState();
    final user = sl<UserModel>(instanceName: 'user');
    final event = ref.read(eventSessionProvider).event;
    _status = user.participants
        ?.where((p) => p.eventId == event?.id)
        .firstOrNull
        ?.status ?? PlayerStatus.Avaliable;
  }

  @override
  Widget build(BuildContext context) {
    final user = sl<UserModel>(instanceName: 'user');
    final event = ref.watch(eventSessionProvider.select((s) => s.event));
    final gameEvents = ref.watch(gameMatchProvider.select((s) => s.gameEvents));
    final schedule = ref.watch(gameScheduleProvider);

    if (user.player == null || event?.id == null) return const SizedBox.shrink();

    final eventId = event!.id!;
    final modality = event.modality?.name ?? '';

    final rating = UserHelper.getRating(user.player!, eventId);

    final stats = [
      (label: 'Gols',   value: '${gameEvents.where((e) => e.userId == user.id && e.type == GameEvent.Goal).length}',    icon: Icons.sports_soccer_rounded, ),
      (label: 'Assist.',value: '${gameEvents.where((e) => e.userId == user.id && e.type == GameEvent.Assist).length}',  icon: Icons.handshake_rounded,     ),
      (label: 'Partidas', value: '${[...schedule.inProgressGames, ...schedule.finishedGames.values.expand((l) => l ?? [])].where((g) => g?.teams?.any((t) => t.players.any((p) => p.id == user.id)) ?? false).length}', icon: Icons.sports_rounded, ),
      (label: 'Média',  value: (rating?.avarage ?? 0.0).toStringAsFixed(1),                                             icon: Icons.bar_chart_rounded,     ),
    ];
    final mainPos = user.player!.getMainPosition(modality);
    final statusMeta = _statusMeta(_status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 14,
          children: [
            // HEADER — avatar + identidade + status
            Row(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ImgCircularWidget(
                  size: 80,
                  image: user.photo,
                  online: true,
                  borderColor: PlayerHelper.setColorPosition(mainPos?.alias),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        UserHelper.getFullName(user),
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '@${user.userName}',
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: AppColors.grey_500,
                        ),
                      ),
                      if (mainPos != null)
                        PositionWidget(
                          position: mainPos.alias,
                          mainPosition: true,
                          width: 35,
                          height: 22,
                          textSide: 10,
                        ),
                    ],
                  ),
                ),
                ButtonDropdownIconWidget<PlayerStatus>(
                  selectedItem: _status,
                  items: PlayerStatus.values,
                  onChange: (value) {
                    if (value == null) return;
                    setState(() => _status = value);
                    widget.onStatusChanged?.call(value);
                  },
                  labelBuilder: (s) => _statusMeta(s).label,
                  iconBuilder: (s) {
                    final m = _statusMeta(s);
                    return Icon(m.icon, color: m.color, size: 13);
                  },
                  width: 130,
                  menuWidth: 150,
                  menuHeight: 220,
                  textSize: 11,
                  iconSize: 13,
                  iconAfter: false,
                  backgroundColor: Theme.of(context).cardTheme.color,
                  borderColor: statusMeta.color,
                  textColor: statusMeta.color,
                  aligment: Alignment.centerLeft,
                ),
              ],
            ),

            const Divider(),

            // ESTATÍSTICAS — geradas a partir do map reativo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: stats.map((s){
                return Column(
                  spacing: 4,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context).iconTheme.color!.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(s.icon, size: 22),
                    ),
                    Text(
                      s.value,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      s.label,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: AppColors.grey_500,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            // MERCADO — preço e variação
            _MarketRow(rating: rating),
          ],
        ),
      ),
    );
  }
}

// ─── MARKET ROW ──────────────────────────────────────────────────────────────

class _MarketRow extends StatelessWidget {
  final RatingModel? rating;

  const _MarketRow({required this.rating});

  String _formatPrice(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final price = rating?.price ?? 0.0;
    final valuation = rating?.valuation ?? 0.0;

    final isPositive = valuation > 0;
    final isNeutral = valuation == 0;
    final valuationColor = isNeutral
        ? AppColors.grey_500
        : (isPositive ? AppColors.green_300 : AppColors.red_300);
    final valuationIcon = isNeutral
        ? Icons.remove_rounded
        : (isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded);
    final valuationLabel = isNeutral
        ? '—'
        : '${isPositive ? '+' : ''}${valuation.toStringAsFixed(1)}%';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: valuationColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 6,
            children: [
              const Icon(Icons.monetization_on_rounded, size: 18, color: AppColors.yellow_500),
              Text(
                'Valor de Mercado',
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: AppColors.grey_500,
                ),
              ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              Text(
                'Fz\$ ${_formatPrice(price)}',
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: valuationColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 3,
                  children: [
                    Icon(valuationIcon, size: 13, color: valuationColor),
                    Text(
                      valuationLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: valuationColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
