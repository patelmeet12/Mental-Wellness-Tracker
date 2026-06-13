import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'custom_button.dart';
import 'glass_card.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final String confirmText;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelText = 'Cancel',
    this.confirmText = 'Confirm',
    this.isDestructive = false,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String content,
    String cancelText = 'Cancel',
    String confirmText = 'Confirm',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) => ConfirmationDialog(
        title: title,
        content: content,
        cancelText: cancelText,
        confirmText: confirmText,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: AppElevations.none,
      child: GlassCard(
        width: 400,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: isDestructive ? AppColors.overwhelmed : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
            ),
            AppSpacing.gapMD,
            Text(
              content,
              style: theme.textTheme.bodyMedium,
            ),
            AppSpacing.gapLG,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  text: cancelText,
                  isSecondary: true,
                  height: 38,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                AppSpacing.gapSM,
                CustomButton(
                  text: confirmText,
                  isDestructive: isDestructive,
                  height: 38,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
