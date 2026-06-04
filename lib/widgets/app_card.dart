import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors_ext.dart';
import 'bouncing_widget.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final VoidCallback? onTap;
  final double radius;
  final Border? border;
  final Gradient? gradient;
  final List<BoxShadow>? shadow;
  final Color? glowColor;
  final double blur;

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
    this.glowColor,
    this.blur = 0,
  });

  @override
  Widget build(BuildContext context) {
    List<BoxShadow>? finalShadow = shadow;
    if (glowColor != null) {
      finalShadow = [
        BoxShadow(
          color: glowColor!.withValues(alpha: 0.3),
          blurRadius: 20,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        )
      ];
    }

    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: blur > 0 
            ? (color ?? context.appCard).withValues(alpha: 0.7) 
            : (gradient == null ? (color ?? context.appCard) : null),
        gradient: blur > 0 ? null : gradient,
        borderRadius: BorderRadius.circular(radius),
        border: border ?? Border.all(
          color: blur > 0 ? Colors.white.withValues(alpha: 0.1) : context.appDivider,
        ),
        boxShadow: blur > 0 ? null : finalShadow,
      ),
      child: child,
    );

    if (blur > 0) {
      content = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: finalShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: content,
          ),
        ),
      );
    }

    if (onTap != null) {
      return BouncingWidget(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
