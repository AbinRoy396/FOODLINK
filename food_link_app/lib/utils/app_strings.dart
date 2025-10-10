class AppStrings {
  // App Info
  static const String appName = 'FoodLink';
  static const String appTagline = 'Connecting Food Donors with Those in Need';

  // User Roles
  static const String roleDonor = 'Donor';
  static const String roleNGO = 'NGO';
  static const String roleReceiver = 'Receiver';

  // Routes
  static const String routeHome = '/';
  static const String routeLogin = '/login';
  static const String routeRoleSelection = '/role-selection';
  static const String routeRegisterDonor = '/donor-registration';
  static const String routeRegisterNGO = '/ngo-registration';
  static const String routeRegisterReceiver = '/receiver-registration';
  static const String routeDonorDashboard = '/donor-dashboard';
  static const String routeNGODashboard = '/ngo-dashboard';
  static const String routeReceiverDashboard = '/receiver-dashboard';
  static const String routeCreateDonation = '/create-donation';
  static const String routeViewDonations = '/view-donations';
  static const String routeCreateRequest = '/create-request';
  static const String routeTrackRequestStatus = '/track-request-status';
  static const String routeDonorProfile = '/donor-profile';
  static const String routeNGOProfile = '/ngo-profile';
  static const String routeReceiverProfile = '/receiver-profile';
  static const String routeChatList = '/chat-list';
  static const String routeChat = '/chat';
  static const String routeDonationDetails = '/donation-details';
  static const String routeRequestDetails = '/request-details';

  // Common Strings
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String share = 'Share';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String refresh = 'Refresh';
  static const String loading = 'Loading...';
  static const String noData = 'No data available';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String warning = 'Warning';
  static const String info = 'Info';

  // Donation Status
  static const String statusPending = 'Pending';
  static const String statusVerified = 'Verified';
  static const String statusAllocated = 'Allocated';
  static const String statusDelivered = 'Delivered';
  static const String statusExpired = 'Expired';

  // Time periods for sorting
  static const String sortDateNewest = 'dateNewest';
  static const String sortDateOldest = 'dateOldest';
  static const String sortQuantityHighest = 'quantityHighest';
  static const String sortQuantityLowest = 'quantityLowest';
  static const String sortStatus = 'status';
}
