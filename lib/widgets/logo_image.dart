import 'package:flutter/material.dart';

import '../core/constants/app_assets.dart';

class LogoImage extends StatelessWidget {
  const LogoImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.logoNoBackground,
      width: 193,
      height: 133,
      fit: BoxFit.contain,
    );
  }
}