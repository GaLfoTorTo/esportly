import 'package:flutter/material.dart';
import 'package:esportly/core/theme/app_colors.dart';

class StatsGameWidget extends StatelessWidget {
  final String title;
  final int teamAValue;
  final int teamBValue;
  final bool isPercentage;

  const StatsGameWidget({
    super.key,
    required this.title,
    required this.teamAValue,
    required this.teamBValue,
    this.isPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    //RESGATAR DIMENSÕES DO DISPOSITIVO
    var dimensions = MediaQuery.of(context).size;
    String teamAVal = "$teamAValue${isPercentage ? '%' : ''}";
    String teamBVal = "$teamBValue${isPercentage ? '%' : ''}";
    return Column(
      spacing: 10,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                teamAVal,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.blue_300,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: AppColors.grey_500
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                teamBVal,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: AppColors.red_300,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
        if(!isPercentage)...[
          Row(
            spacing: 2,
            children: [
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.blue_300.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  constraints: BoxConstraints(
                    maxWidth: (dimensions.width / 2) - 21
                  ),
                  child: FractionallySizedBox(
                    widthFactor: (teamAValue / 20).clamp(0, 1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.blue_300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.red_300.withAlpha(10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerLeft,
                  constraints: BoxConstraints(
                    maxWidth: (dimensions.width / 2) - 21
                  ),
                  child: FractionallySizedBox(
                    widthFactor: (teamBValue / 20).clamp(0, 1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.red_300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              )
            ]
          )
        ]else...[
          Row(
            spacing: 2,
            children: [
              Container(
                height: 10,
                width: (( dimensions.width * teamAValue ) / 100 ) - 21,
                decoration: const BoxDecoration(
                  color: AppColors.blue_300,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), topLeft: Radius.circular(12)),
                ),
                alignment: Alignment.centerLeft,
              ),
              Container(
                height: 10,
                width: (( dimensions.width * teamBValue ) / 100 ) - 21,
                decoration: const BoxDecoration(
                  color: AppColors.red_300,
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                alignment: Alignment.centerLeft,
              )
            ]
          )
        ]
      ],
    );
  }
}