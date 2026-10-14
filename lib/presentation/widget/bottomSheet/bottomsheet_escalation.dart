import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/core/providers/game/game_config_provider.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';
import 'package:esportly/presentation/widget/others/lineup_widget.dart';

class BottomSheetEscalation extends ConsumerStatefulWidget {
  final bool team;
  const BottomSheetEscalation({super.key, required this.team});

  @override
  ConsumerState<BottomSheetEscalation> createState() => _BottomSheetEscalationState();
}

class _BottomSheetEscalationState extends ConsumerState<BottomSheetEscalation> {
  bool activeTeam = true;

  void alterTeamView() {
    setState(() { activeTeam = !activeTeam; });
  }

  @override
  Widget build(BuildContext context) {
    var dimensions = MediaQuery.of(context).size;
    final category = ref.watch(gameConfigProvider.select((s) => s.config?.category ?? ''));

    return Container(
      height: dimensions.height * 0.75,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).dialogTheme.backgroundColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ButtonTextWidget(
                width: dimensions.width * 0.42,
                height: 25,
                backgroundColor: activeTeam ? AppColors.green_300 : AppColors.green_100.withAlpha(100),
                text: "Time A",
                textSize: 12,
                textColor: AppColors.blue_500,
                iconSize: 20,
                action: () => alterTeamView(),
              ),
              ButtonTextWidget(
                width: dimensions.width * 0.42,
                height: 25,
                backgroundColor: !activeTeam ? AppColors.green_300 : AppColors.green_100.withAlpha(100),
                text: "Time B",
                textSize: 12,
                textColor: AppColors.blue_500,
                iconSize: 20,
                action: () => alterTeamView(),
              ),
            ],
          ),
          const Divider(color: AppColors.grey_300),
          LineupWidget(category: category),
        ],
      ),
    );
  }
}
