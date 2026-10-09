import 'package:flutter/material.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartPieWidget extends StatelessWidget {
  final double team1Value;
  final double drawValue;
  final double team2Value;
  final Color team1Color;
  final Color team2Color;
  final double? size;

  const ChartPieWidget({
    super.key,
    required this.team1Value,
    required this.drawValue,
    required this.team2Value,
    required this.team1Color,
    required this.team2Color,
    this.size,
  });

  Color _centerColor() {
    if (team1Value == 0 && team2Value == 0 && drawValue == 0) return AppColors.grey_300;
    if (team1Value > team2Value && team1Value >= drawValue) return team1Color;
    if (team2Value > team1Value && team2Value >= drawValue) return team2Color;
    return AppColors.grey_300;
  }

  @override
  Widget build(BuildContext context) {
    final double sz = size ?? 120;
    return SizedBox(
      width: sz,
      height: sz,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: drawValue.clamp(1, 97),
                    color: AppColors.grey_300,
                    radius: sz * 0.15,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: team1Value.clamp(1, 97),
                    color: team1Color,
                    radius: sz * 0.15,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: team2Value.clamp(1, 97),
                    color: team2Color,
                    radius: sz * 0.15,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          Icon(
            Icons.emoji_events_rounded,
            size: sz * 0.42,
            color: _centerColor(),
          ),
        ],
      ),
    );
  }
}
