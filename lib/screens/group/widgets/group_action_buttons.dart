import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_scaler.dart';

class GroupActionButtons extends StatelessWidget {
  final VoidCallback? onAddExpense;
  final VoidCallback? onSettleUp;

  const GroupActionButtons({
    super.key,
    this.onAddExpense,
    this.onSettleUp,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ------------------------------------------------------------
        // ADD EXPENSE
        // ------------------------------------------------------------
        GestureDetector(
          onTap: onAddExpense,
          child: Container(
            width: s.w(85),
            height: s.h(60),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.16),
                  blurRadius: 5,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Shiny border
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GlassBorderPainter(
                      borderRadius: 8,
                      showLeft: true,
                      showRight: false,
                    ),
                  ),
                ),

                // Main button
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(1.2),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(7),
                        bottomLeft: Radius.circular(7),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Top shine
                        Positioned(
                          top: 0,
                          left: 1,
                          right: 0,
                          height: 15,
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(7),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.fromRGBO(255, 255, 255, 0.16),
                                  Color.fromRGBO(255, 255, 255, 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Bottom depth
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(7),
                                bottomLeft: Radius.circular(7),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color.fromRGBO(0, 0, 0, 0.22),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Center(
                          child: Text(
                            'Add\nExpense',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: s.sp(17),
                              fontFamily: 'Rale way',
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ------------------------------------------------------------
        // SETTLE UP
        // ------------------------------------------------------------
        GestureDetector(
          onTap: onSettleUp,
          child: Container(
            width: s.w(85),
            height: s.h(60),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.toolbarBackground.withValues(
                    alpha: 0.65,
                  ),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Shiny border
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GlassBorderPainter(
                      borderRadius: 8,
                      showLeft: false,
                      showRight: true,
                    ),
                  ),
                ),

                // Main button
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(1.2),
                    decoration: BoxDecoration(
                      color: AppColors.toolbarBackground,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(7),
                        bottomRight: Radius.circular(7),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Top shine
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 1,
                          height: 15,
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(7),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.fromRGBO(255, 255, 255, 0.18),
                                  Color.fromRGBO(255, 255, 255, 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Bottom depth
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(7),
                                bottomRight: Radius.circular(7),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color.fromRGBO(0, 0, 0, 0.18),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Center(
                          child: Text(
                            'Settle\nUp',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: s.sp(17),
                              fontFamily: 'Rale way',
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------
// SHINY GLASS BORDER
// ----------------------------------------------------------------------

class _GlassBorderPainter extends CustomPainter {
  final double borderRadius;
  final bool showLeft;
  final bool showRight;

  _GlassBorderPainter({
    required this.borderRadius,
    required this.showLeft,
    required this.showRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // ------------------------------------------------------------
    // BLUE METALLIC GLOW
    // ------------------------------------------------------------

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        5,
      )
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(80, 190, 255, 0.75),
          Color.fromRGBO(0, 90, 255, 0.45),
          Color.fromRGBO(30, 130, 255, 0.70),
          Color.fromRGBO(0, 70, 220, 0.40),
        ],
      ).createShader(rect);

    // ------------------------------------------------------------
    // METALLIC BLUE BORDER
    // ------------------------------------------------------------

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFE6FF),
          Color(0xFFFF9FF5),
          Color(0xFFD946EF),
          Color(0xFF7E22CE),
          Color(0xFFF0ABFC),
        ],
        stops: [
          0.0,
          0.20,
          0.50,
          0.78,
          1.0,
        ],
      ).createShader(rect);

    // ------------------------------------------------------------
    // BORDER PATH
    // ------------------------------------------------------------

    final path = Path();

    if (showLeft) {
      path.moveTo(size.width, 0);

      path.lineTo(
        borderRadius,
        0,
      );

      path.quadraticBezierTo(
        0,
        0,
        0,
        borderRadius,
      );

      path.lineTo(
        0,
        size.height - borderRadius,
      );

      path.quadraticBezierTo(
        0,
        size.height,
        borderRadius,
        size.height,
      );

      path.lineTo(
        size.width,
        size.height,
      );
    }

    if (showRight) {
      path.moveTo(
        0,
        0,
      );

      path.lineTo(
        size.width - borderRadius,
        0,
      );

      path.quadraticBezierTo(
        size.width,
        0,
        size.width,
        borderRadius,
      );

      path.lineTo(
        size.width,
        size.height - borderRadius,
      );

      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width - borderRadius,
        size.height,
      );

      path.lineTo(
        0,
        size.height,
      );
    }

    // Glow underneath the metallic edge.
    canvas.drawPath(
      path,
      glowPaint,
    );

    // Sharp metallic edge.
    canvas.drawPath(
      path,
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant _GlassBorderPainter oldDelegate,
      ) {
    return false;
  }
}