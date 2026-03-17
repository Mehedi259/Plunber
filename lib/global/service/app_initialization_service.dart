import 'dart:developer';
import 'auth/auth_service.dart';
import 'auth/token_manager.dart';

class AppInitializationService {
  // Initialize app and check authentication status
  static Future<AppInitResult> initializeApp() async {
    try {
      log('Initializing app...');

      // Check if user is logged in
      final isAuthenticated = await AuthService.checkAuthStatus();
      
      if (isAuthenticated) {
        // Fetch latest user profile to get current onboarding status
        log('Fetching latest user profile...');
        final profileResult = await AuthService.fetchUserProfile();
        
        if (profileResult['success']) {
          final user = profileResult['user'];
          
          if (user != null) {
            // Check if onboarding is complete
            final onboardingComplete = user['onboarding_complete'] ?? false;
            log('User onboarding status from API: $onboardingComplete');
            
            if (onboardingComplete) {
              log('User authenticated and onboarding complete - navigating to home');
              return AppInitResult(
                isAuthenticated: true,
                shouldNavigateToHome: true,
                shouldNavigateToOnboarding: false,
                user: user,
              );
            } else {
              log('User authenticated but onboarding incomplete - navigating to profile setup');
              return AppInitResult(
                isAuthenticated: true,
                shouldNavigateToHome: false,
                shouldNavigateToOnboarding: true,
                user: user,
              );
            }
          }
        } else {
          // If profile fetch fails, use stored data
          log('Failed to fetch profile, using stored data');
          final user = AuthService.getCurrentUser();
          
          if (user != null) {
            final onboardingComplete = user['onboarding_complete'] ?? false;
            log('User onboarding status from storage: $onboardingComplete');
            
            if (onboardingComplete) {
              return AppInitResult(
                isAuthenticated: true,
                shouldNavigateToHome: true,
                shouldNavigateToOnboarding: false,
                user: user,
              );
            } else {
              return AppInitResult(
                isAuthenticated: true,
                shouldNavigateToHome: false,
                shouldNavigateToOnboarding: true,
                user: user,
              );
            }
          } else {
            log('User tokens exist but no user data found - clearing tokens');
            await TokenManager.clearTokens();
          }
        }
      }

      log('User not authenticated - navigating to login');
      return AppInitResult(
        isAuthenticated: false,
        shouldNavigateToHome: false,
        shouldNavigateToOnboarding: false,
      );
    } catch (e) {
      log('Error during app initialization: $e');
      
      // Clear potentially corrupted data
      await TokenManager.clearTokens();
      
      return AppInitResult(
        isAuthenticated: false,
        shouldNavigateToHome: false,
        shouldNavigateToOnboarding: false,
        error: e.toString(),
      );
    }
  }

  // Handle app resume (when app comes back from background)
  static Future<bool> handleAppResume() async {
    try {
      // Check if tokens are still valid
      return await AuthService.checkAuthStatus();
    } catch (e) {
      log('Error during app resume: $e');
      return false;
    }
  }
}

class AppInitResult {
  final bool isAuthenticated;
  final bool shouldNavigateToHome;
  final bool shouldNavigateToOnboarding;
  final Map<String, dynamic>? user;
  final String? error;

  AppInitResult({
    required this.isAuthenticated,
    required this.shouldNavigateToHome,
    required this.shouldNavigateToOnboarding,
    this.user,
    this.error,
  });
}