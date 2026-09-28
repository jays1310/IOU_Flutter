import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_scaler.dart';
import '../../widgets/logo_image.dart';
import '../../widgets/logo_title.dart';
import '../../widgets/app_button.dart';
import 'package:go_router/go_router.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [

            /// Logo Image
            Positioned(
              left: s.w(40),
              top: s.h(69),
              child: const LogoImage(),
            ),

            /// I Owe You
            Positioned(
              right: s.w(73),
              top: s.h(77),
              child: const LogoTitle(),
            ),

            /// Let's Get
            Positioned(
              left: s.w(80),
              top: s.h(270),
              child: Text(
                "Let's Get",
                style: AppTextStyles.getStartedWhite(s.sp(60)),
              ),
            ),

            /// Started
            Positioned(
              left: s.w(95),
              top: s.h(330),
              child: Text(
                "Started",
                style: AppTextStyles.getStartedPurple(s.sp(60)),
              ),
            ),

            /// Sign Up
            Positioned(
              bottom: s.h(248),
              left: (MediaQuery.of(context).size.width - s.w(190)) / 2,
              child: AppButton(
                width: s.w(190),
                height: s.h(50),
                text: "Sign Up",
                onPressed: () {
                  context.push('/signup');
                },
              ),
            ),

            /// Log In
            Positioned(
              bottom: s.h(156),
              left: (MediaQuery.of(context).size.width - s.w(191)) / 2,
              child: AppButton(
                width: s.w(191),
                height: s.h(50),
                text: "Log In",
                onPressed: () {
                  context.push('/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}