import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iou_flutter/screens/auth/signup_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/get_started_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/otp_verification_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/get-started',
        builder: (context, state) => const GetStartedScreen(),
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          final screen = state.extra as OtpVerificationScreen;
          return screen;
        },
      ),

      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}