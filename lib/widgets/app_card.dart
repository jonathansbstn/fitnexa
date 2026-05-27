import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_colors_ext.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final VoidCallback? onTap;
  final double radius;
  final Border? border;
  final Gradient? gradient;
  final List<BoxShadow>? shadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.onTap,
    this.radius = 18,
    this.border,
    this.gradient,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: gradient == null ? (color ?? context.appCard) : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius),
          border: border ?? Border.all(color: context.appDivider),
          boxShadow: shadow,
        ),
        child: child,
      ),
    );
  }
}
