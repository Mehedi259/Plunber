import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import '../service/app_initialization_service.dart';

class SplashController extends GetxController {
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Add a minimum splash duration for better UX
    await Future.delayed(const Duration(seconds: 2));

    final result = await AppInitializationService.initializeApp();

    isLoading.value = false;

    // Get the current context from the navigator
    final context = Get.context;
    if (context != null && context.mounted) {
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
}