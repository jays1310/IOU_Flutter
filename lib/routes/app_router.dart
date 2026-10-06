import 'package:go_router/go_router.dart';
import 'package:iou_flutter/screens/auth/signup_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/get_started_screen.dart';
import '../screens/auth/login_screen.dart';
import '../models/user_model.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/group/select_members_screen.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/get-started',
        builder: (context, state) => const GetStartedScreen(),
      ),

      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;

          final user = data['user'] as UserModel;
          final verificationId = data['verificationId'] as String;

          return OtpVerificationScreen(
            user: user,
            verificationId: verificationId,
          );
        },
      ),

      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),

      GoRoute(
        path: '/select-members',
        builder: (context, state) {
          final screen = state.extra as SelectMembersScreen;
          return screen;
        },
      ),
    ],
  );
}