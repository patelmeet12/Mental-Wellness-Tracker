import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_card.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final int score;
  final Color color;
  final IconData icon;

  const MetricCard({
    super.key,
    required this.title,
    required this.score,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GlassCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          AppSpacing.gapLG,
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 8,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  Text(
                    '%',
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.gapLG,
          Text(
            score >= 75
                ? 'Healthy Level'
                : score >= 45
                    ? 'Moderate Level'
                    : 'Needs Attention',
            style: textTheme.bodyMedium?.copyWith(
              color: score >= 75
                  ? AppColors.excellent
                  : score >= 45
                      ? AppColors.stressed
                      : AppColors.overwhelmed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
