class ApiConstants {
  static const String baseUrl = 'http://10.10.7.120:8888/api';
  
  // Auth endpoints
  static const String login = '/user/login/';
  static const String register = '/user/register/';
  static const String registerInitiate = '/user/register/initiate/';
  static const String registerVerify = '/user/register/verify/';
  static const String passwordResetInitiate = '/user/password-reset/initiate/';
  static const String passwordResetVerify = '/user/password-reset/verify/';
  static const String passwordResetConfirm = '/user/password-reset/confirm/';
  static const String tokenRefresh = '/token/refresh/';
  static const String logout = '/user/logout/';
  
  // Onboarding endpoints
  static const String onboardingStep1 = '/user/onboarding/step1/';
  static const String onboardingStep2 = '/user/onboarding/step2/';
  
  // Job endpoints
  static const String myJobs = '/jobs/my/';
  static const String myVehicles = '/jobs/employee/my-vehicles/';
  static const String jobsByDate = '/jobs/employee/jobs-by-date/';
  static String jobDetailsById(String uuid) => '/jobs/employee/$uuid/';
  static const String calendar = '/jobs/employee/calendar/';
  static String startJob(String jobId) => '/jobs/employee/$jobId/start/';
  static String completeJob(String jobId) => '/jobs/employee/$jobId/complete/';
  
  // Report endpoints
  static String reportFormFields(String jobReportId) => '/reports/$jobReportId/formfields/';
  static String reportForm(String jobReportId) => '/reports/$jobReportId/form/';
  static String submitReport(String jobReportId, String reportType) => '/reports/$jobReportId/submit/$reportType/';
  
  // Fleet endpoints
  static String vehicleDetails(String vehicleId) => '/fleet/$vehicleId/';
  static String inspectionHistory(String vehicleId) => '/inspections/vehicle/$vehicleId/history/';
  static String inspectionDetails(String inspectionId) => '/inspections/$inspectionId/';
  static String submitInspection(String vehicleId) => '/inspections/vehicle/$vehicleId/submit/';
  
  // Profile endpoints
  static const String employeeProfile = '/user/me/employee-profile/';
  static const String updateProfile = '/user/me/employee-profile/update/';
  static const String userMe = '/user/me/';
  static const String certificates = '/certificates/';
  
  // Support endpoints
  static const String faqs = '/supports/faqs/';
  static const String aboutUs = '/supports/about-us/';
  static const String terms = '/supports/terms/';
  static const String privacy = '/supports/privacy/';
  static const String submitIssue = '/supports/issues/submit/';
  static const String submitFeedback = '/supports/feedback/submit/';
  
  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String rememberMeKey = 'remember_me';
}
