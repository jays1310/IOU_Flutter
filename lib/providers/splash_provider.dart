import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart';

class SplashProvider extends ChangeNotifier {
  Future<void> startSplash(BuildContext context) async {
    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!context.mounted) return;

    final authProvider = context.read<AuthProvider>();

    try {
      await authProvider.restoreSession();

      if (!context.mounted) return;

      if (authProvider.isLoggedIn) {
        context.go('/home');
        return;
      }
    } catch (_) {
      // Stored token is invalid or expired.
      // Continue to Get Started.
    }

    if (!context.mounted) return;

    context.go('/get-started');
  }
}