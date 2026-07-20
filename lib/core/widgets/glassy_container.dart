import 'dart:ui';
import 'package:flutter/material.dart';

/// En widget som skapar Apples glassy look med blur och transparens
class GlassyContainer extends StatelessWidget {
  const GlassyContainer({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.border,
    this.opacity = 0.7,
    this.blurStrength = 20.0,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final Border? border;
  final double opacity;
  final double blurStrength;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurStrength, sigmaY: blurStrength),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(opacity),
            borderRadius: borderRadius,
            border: border ?? Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 0.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
