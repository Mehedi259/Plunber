class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
  
  // Auth endpoints
  static const String login = '/user/login/';
  static const String register = '/user/register/';
  static const String logout = '/user/logout/';
  
  // Onboarding endpoints
  static const String onboardingStep1 = '/user/onboarding/step1/';
  static const String onboardingStep2 = '/user/onboarding/step2/';
  
  // Job endpoints
  static const String myJobs = '/jobs/employee/my-jobs/';
  static const String calendar = '/jobs/employee/calendar/';
  
  // Fleet endpoints
  static String vehicleDetails(String vehicleId) => '/fleet/$vehicleId/';
  static String inspectionHistory(String vehicleId) => '/inspections/vehicle/$vehicleId/history/';
  static String inspectionDetails(String inspectionId) => '/inspections/$inspectionId/';
  static String submitInspection(String vehicleId) => '/inspections/vehicle/$vehicleId/submit/';
  
  // Profile endpoints
  static const String employeeProfile = '/user/me/employee-profile/';
  static const String updateProfile = '/user/me/employee-profile/update/';
  static const String certificates = '/certificates/';
  
  // Support endpoints
  static const String faqs = '/supports/faqs/';
  static const String aboutUs = '/supports/about-us/';
  static const String terms = '/supports/terms/';
  static const String privacy = '/supports/privacy/';
  static const String submitIssue = '/supports/issues/submit/';
  
  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
}
