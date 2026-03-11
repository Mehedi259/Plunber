import 'package:get/get.dart';
import '../../service/auth/login_service.dart';

class LoginController extends GetxController {
  final LoginService _loginService = LoginService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Email and password are required';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _loginService.login(
        email: email,
        password: password,
      );

      if (response.success) {
        isLoading.value = false;
        return true;
      } else {
        errorMessage.value = response.message;
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      isLoading.value = false;
      return false;
    }
  }

  Future<void> logout() async {
    await _loginService.logout();
  }

  bool isLoggedIn() {
    return _loginService.isLoggedIn();
  }

  UserData? getCurrentUser() {
    return _loginService.getCurrentUser();
  }
}
