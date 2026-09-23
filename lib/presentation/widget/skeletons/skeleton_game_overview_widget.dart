import 'package:flutter/material.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonGameOverviewWidget extends StatelessWidget {
  const SkeletonGameOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final dimensions = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.dark_500.withAlpha(120) : AppColors.grey_300.withAlpha(80);
    final highlightColor = isDark ? AppColors.dark_300.withAlpha(120) : AppColors.grey_300.withAlpha(180);

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        period: const Duration(milliseconds: 1200),
        child: Container(
          width: dimensions.width,
          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            color: isDark ? AppColors.dark_500 : AppColors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // título "Detalhes da Partida"
              _bar(160, 16, isDark),
              const SizedBox(height: 15),

              // quadra 3D
              Container(
                width: dimensions.width,
                height: 150,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.dark_300 : AppColors.grey_300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 15),

              // grid de infos da partida (4 itens em wrap)
              Wrap(
                spacing: 10,
                runSpacing: 14,
                children: List.generate(4, (_) {
                  return SizedBox(
                    width: dimensions.width * 0.4,
                    child: Row(
                      spacing: 10,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.dark_300 : AppColors.grey_300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6,
                          children: [
                            _bar(60, 11, isDark),
                            _bar(80, 14, isDark),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 15),

              const Divider(),
              const SizedBox(height: 10),

              // seção "Quem Vencerá?"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _bar(180, 15, isDark),
                  _bar(80, 12, isDark),
                ],
              ),
              const SizedBox(height: 14),

              // botões de voto (3 opções)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (_) => Column(
                  spacing: 10,
                  children: [
                    _bar(80, 13, isDark),
                    Container(
                      width: 90,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.dark_300 : AppColors.grey_300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    _bar(70, 12, isDark),
                  ],
                )),
              ),
              const SizedBox(height: 20),

              // seção "Quem será o MVP?"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _bar(140, 15, isDark),
                  _bar(80, 12, isDark),
                ],
              ),
              const SizedBox(height: 14),

              // cards de jogadores MVP (3 itens)
              Row(
                spacing: 12,
                children: List.generate(3, (_) => Column(
                  spacing: 8,
                  children: [
                    Container(
                      width: 70,
                      height: 90,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.dark_300 : AppColors.grey_300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    _bar(60, 12, isDark),
                  ],
                )),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(double width, double height, bool isDark) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: isDark ? AppColors.dark_300 : AppColors.grey_300,
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
