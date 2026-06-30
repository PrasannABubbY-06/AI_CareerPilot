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
    
    // Disable BackdropFilter on Android to prevent Impeller GPU shader compilation errors
    // related to texture LOD bias (e.g., texture(..., -0.475)) on Mali/Adreno GPUs.
    final bool isAndroid = Theme.of(context).platform == TargetPlatform.android;

    final container = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isAndroid ? (opacity * 1.5).clamp(0.0, 1.0) : opacity),
        borderRadius: finalRadius,
        border: border ?? Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1.0,
        ),
        gradient: gradient,
      ),
      child: child,
    );

    if (isAndroid) {
      return ClipRRect(
        borderRadius: finalRadius,
        child: container,
      );
    }

    return ClipRRect(
      borderRadius: finalRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: container,
      ),
    );
  }
}
