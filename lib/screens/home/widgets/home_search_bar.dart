import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_scaler.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final scaler = AppScaler(context);

    return Container(
      height: scaler.h(48),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EBF7),
        borderRadius: BorderRadius.circular(scaler.h(30)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: scaler.w(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.menu_rounded,
            color: Colors.black54,
            size: scaler.sp(18),
          ),

          SizedBox(width: scaler.w(10)),

          Expanded(
            child: TextField(
              cursorColor: AppColors.accent,
              style: TextStyle(
                color: Colors.black87,
                fontSize: scaler.sp(13),
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: 'search contact or group',
                hintStyle: TextStyle(
                  color: Colors.black54,
                  fontSize: scaler.sp(13),
                ),
                filled: false,
              ),
            ),
          ),

          Icon(
            Icons.search_rounded,
            color: Colors.black54,
            size: scaler.sp(18),
          ),
        ],
      ),
    );
  }
}