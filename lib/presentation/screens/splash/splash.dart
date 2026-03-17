import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../global/service/app_initialization_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Add a minimum splash duration for better UX
    await Future.delayed(const Duration(seconds: 2));

    final result = await AppInitializationService.initializeApp();

    if (mounted) {
      // Navigate based on initialization result
      if (result.isAuthenticated) {
        if (result.shouldNavigateToHome) {
          context.goNamed('home');
        } else if (result.shouldNavigateToOnboarding) {
          context.goNamed('profile-setup');
        }
      } else {
        context.goNamed('login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/app_banner.png',
              width: 200,
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Color(0xFF2563EB),
            ),
          ],
        ),
      ),
    );
  }
}
