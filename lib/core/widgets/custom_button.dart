import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final double? width;
  final double height;
  final bool isDestructive;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.width,
    this.height = 48.0,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    if (isSecondary) {
      bg = Colors.transparent;
      fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
      border = BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 1.0,
      );
    } else if (isDestructive) {
      bg = AppColors.overwhelmed;
      fg = Colors.white;
    } else {
      bg = AppColors.primary;
      fg = Colors.white;
    }

    final isButtonEnabled = onPressed != null && !isLoading;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: isButtonEnabled ? bg : (bg == Colors.transparent ? Colors.transparent : bg.withOpacity(0.4)),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderMD,
          side: border,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isButtonEnabled ? onPressed : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            alignment: Alignment.center,
            decoration: !isSecondary && !isDestructive && isButtonEnabled
                ? BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: AppRadius.borderMD,
                  )
                : null,
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isSecondary
                          ? (isDark ? AppColors.primary : AppColors.primary)
                          : Colors.white,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: fg, size: 18),
                        AppSpacing.gapXS,
                      ],
                      Text(
                        text,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
