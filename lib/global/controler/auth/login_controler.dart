import 'package:get/get.dart';
import '../../service/auth/auth_service.dart';

class LoginController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Email and password are required';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await AuthService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      isLoading.value = false;

      if (result['success']) {
        return true;
      } else {
        errorMessage.value = result['message'];
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
  }

  Future<bool> checkAuthStatus() async {
    return await AuthService.checkAuthStatus();
  }

  Map<String, dynamic>? getCurrentUser() {
    return AuthService.getCurrentUser();
  }
}
