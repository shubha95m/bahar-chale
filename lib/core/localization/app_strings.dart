import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_language.dart';

class AppStrings {
  final AppLanguage language;

  const AppStrings(this.language);

  bool get isHindi => language == AppLanguage.hindi;

  // --- Dynamic Localized Strings ---

  // App Identity
  String get appTitle => isHindi ? 'बाहर चलें' : 'Bahar Chale';
  String get appTagline => isHindi ? 'सफर साथ में, आसान हर राह।' : 'Travel together, make every road easy.';

  // Navigation
  String get navHomeText => isHindi ? 'होम' : 'Home';
  String get navSearchText => isHindi ? 'सवारी खोजें' : 'Find Rides';
  String get navMyTravelText => isHindi ? 'मेरी यात्राएं' : 'My Travel';
  String get navMessagesText => isHindi ? 'संदेश' : 'Messages';
  String get navProfileText => isHindi ? 'प्रोफ़ाइल' : 'Profile';

  // Primary Actions
  String get actionWantRideText => isHindi ? 'मुझे यात्रा करनी है' : 'Find a Ride';
  String get actionGiveRideText => isHindi ? 'मैं साथ ले जा सकता हूँ' : 'Offer a Ride';
  String get actionWantRideSubtitleText =>
      isHindi ? 'अपने गंतव्य के लिए साथी खोजें' : 'Find co-travelers heading your way';
  String get actionGiveRideSubtitleText =>
      isHindi ? 'अपनी गाड़ी में सीटें साझा करें' : 'Share empty seats in your car or bike';

  // Home Screen Sections
  String get upcomingJourneysText => isHindi ? 'आपकी आगामी यात्राएं' : 'Upcoming Journeys';
  String get pendingRequestsText => isHindi ? 'प्रतीक्षारत अनुरोध' : 'Pending Requests';
  String get recentRidesText => isHindi ? 'हाल ही में जोड़ी गई सवारी' : 'Recently Added Rides';
  String get noUpcomingJourneysText => isHindi ? 'कोई आगामी यात्रा निर्धारित नहीं है।' : 'No upcoming journeys scheduled.';
  String get noPendingRequestsText => isHindi ? 'कोई नया अनुरोध लंबित नहीं है।' : 'No pending requests.';

  // Travel Tabs
  String get tabIncomingText => isHindi ? 'मिले अनुरोध' : 'Incoming Requests';
  String get tabMyDrivesText => isHindi ? 'मेरी राइड्स' : 'My Drives';
  String get tabMyRequestsText => isHindi ? 'भेजे अनुरोध' : 'My Requests';

  // Search & Browse
  String get searchPageTitle => isHindi ? 'सवारियां खोजें व साझा करें' : 'Find & Share Rides';
  String get searchPageSubtitle => isHindi ? 'उपलब्ध सभी यात्राओं की खुली सूची' : 'Open feed of all available journeys';
  String get searchBarHint => isHindi ? 'शहर, स्थान या मार्ग खोजें (उदा. Pune, Mumbai...)' : 'Search city, area or route (e.g. Pune, Mumbai...)';
  String get allVehiclesText => isHindi ? 'सभी वाहन' : 'All Vehicles';
  String get carText => isHindi ? 'कार (Car)' : 'Car';
  String get bikeText => isHindi ? 'बाइक (Bike)' : 'Bike';
  String get clearFilterText => isHindi ? 'साफ़ करें' : 'Clear';
  String get noRidesFoundTitle => isHindi ? 'कोई सवारी उपलब्ध नहीं है' : 'No rides available';
  String get noRidesFoundSubtitle => isHindi
      ? 'आपके चुने गए स्थान या तारीख के लिए अभी कोई सक्रिय राइड नहीं मिली।'
      : 'No active rides found matching your location or date.';
  String get googleMapsDirectionsText => isHindi ? 'Google Maps (मुफ़्त)' : 'Google Maps (Free)';
  String get viewDetailsAndRequest => isHindi ? 'विवरण व अनुरोध' : 'Details & Request';

  // Messages & Conversations
  String get conversationsTitle => isHindi ? 'संदेश और बातचीत' : 'Messages & Chat';
  String get conversationsSubtitle => isHindi ? 'सवारी समन्वय व सहयात्रियों से संवाद' : 'Travel coordination & chat';
  String get noConversationsTitle => isHindi ? 'अभी कोई सक्रिय बातचीत नहीं है' : 'No active conversations yet';
  String get noConversationsSubtitle => isHindi
      ? 'जब आप किसी यात्रा के लिए अनुरोध करेंगे या कोई आपकी सवारी में शामिल होना चाहेगा, तो यहाँ सीधे संवाद शुरू हो जाएगा।'
      : 'When you request a ride or someone requests to join yours, your chat will appear here.';

  // Buttons & Common Actions
  String get acceptText => isHindi ? 'स्वीकार करें' : 'Accept';
  String get rejectText => isHindi ? 'मना करें' : 'Reject';
  String get chatText => isHindi ? 'बातचीत (Chat)' : 'Chat';
  String get agreementText => isHindi ? 'सहमति पत्र' : 'Agreement';
  String get cancelText => isHindi ? 'रद्द करें' : 'Cancel';
  String get confirmText => isHindi ? 'पुष्टि करें' : 'Confirm';
  String get saveText => isHindi ? 'सहेजें' : 'Save';
  String get logoutText => isHindi ? 'लॉग आउट' : 'Log Out';
  String get logoutConfirmText => isHindi ? 'क्या आप वाकई लॉग आउट करना चाहते हैं?' : 'Are you sure you want to log out?';
  String get interfaceLanguageText => isHindi ? 'इंटरफ़ेस भाषा' : 'Interface Language';

