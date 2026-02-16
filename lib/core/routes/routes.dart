// lib/core/routes/routes.dart

import 'package:go_router/go_router.dart';
import '../../presentation/screens/authentication/forget_password.dart';
import '../../presentation/screens/authentication/forget_password_otp.dart';
import '../../presentation/screens/authentication/login.dart';
import '../../presentation/screens/authentication/reset_password.dart';
import '../../presentation/screens/authentication/reset_password_success.dart';
import '../../presentation/screens/authentication/sign_up.dart';
import '../../presentation/screens/authentication/sign_up_otp.dart';
import '../../presentation/screens/splash/splash.dart';
import '../../presentation/widgets/custom_navigation/main_navigation.dart';
import '../../presentation/screens/notification/notification.dart';
import 'route_observer.dart';
import 'route_path.dart';

class AppRouter {
  static final GoRouter initRoute = GoRouter(
    initialLocation: RoutePath.splash.addBasePath,
    debugLogDiagnostics: true,
    routes: [

      // ================== OnBoarding ==================
      GoRoute(
        name: RoutePath.splash,
        path: RoutePath.splash.addBasePath,
        builder: (context, state) => const SplashScreen(),
      ),

      // ================== Authentication ==================
      GoRoute(
        name: RoutePath.login,
        path: RoutePath.login.addBasePath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: RoutePath.signup,
        path: RoutePath.signup.addBasePath,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        name: RoutePath.signUpOtp,
        path: RoutePath.signUpOtp.addBasePath,
        builder: (context, state) => const SignUpOtpScreen(),
      ),
      GoRoute(
        name: RoutePath.forgetPassword,
        path: RoutePath.forgetPassword.addBasePath,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        name: RoutePath.forgetPasswordOtp,
        path: RoutePath.forgetPasswordOtp.addBasePath,
        builder: (context, state) => const ForgetPasswordOtpScreen(),
      ),
      GoRoute(
        name: RoutePath.resetPassword,
        path: RoutePath.resetPassword.addBasePath,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        name: RoutePath.resetPasswordSuccess,
        path: RoutePath.resetPasswordSuccess.addBasePath,
        builder: (context, state) => const PasswordResetSuccessScreen(),
      ),

      // ================== Home ==================
      GoRoute(
        name: RoutePath.home,
        path: RoutePath.home.addBasePath,
        builder: (context, state) => const MainNavigation(initialIndex: 0),
      ),

      // ================== Calendar ==================
      GoRoute(
        name: RoutePath.calendar,
        path: RoutePath.calendar.addBasePath,
        builder: (context, state) => const MainNavigation(initialIndex: 1),
      ),

      // ================== Vehicle ==================
      GoRoute(
        name: RoutePath.vehicle,
        path: RoutePath.vehicle.addBasePath,
        builder: (context, state) => const MainNavigation(initialIndex: 2),
      ),

      // ================== Profile ==================
      GoRoute(
        name: RoutePath.profile,
        path: RoutePath.profile.addBasePath,
        builder: (context, state) => const MainNavigation(initialIndex: 3),
      ),

      // ================== Notification ==================
      GoRoute(
        name: RoutePath.notification,
        path: RoutePath.notification.addBasePath,
        builder: (context, state) => const NotificationScreen(),
      ),

    ],
    observers: [routeObserver],
  );

  static GoRouter get route => initRoute;
}

extension BasePathExtension on String {
  String get addBasePath => '/$this';
}