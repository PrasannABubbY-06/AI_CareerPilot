import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final LinearGradient? gradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.opacity = 0.05,
    this.borderRadius,
    this.border,
    this.padding = const EdgeInsets.all(16),
    this.width,
    this.height,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final defaultRadius = BorderRadius.circular(24);
    final finalRadius = borderRadius ?? defaultRadius;

    return ClipRRect(
      borderRadius: finalRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: finalRadius,
            border: border ?? Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.0,
            ),
            gradient: gradient,
          ),
          child: child,
        ),
      ),
    );
  }
}
