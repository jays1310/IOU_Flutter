import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_scaler.dart';
import '../../widgets/app_button.dart';
import '../../widgets/logo_image.dart';
import '../../widgets/logo_title.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,

      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.screenGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double screenWidth = constraints.maxWidth;
              final double screenHeight = constraints.maxHeight;

              return Stack(
                children: [
                  // =======================================================
                  // BACKGROUND GLOW - TOP RIGHT
                  // =======================================================

                  Positioned(
                    top: -screenHeight * 0.12,
                    right: -screenWidth * 0.25,
                    child: Container(
                      width: screenWidth * 0.70,
                      height: screenWidth * 0.70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(
                              alpha: 0.16,
                            ),
                            AppColors.primary.withValues(
                              alpha: 0.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // =======================================================
                  // BACKGROUND GLOW - BOTTOM LEFT
                  // =======================================================

                  Positioned(
                    bottom: -screenHeight * 0.10,
                    left: -screenWidth * 0.30,
                    child: Container(
                      width: screenWidth * 0.75,
                      height: screenWidth * 0.75,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accent.withValues(
                              alpha: 0.12,
                            ),
                            AppColors.accent.withValues(
                              alpha: 0.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // =======================================================
                  // MAIN RESPONSIVE CONTENT
                  // =======================================================

                  Column(
                    children: [
                      // ===================================================
                      // LOGO SECTION
                      // ===================================================

                      SizedBox(
                        height: screenHeight * 0.40,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: s.w(24),
                            ),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  // -------------------------------
                                  // IOU LOGO
                                  // -------------------------------

                                  const LogoImage(),

                                  SizedBox(
                                    width: s.w(8),
                                  ),

                                  // -------------------------------
                                  // I OWE YOU
                                  // -------------------------------

                                  const LogoTitle(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ===================================================
                      // GAP AFTER LOGO
                      // ===================================================

                      SizedBox(
                        height: screenHeight * 0.035,
                      ),

                      // ===================================================
                      // LET'S GET STARTED
                      // ===================================================

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Let's Get",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.getStartedWhite(
                              s.sp(60),
                            ),
                          ),
                          Text(
                            "Started",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.getStartedPurple(
                              s.sp(60),
                            ),
                          ),
                        ],
                      ),

                      // ===================================================
                      // FLEXIBLE SPACE
                      // ===================================================

                      const Spacer(),

                      // ===================================================
                      // SIGN UP BUTTON
                      // ===================================================

                      AppButton(
                        width: s.w(190),
                        height: s.h(50),
                        text: "Sign Up",
                        onPressed: () {
                          context.push('/signup');
                        },
                      ),

                      // ===================================================
                      // BUTTON GAP
                      // ===================================================

                      SizedBox(
                        height: screenHeight * 0.027,
                      ),

                      // ===================================================
                      // LOG IN BUTTON
                      // ===================================================

                      AppButton(
                        width: s.w(191),
                        height: s.h(50),
                        text: "Log In",
                        onPressed: () {
                          context.push('/login');
                        },
                      ),

                      // ===================================================
                      // BOTTOM SPACE
                      // ===================================================

                      SizedBox(
                        height: screenHeight * 0.10,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}