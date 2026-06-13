import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final double blur;
  final Color? fillColor;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.blur = 16.0,
    this.fillColor,
    this.borderColor,
    this.shadows,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fallbackFill = fillColor ?? 
        (isDarkMode 
            ? AppColors.darkSurface.withOpacity(0.4) 
            : AppColors.lightSurface.withOpacity(0.6));
            
    final fallbackBorder = borderColor ?? 
        (isDarkMode 
            ? AppColors.darkBorder.withOpacity(0.5) 
            : AppColors.lightBorder.withOpacity(0.7));

    final actualBorderRadius = borderRadius ?? AppRadius.borderMD;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: actualBorderRadius,
        boxShadow: shadows ?? AppColors.getGlassShadow(isDarkMode),
      ),
      child: ClipRRect(
        borderRadius: actualBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: gradient == null ? fallbackFill : null,
              gradient: gradient,
              borderRadius: actualBorderRadius,
              border: Border.all(
                color: fallbackBorder,
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
