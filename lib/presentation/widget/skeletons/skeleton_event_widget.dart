import 'package:flutter/material.dart';
import 'package:esportly/core/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonEventWidget extends StatelessWidget {
  const SkeletonEventWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final dimensions = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.dark_500.withAlpha(120) : AppColors.grey_300.withAlpha(80);
    final highlightColor = isDark ? AppColors.dark_300.withAlpha(120) : AppColors.grey_300.withAlpha(180);

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // HERO IMAGE SKELETON
          Shimmer.fromColors(
            baseColor: AppColors.dark_500.withAlpha(150),
            highlightColor: AppColors.dark_300.withAlpha(150),
            period: const Duration(milliseconds: 1200),
            child: Container(
              width: dimensions.width,
              height: dimensions.height * 0.4,
              color: AppColors.dark_700,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // rating row
                  Container(
                    width: 60,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // title
                  Container(
                    width: dimensions.width * 0.55,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // action buttons row
                  Row(
                    children: List.generate(3, (_) => Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: AppColors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    )),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // CONTENT AREA SKELETON
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            period: const Duration(milliseconds: 1200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // info row (data, local, participantes)
                  Row(
                    spacing: 5,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(5, (_) {
                      return Container(
                        width: 70,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.dark_300 : AppColors.grey_300,
                          borderRadius: BorderRadius.circular(5),
                        )
                      );
                    }),
                  ),
                ]
              )
            )
          ),

          // CONTENT AREA SKELETON
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            period: const Duration(milliseconds: 1200),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // info row (data, local, participantes)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (_) => _infoCard(isDark)),
                  ),
                  const SizedBox(height: 24),
                  // section title
                  _bar(120, 18, isDark),
                  const SizedBox(height: 12),
                  // large card
                  _card(dimensions.width, 160, isDark),
                  const SizedBox(height: 24),
                  // section title
                  _bar(90, 18, isDark),
                  const SizedBox(height: 12),
                  // list items
                  ..._listItems(isDark, dimensions.width),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(bool isDark) => Container(
    width: 100,
    height: 70,
    decoration: BoxDecoration(
      color: isDark ? AppColors.dark_300 : AppColors.grey_300,
      borderRadius: BorderRadius.circular(12),
    ),
  );

  Widget _card(double width, double height, bool isDark) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: isDark ? AppColors.dark_300 : AppColors.grey_300,
      borderRadius: BorderRadius.circular(16),
    ),
  );

  Widget _bar(double width, double height, bool isDark) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: isDark ? AppColors.dark_300 : AppColors.grey_300,
      borderRadius: BorderRadius.circular(8),
    ),
  );

  List<Widget> _listItems(bool isDark, double width) => List.generate(3, (i) => Container(
    width: width,
    height: 56,
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: isDark ? AppColors.dark_300 : AppColors.grey_300,
      borderRadius: BorderRadius.circular(12),
    ),
  ));
}
