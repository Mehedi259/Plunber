// lib/core/routes/routes.dart

import 'package:go_router/go_router.dart';
import '../../presentation/screens/authentication/forget_password.dart';
import '../../presentation/screens/authentication/forget_password_otp.dart';
import '../../presentation/screens/authentication/login.dart';
import '../../presentation/screens/authentication/reset_password.dart';
import '../../presentation/screens/authentication/reset_password_success.dart';
import '../../presentation/screens/authentication/sign_up.dart';
import '../../presentation/screens/authentication/sign_up_otp.dart';
import '../../presentation/screens/authentication/otp_verification_screen.dart';
import '../../presentation/screens/splash/splash.dart';
import '../../presentation/widgets/custom_navigation/main_navigation.dart';
import '../../presentation/screens/notification/notification.dart';
import '../../presentation/screens/job/job_details.dart';
import '../../presentation/screens/job/seafty_check_required.dart';
import '../../presentation/screens/job/start_job.dart';
import '../../presentation/screens/job/problem_submit.dart';
import '../../presentation/screens/job/problem_details_screen.dart';
import '../../presentation/screens/vehicle/inspection.dart';
import '../../presentation/screens/vehicle/inspection_history.dart';
import '../../presentation/screens/profile/certifiction.dart';
import '../../presentation/screens/profile/add_cirtification.dart';
import '../../presentation/screens/profile/Report_issue.dart';
import '../../presentation/screens/profile/edit_profile.dart';
import '../../presentation/screens/support/faqs.dart';
import '../../presentation/screens/support/contact_support.dart';
import '../../presentation/screens/support/privacy_policy.dart';
import '../../presentation/screens/support/T&C.dart';
import '../../presentation/screens/profile_setup_screen/profile_setup.dart';
import '../../presentation/screens/profile_setup_screen/work_details.dart';
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
        name: RoutePath.signUpVerifyOtp,
        path: RoutePath.signUpVerifyOtp.addBasePath,
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpVerificationScreen(email: email);
        },
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

      // ================== Job ==================
      GoRoute(
        name: RoutePath.jobDetails,
        path: RoutePath.jobDetails.addBasePath,
        builder: (context, state) {
          final jobId = state.uri.queryParameters['jobId'] ?? '';
          return JobDetailsScreen(jobId: jobId);
        },
      ),
      GoRoute(
        name: RoutePath.safetyCheck,
        path: RoutePath.safetyCheck.addBasePath,
        builder: (context, state) {
          final jobId = state.uri.queryParameters['jobId'] ?? '';
          final address = state.uri.queryParameters['address'] ?? '';
          final templateId = state.uri.queryParameters['templateId'];
          return SafetyCheckRequiredScreen(
            jobId: jobId,
            address: address,
            templateId: templateId,
          );
        },
      ),
      GoRoute(
        name: RoutePath.startJob,
        path: RoutePath.startJob.addBasePath,
        builder: (context, state) {
          final jobId = state.uri.queryParameters['jobId'] ?? '';
          return StartJobScreen(jobId: jobId);
        },
      ),
      GoRoute(
        name: RoutePath.problemSubmit,
        path: RoutePath.problemSubmit.addBasePath,
        builder: (context, state) {
          final jobId = state.uri.queryParameters['jobId'] ?? '';
          return ProblemSubmitScreen(jobId: jobId);
        },
      ),
      GoRoute(
        name: RoutePath.problemDetails,
        path: RoutePath.problemDetails.addBasePath,
        builder: (context, state) {
          final jobId = state.uri.queryParameters['jobId'] ?? '';
          final jobReportId = state.uri.queryParameters['jobReportId'] ?? '';
          final reportType = state.uri.queryParameters['reportType'] ?? '';
          final reportTypeDisplay = state.uri.queryParameters['reportTypeDisplay'] ?? '';
          return ProblemDetailsScreen(
            jobId: jobId,
            jobReportId: jobReportId,
            reportType: reportType,
            reportTypeDisplay: reportTypeDisplay,
          );
        },
      ),

      // ================== Vehicle ==================
      GoRoute(
        name: RoutePath.inspection,
        path: RoutePath.inspection.addBasePath,
        builder: (context, state) {
          final vehicleId = state.uri.queryParameters['vehicleId'] ?? '';
          final vehicleName = state.uri.queryParameters['vehicleName'] ?? '';
          final vehiclePlate = state.uri.queryParameters['vehiclePlate'] ?? '';
          return InspectionScreen(
            vehicleId: vehicleId,
            vehicleName: vehicleName,
            vehiclePlate: vehiclePlate,
          );
        },
      ),
      GoRoute(
        name: RoutePath.inspectionHistory,
        path: RoutePath.inspectionHistory.addBasePath,
        builder: (context, state) {
          final vehicleId = state.uri.queryParameters['vehicleId'] ?? '';
          final vehicleName = state.uri.queryParameters['vehicleName'] ?? '';
          final vehiclePlate = state.uri.queryParameters['vehiclePlate'] ?? '';
          return InspectionHistoryScreen(
            vehicleId: vehicleId,
            vehicleName: vehicleName,
            vehiclePlate: vehiclePlate,
          );
        },
      ),

      // ================== Profile ==================
      GoRoute(
        name: RoutePath.editProfile,
        path: RoutePath.editProfile.addBasePath,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        name: RoutePath.certification,
        path: RoutePath.certification.addBasePath,
        builder: (context, state) => const CertificationScreen(),
      ),
      GoRoute(
        name: RoutePath.addCertification,
        path: RoutePath.addCertification.addBasePath,
        builder: (context, state) => const AddCertificationScreen(),
      ),
      GoRoute(
        name: RoutePath.reportIssue,
        path: RoutePath.reportIssue.addBasePath,
        builder: (context, state) => const ReportIssueScreen(),
      ),

      // ================== Support ==================
      GoRoute(
        name: RoutePath.faqs,
        path: RoutePath.faqs.addBasePath,
        builder: (context, state) => const FaqsScreen(),
      ),
      GoRoute(
        name: RoutePath.contactSupport,
        path: RoutePath.contactSupport.addBasePath,
        builder: (context, state) => const ContactSupportScreen(),
      ),
      GoRoute(
        name: RoutePath.privacyPolicy,
        path: RoutePath.privacyPolicy.addBasePath,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        name: RoutePath.termsAndConditions,
        path: RoutePath.termsAndConditions.addBasePath,
        builder: (context, state) => const TermsAndConditionsScreen(),
      ),

      // ================== Profile Setup ==================
      GoRoute(
        name: RoutePath.profileSetup,
        path: RoutePath.profileSetup.addBasePath,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        name: RoutePath.workDetails,
        path: RoutePath.workDetails.addBasePath,
        builder: (context, state) => const WorkDetailsScreen(),
      ),

    ],
    observers: [routeObserver],
  );

  static GoRouter get route => initRoute;
}

extension BasePathExtension on String {
  String get addBasePath => '/$this';
}