  // Authentication
  String get signInTab => isHindi ? 'साइन इन (लॉगिन)' : 'Sign In';
  String get signUpTab => isHindi ? 'नया खाता (OTP)' : 'Sign Up (OTP)';
  String get fullNameLabel => isHindi ? 'आपका पूरा नाम *' : 'Full Name *';
  String get emailLabel => isHindi ? 'असली ईमेल पता (Gmail / Other) *' : 'Real Email Address *';
  String get passwordLabel => isHindi ? 'पासवर्ड *' : 'Password *';
  String get sendOtpButton => isHindi ? 'ईमेल पर OTP भेजें' : 'Send OTP to Email';
  String get verifyOtpButton => isHindi ? 'OTP सत्यापित करें' : 'Verify OTP';
  String get quickTestHeader => isHindi ? 'या त्वरित परीक्षण (Quick Test)' : 'Or Quick Test';
  String get driverRole => isHindi ? 'चालक (Driver)' : 'Driver';
  String get riderRole => isHindi ? 'यात्री (Rider)' : 'Rider';
  String get googleSignInButton => isHindi ? 'Google से साइन इन करें' : 'Sign in with Google';

  // ------------------------------------------------------------------------
  // Static Backwards-Compatibility Constants
  // ------------------------------------------------------------------------
  static const String appName = 'Bahar Chale';
  static const String appNameHindi = 'बाहर चलें';
  static const String tagline = 'सफर साथ में, आसान हर राह।';

  // Navigation
  static const String navHome = 'होम';
  static const String navMyTravel = 'मेरी यात्राएं';
  static const String navProfile = 'प्रोफ़ाइल';

  // Primary Actions
  static const String actionWantRide = 'मुझे यात्रा करनी है';
  static const String actionGiveRide = 'मैं साथ ले जा सकता हूँ';
  static const String actionWantRideSubtitle = 'अपने गंतव्य के लिए साथी खोजें';
  static const String actionGiveRideSubtitle = 'अपनी गाड़ी में सीटें साझा करें';

  // Home Screen Sections
  static const String upcomingJourneys = 'आपकी आगामी यात्राएं';
  static const String pendingRequests = 'प्रतीक्षारत अनुरोध';
  static const String recentRides = 'हाल ही में जोड़ी गई सवारी';
  static const String noUpcomingJourneys = 'कोई आगामी यात्रा निर्धारित नहीं है।';
  static const String noPendingRequests = 'कोई नया अनुरोध लंबित नहीं है।';

  // Authentication
  static const String loginTitle = 'बाहर चलें में आपका स्वागत है';
  static const String loginSubtitle = 'सुरक्षित और आसान सामुदायिक यात्रा समन्वय';
  static const String signInWithGoogle = 'Google से साइन इन करें';
  static const String loggingIn = 'साइन इन हो रहा है...';
  static const String logout = 'लॉग आउट';
  static const String logoutConfirm = 'क्या आप वाकई लॉग आउट करना चाहते हैं?';

  // Form Fields & Labels
  static const String originCity = 'प्रस्थान शहर';
  static const String originArea = 'प्रस्थान क्षेत्र / इलाका (वैकल्पिक)';
  static const String destinationCity = 'गंतव्य शहर';
  static const String destinationArea = 'गंतव्य क्षेत्र / इलाका (वैकल्पिक)';
  static const String travelDate = 'यात्रा की तारीख';
  static const String travelTime = 'पसंदीदा समय (वैकल्पिक)';
  static const String flexibleTime = 'समय में लचीलापन है';
  static const String totalSeats = 'उपलब्ध सीटें';
  static const String contributionAmount = 'सहयोग राशि (₹) (वैकल्पिक)';
  static const String notes = 'अतिरिक्त विवरण या शर्तें';
  static const String vehicleType = 'वाहन का प्रकार';
  static const String vehicleCar = 'कार (Car)';
  static const String vehicleBike = 'बाइक (Bike)';
  static const String vehicleOther = 'अन्य (Other)';

  // Common UI
  static const String cancel = 'रद्द करें';
  static const String confirm = 'पुष्टि करें';
  static const String save = 'सहेजें';
  static const String search = 'खोजें';
  static const String sendRequest = 'अनुरोध भेजें';
  static const String accept = 'स्वीकार करें';
  static const String reject = 'अस्वीकार करें';
  static const String details = 'विवरण';
  static const String openMap = 'Google Maps में देखें';
  static const String chat = 'बातचीत (Chat)';
  static const String agreement = 'यात्रा समन्वय';

  // Statuses
  static const String statusOpen = 'उपलब्ध';
  static const String statusFull = 'सीटें भर चुकी हैं';
  static const String statusPending = 'लंबित';
  static const String statusAccepted = 'स्वीकृत';
  static const String statusRejected = 'अस्वीकृत';
  static const String statusConfirmed = 'पुष्टित';
  static const String statusCompleted = 'पूर्ण';
  static const String statusCancelled = 'रद्द';

  // Error Messages
  static const String errorNetwork = 'इंटरनेट कनेक्शन उपलब्ध नहीं है। कृपया अपना नेटवर्क जांचें।';
  static const String errorGeneric = 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।';
  static const String errorAuthFailed = 'साइन इन करने में असमर्थ। कृपया पुनः प्रयास करें।';
  static const String errorSeatsExhausted = 'माफ़ कीजिए, इस यात्रा में सीटें समाप्त हो चुकी हैं।';
}

final stringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(appLanguageProvider);
  return AppStrings(lang);
});
