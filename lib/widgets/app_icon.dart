import 'package:flutter/material.dart';

class AppIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final EdgeInsets padding;
  final BoxFit fit;
  final Color? color;

  const AppIcon(
      this.assetPath, {
        super.key,
        this.size = 24,
        this.padding = const EdgeInsets.all(14),
        this.fit = BoxFit.contain,
        this.color,
      });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          assetPath,
          fit: fit,
          color: color,
        ),
      ),
    );
  }
}