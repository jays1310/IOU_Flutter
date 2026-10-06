import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_scaler.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.screenGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // =====================================================
              // TOP RIGHT PURPLE GLOW
              // =====================================================

              Positioned(
                top: -s.h(120),
                right: -s.w(130),
                child: Container(
                  width: s.w(280),
                  height: s.w(280),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.16),
                        AppColors.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // =====================================================
              // BOTTOM LEFT PURPLE GLOW
              // =====================================================

              Positioned(
                bottom: -s.h(120),
                left: -s.w(150),
                child: Container(
                  width: s.w(300),
                  height: s.w(300),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.12),
                        AppColors.accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // =====================================================
              // CONTENT
              // =====================================================

              Column(
                children: [
                  // ===================================================
                  // HEADER
                  // ===================================================

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: s.w(18),
                      vertical: s.h(10),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: s.w(42),
                            height: s.w(42),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: 0.06,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: s.sp(18),
                            ),
                          ),
                        ),
                        SizedBox(width: s.w(14)),
                        Expanded(
                          child: Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Raleway',
                              fontSize: s.sp(22),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===================================================
                  // TERMS CONTENT
                  // ===================================================

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        s.w(20),
                        s.h(12),
                        s.w(20),
                        s.h(30),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          _buildIntro(s),

                          SizedBox(height: s.h(22)),

                          _buildSection(
                            s,
                            number: '1',
                            title: 'Acceptance of Terms',
                            content:
                            'By creating an account or using IOU, '
                                'you agree to these Terms & Conditions. '
                                'If you do not agree with these terms, '
                                'please do not use the application.',
                          ),

                          _buildSection(
                            s,
                            number: '2',
                            title: 'About IOU',
                            content:
                            'IOU is an expense-splitting application '
                                'designed to help users record shared '
                                'expenses, divide costs between people, '
                                'and keep track of amounts owed between '
                                'users.',
                          ),

                          _buildSection(
                            s,
                            number: '3',
                            title: 'Your Account',
                            content:
                            'You are responsible for providing '
                                'accurate information when creating your '
                                'account and for keeping your account '
                                'credentials secure. You should not '
                                'share your password or verification '
                                'information with others.',
                          ),

                          _buildSection(
                            s,
                            number: '4',
                            title: 'Expense Information',
                            content:
                            'You are responsible for the accuracy '
                                'of the expenses, amounts, participants, '
                                'and other information that you enter '
                                'into IOU. IOU only records and calculates '
                                'the information provided by its users.',
                          ),

                          _buildSection(
                            s,
                            number: '5',
                            title: 'Payments and Settlements',
                            content:
                            'IOU helps users track amounts owed and '
                                'settlements between users. IOU does not '
                                'process, hold, transfer, or guarantee '
                                'any monetary payment between users. '
                                'Users are responsible for completing '
                                'their own payments and resolving any '
                                'payment disputes.',
                          ),

                          _buildSection(
                            s,
                            number: '6',
                            title: 'Acceptable Use',
                            content:
                            'You agree to use IOU only for lawful '
                                'purposes. You must not use the '
                                'application to mislead, impersonate, '
                                'defraud, harass, or harm another person.',
                          ),

                          _buildSection(
                            s,
                            number: '7',
                            title: 'Privacy',
                            content:
                            'Information provided while using IOU '
                                'may be stored and processed to provide '
                                'the application features. Users should '
                                'avoid entering sensitive information '
                                'that is not necessary for managing '
                                'shared expenses.',
                          ),

                          _buildSection(
                            s,
                            number: '8',
                            title: 'Accuracy of Calculations',
                            content:
                            'IOU provides expense calculations based '
                                'on the information entered by users. '
                                'Users should review calculated amounts '
                                'before relying on them for a settlement '
                                'or payment.',
                          ),

                          _buildSection(
                            s,
                            number: '9',
                            title: 'Availability of the App',
                            content:
                            'IOU may occasionally be unavailable '
                                'because of maintenance, technical '
                                'problems, network issues, or other '
                                'circumstances. We do not guarantee '
                                'that the application will always be '
                                'available or error-free.',
                          ),

                          _buildSection(
                            s,
                            number: '10',
                            title: 'Changes to These Terms',
                            content:
                            'These Terms & Conditions may be updated '
                                'when necessary. Continued use of IOU '
                                'after changes are made means that you '
                                'accept the updated terms.',
                          ),

                          _buildSection(
                            s,
                            number: '11',
                            title: 'Contact',
                            content:
                            'If you have questions, concerns, or '
                                'feedback regarding these Terms & '
                                'Conditions or the IOU application, '
                                'please contact the application '
                                'administrator.',
                          ),

                          SizedBox(height: s.h(18)),

                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(s.w(14)),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius:
                              BorderRadius.circular(s.w(12)),
                              border: Border.all(
                                color:
                                AppColors.primary.withValues(
                                  alpha: 0.20,
                                ),
                              ),
                            ),
                            child: Text(
                              'Last updated: October 2026',
                              style: TextStyle(
                                color: Colors.white.withValues(
                                  alpha: 0.55,
                                ),
                                fontFamily: 'Raleway',
                                fontSize: s.sp(11),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntro(AppScaler s) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(s.w(16)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(s.w(14)),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: s.w(38),
                height: s.w(38),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accent,
                      AppColors.primary,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: Colors.white,
                  size: s.sp(19),
                ),
              ),
              SizedBox(width: s.w(11)),
              Expanded(
                child: Text(
                  'Welcome to IOU',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Raleway',
                    fontSize: s.sp(18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: s.h(12)),
          Text(
            'These Terms & Conditions explain the basic rules '
                'for using IOU and its expense-sharing features. '
                'Please read them before using the application.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontFamily: 'Raleway',
              fontSize: s.sp(12.5),
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      AppScaler s, {
        required String number,
        required String title,
        required String content,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: s.h(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: s.w(28),
                height: s.w(28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(
                    alpha: 0.12,
                  ),
                  border: Border.all(
                    color: AppColors.primary.withValues(
                      alpha: 0.30,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: TextStyle(
                      color: AppColors.accent,
                      fontFamily: 'Raleway',
                      fontSize: s.sp(11),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: s.w(10)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Raleway',
                    fontSize: s.sp(15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: s.h(8)),
          Padding(
            padding: EdgeInsets.only(
              left: s.w(38),
            ),
            child: Text(
              content,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62),
                fontFamily: 'Raleway',
                fontSize: s.sp(12.5),
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}