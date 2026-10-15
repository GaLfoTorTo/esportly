import 'package:flutter/material.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/presentation/widget/buttons/button_text_widget.dart';
import 'package:esportly/presentation/widget/cards/card_player_present_widget.dart';

class BottomsheetPlayerPicker extends StatelessWidget {
  final String actionLabel;
  final IconData actionIcon;
  final Color actionColor;
  final List<UserModel> players;
  final String modality;
  final String teamName;
  final Color teamColor;
  final void Function(int userId) onPlayerSelected;

  const BottomsheetPlayerPicker({
    super.key,
    required this.actionLabel,
    required this.actionIcon,
    required this.actionColor,
    required this.players,
    required this.modality,
    required this.teamName,
    required this.teamColor,
    required this.onPlayerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.dark_500
            : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabeçalho: ação + time
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              spacing: 10,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: actionColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(actionIcon, color: actionColor, size: 22),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        actionLabel,
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        teamName,
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: teamColor
                        ),
                      ),
                    ],
                  ),
                ),
                ButtonTextWidget(
                    text: "Cancelar",
                    icon: Icons.close,
                    width: 100,
                    height: 30,
                    textColor: AppColors.white,
                    backgroundColor: AppColors.red_300,
                    action: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),

          //DIVIDER
          const Divider(height: 1),

          // Lista de jogadores
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: players.length,
              itemBuilder: (ctx, i) {
                final user = players[i];
                
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onPlayerSelected(user.id!),
                    child: CardPlayerPresentWidget(
                      user: user,
                      modality: modality,
                      present: true,
                    )
                  )
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
