import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../global/service/auth/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedDay;
  String? _selectedMonth;
  String? _selectedYear;
  bool _acceptTerms = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _birthDate {
    if (_selectedYear != null && _selectedMonth != null && _selectedDay != null) {
      return '$_selectedYear-${_selectedMonth!.padLeft(2, '0')}-${_selectedDay!.padLeft(2, '0')}';
    }
    return '';
  }

  bool get _isFormValid {
    return _emailController.text.isNotEmpty &&
           _usernameController.text.isNotEmpty &&
           _passwordController.text.isNotEmpty &&
           _selectedDay != null &&
           _selectedMonth != null &&
           _selectedYear != null &&
           _acceptTerms;
  }

  Future<void> _createAccount() async {
    if (!_isFormValid) {
      setState(() {
        _errorMessage = 'Please fill all fields and accept terms';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.initiateRegistration(
      email: _emailController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      birthDate: _birthDate,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      // Navigate to OTP verification screen
      if (mounted) {
        context.goNamed(
          'signup-verify-otp',
          queryParameters: {'email': _emailController.text.trim()},
        );
      }
    } else {
      setState(() {
        _errorMessage = result['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.h),
                  
                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/app_banner.png',
                      width: 174.w,
                      height: 93.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  
                  SizedBox(height: 9.h),
                  
                  // Title
                  Text(
                    'Create your Free Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontSize: 18.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Email Field
                  _buildInputField(
                    label: 'Email',
                    controller: _emailController,
                    hintText: 'name@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // Username Field
                  _buildInputField(
                    label: 'Username',
                    controller: _usernameController,
                    hintText: 'Bonnie Green',
                  ),
                  
                  SizedBox(height: 20.h),
                  
                  // Password Field
                  _buildPasswordField(),
                  
                  SizedBox(height: 20.h),
                  
                  // Birth Date
                  Text(
                    'Birth Date',
                    style: TextStyle(
                      color: const Color(0xFF0F172A),
                      fontSize: 16.sp,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  SizedBox(height: 10.h),
                  
                  // Day Dropdown
                  _buildDropdown(
                    value: _selectedDay,
                    hint: 'Day',
                    items: List.generate(31, (index) => (index + 1).toString()),
                    onChanged: (value) => setState(() => _selectedDay = value),
                  ),
                  
                  SizedBox(height: 10.h),
                  
                  // Month Dropdown
                  _buildDropdown(
                    value: _selectedMonth,
                    hint: 'Month',
                    items: List.generate(12, (index) => (index + 1).toString()),
                    onChanged: (value) => setState(() => _selectedMonth = value),
                  ),
                  
                  SizedBox(height: 10.h),
                  
                  // Year Dropdown
                  _buildDropdown(
                    value: _selectedYear,
                    hint: 'Year',
                    items: List.generate(100, (index) => (2024 - index).toString()),
                    onChanged: (value) => setState(() => _selectedYear = value),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Terms and Conditions
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: Checkbox(
                          value: _acceptTerms,
                          onChanged: (value) {
                            setState(() {
                              _acceptTerms = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          side: BorderSide(
                            width: 0.5,
                            color: const Color(0xFFD1D5DB),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 0.h),
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'I accept the ',
                                style: TextStyle(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 12.sp,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Terms and Conditions',
                                  style: TextStyle(
                                    color: const Color(0xFF1C64F2),
                                    fontSize: 12.sp,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Error Message
                  if (_errorMessage != null)
                    Container(
                      margin: EdgeInsets.only(bottom: 16.h),
                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: const Color(0xFFDC2626),
                          fontSize: 14.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  // Create Account Button
                  _buildCreateAccountButton(),
                  
                  SizedBox(height: 16.h),
                  
                  // Already have account
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        context.pop();
                      },
                      child: Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: const Color(0xFF1C64F2),
                          fontSize: 14.sp,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF222222),
            fontSize: 16.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: ShapeDecoration(
            color: const Color(0xFFF9FAFB),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: const Color(0xFFD1D5DB),
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              color: const Color(0xFF0F172A),
              fontSize: 14.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: const Color(0xFF6B7280),
                fontSize: 14.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontSize: 16.sp,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: ShapeDecoration(
            color: const Color(0xFFF9FAFB),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: const Color(0xFFD1D5DB),
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            style: TextStyle(
              color: const Color(0xFF0F172A),
              fontSize: 14.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: '••••••••••',
              hintStyle: TextStyle(
                color: const Color(0xFF6B7280),
                fontSize: 14.sp,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: const Color(0xFF6B7280),
                  size: 20.sp,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: ShapeDecoration(
        color: const Color(0xFFF9FAFB),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: const Color(0xFFD1D5DB),
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(
              color: const Color(0xFF6B7280),
              fontSize: 14.sp,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: const Color(0xFF6B7280),
            size: 20.sp,
          ),
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontSize: 14.sp,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCreateAccountButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (_isFormValid && !_isLoading) ? _createAccount : null,
          borderRadius: BorderRadius.circular(8.r),
          child: Ink(
            decoration: BoxDecoration(
              color: (_isFormValid && !_isLoading)
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Container(
              height: 48.h,
              alignment: Alignment.center,
              child: _isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Create account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
