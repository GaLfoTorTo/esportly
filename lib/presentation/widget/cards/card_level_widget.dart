import 'package:flutter/material.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:esportly/data/models/user_model.dart';
import 'package:esportly/core/helpers/modality_helper.dart';
import 'package:esportly/presentation/widget/charts/chart_level_widget.dart';

class CardLevelWidget extends StatelessWidget {
  final UserModel  user;

  const CardLevelWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    //RESGATAR DIMENSÕES DO DISPOSITIVO
    var dimensions = MediaQuery.of(context).size;

    //RESGATAR TEMA PERSONALIZADO PARA MODALIDADE PRINCIPAL DO USUARIO
    final modalityInfo = ModalityHelper.getEventModalityColor(user.config?.mainModality?.name ?? 'Football');
    final modalityColor = modalityInfo['color'];
    final modalityTextColor = modalityInfo['textColor'];
    final modalityImage = modalityInfo['image'];
    //CONTABILIZAR PROGRESSO DE NIVEL
    double progress = (user.level!.points * 100) / user.level!.pointsMax;

    return Card(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: modalityColor,
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: AssetImage(modalityImage) as ImageProvider,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              modalityColor.withAlpha(200), 
              BlendMode.hardLight,
            )
          ),
        ),
        child: Column(
          children: [
            Row(
              spacing: 20,
              children: [
                SizedBox(
                  width: dimensions.width * 0.25,
                  height: 150,
                  child: ChartLevel(
                    value: progress,
                    color: modalityTextColor,
                    level: user.level!.number
                  ),
                ),
                Expanded(
                  child: Column(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 50.0),
                        child: Text(
                          'Nível Atual',
                          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: modalityTextColor
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 50.0),
                        child: Text(
                          user.level!.tier,
                          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                            color: modalityTextColor
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'XP progresso',
                            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                              color: modalityTextColor
                            ),
                          ),
                          Text(
                            '${progress.toInt()}%',
                            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                              color: modalityTextColor
                            ),
                          ),
                        ],
                      ),
                      LinearProgressIndicator(
                        color: modalityTextColor,
                        backgroundColor: AppColors.white.withAlpha(50),
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 10,
                        value: progress / 100,
                      ),
                      Text(
                        '${user.level!.points}/${user.level!.pointsMax}',
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          color: modalityTextColor
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}