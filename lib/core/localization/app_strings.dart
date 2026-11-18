import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_language.dart';

class AppStrings {
  final AppLanguage language;

  const AppStrings(this.language);

  bool get isHindi => language == AppLanguage.hindi;

  // --- Dynamic Localized Strings ---

  // App Identity
  String get appTitle => isHindi ? 'बाहर चलें (Bahar Chale)' : 'Bahar Chale';
  String get appTagline => isHindi ? 'सफर साथ में, आसान हर राह।' : 'Travel together, make every road easy.';

  // Navigation
  String get navHomeText => isHindi ? 'होम (Home)' : 'Home';
  String get navSearchText => isHindi ? 'सवारी खोजें (Find Rides)' : 'Find Rides';
  String get navMyTravelText => isHindi ? 'मेरी यात्राएं (My Travel)' : 'My Travel';
  String get navMessagesText => isHindi ? 'संदेश (Messages)' : 'Messages';
  String get navProfileText => isHindi ? 'प्रोफ़ाइल (Profile)' : 'Profile';
  String get notificationsText => isHindi ? 'सूचनाएं (Notifications)' : 'Notifications';

  // Primary Actions (Dual Cards)
  String get offerRideTitle => isHindi ? 'अपनी ड्राइविंग राइड शेयर करें' : 'Offer a Ride';
  String get offerRideSubtitle => isHindi ? 'गाड़ी या बाइक में खाली सीटें शेयर करें' : 'Share empty seats in your car or bike';
  String get needRideTitle => isHindi ? 'अपनी यात्रा का अनुरोध शेयर करें' : 'Need a Ride';
  String get needRideSubtitle => isHindi ? 'यात्रा विवरण पोस्ट करें, चालक आपसे जुड़ेंगे' : 'Post itinerary to get driver offers';

  String get actionWantRideText => isHindi ? 'मुझे यात्रा करनी है' : 'Find a Ride';
  String get actionGiveRideText => isHindi ? 'अपनी ड्राइविंग राइड शेयर करें' : 'Offer a Ride';
  String get actionWantRideSubtitleText =>
      isHindi ? 'यात्रा विवरण पोस्ट करें, चालक आपसे जुड़ेंगे' : 'Find co-travelers heading your way';
  String get actionGiveRideSubtitleText =>
      isHindi ? 'गाड़ी या बाइक में खाली सीटें शेयर करें' : 'Share empty seats in your car or bike';

  // Marketplace Feed Tabs
  String get availableDrivesTab => isHindi ? 'उपलब्ध ड्राइविंग राइड्स' : 'Available Rides';
  String get passengerRequestsTab => isHindi ? 'यात्रियों के अनुरोध' : 'Passenger Requests';

  // Home Screen Sections
  String get upcomingJourneysText => isHindi ? 'आपकी आगामी यात्राएं' : 'Upcoming Journeys';
  String get pendingRequestsText => isHindi ? 'प्रतीक्षारत अनुरोध' : 'Pending Requests';
  String get recentRidesText => isHindi ? 'हाल ही में जोड़ी गई सवारी' : 'Recently Added Rides';
  String get noUpcomingJourneysText => isHindi ? 'कोई आगामी यात्रा निर्धारित नहीं है।' : 'No upcoming journeys scheduled.';
  String get noPendingRequestsText => isHindi ? 'कोई नया अनुरोध लंबित नहीं है।' : 'No pending requests.';

  // Travel Tabs
  String get tabIncomingText => isHindi ? 'मिले अनुरोध (Incoming)' : 'Incoming Requests';
  String get tabMyDrivesText => isHindi ? 'मेरी राइड्स (My Drives)' : 'My Drives';
  String get tabMyRequestsText => isHindi ? 'भेजे अनुरोध (My Requests)' : 'My Requests';

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
  String get viewDetailsAndRequest => isHindi ? 'यात्री व विवरण' : 'Ride Details';

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
  String get agreementText => isHindi ? 'सहमति पत्र (समन्वय पत्र)' : 'Travel Agreement';
  String get agreementTitle => isHindi ? 'यात्रा समन्वय (Travel Agreement)' : 'Travel Agreement';
  String get certificateTitle => isHindi ? 'डिजिटल यात्रा समन्वय पत्र' : 'Digital Travel Coordination Certificate';
  String get certificateSubtitle => isHindi ? 'बाहर चलें सामुदायिक यात्रा नेटवर्क' : 'Bahar Chale Community Ride Network';
  String get certificateVerifiedBadge => isHindi ? 'प्रमाणित व पुष्टित' : 'Verified & Confirmed';
  String get certificatePendingBadge => isHindi ? 'पुष्टि प्रतीक्षित' : 'Pending Confirmation';
  String get certificateRef => isHindi ? 'प्रमाणपत्र संख्या' : 'Certificate No.';
  String get driverParty => isHindi ? 'सवारी प्रदाता (चालक)' : 'Ride Provider (Driver)';
  String get passengerParty => isHindi ? 'सहयात्री (यात्री)' : 'Co-Traveler (Passenger)';
  String get itinerarySection => isHindi ? 'निर्धारित यात्रा मार्ग व विवरण' : 'Agreed Journey Itinerary';
  String get pickupPoint => isHindi ? 'पिकअप स्थल' : 'Pickup Point';
  String get dropPoint => isHindi ? 'ड्रॉप स्थल' : 'Drop Point';
  String get travelDateTime => isHindi ? 'तारीख व समय' : 'Date & Time';
  String get contributionLabel => isHindi ? 'सहयोग राशि' : 'Contribution';
  String get freeCommunityRide => isHindi ? 'निःशुल्क सामुदायिक यात्रा' : 'Free Community Travel';
  String get mutualConfirmationTitle => isHindi ? 'पारस्परिक पुष्टि स्थिति' : 'Mutual Confirmation Status';
  String get driverConfirmedStamp => isHindi ? 'चालक द्वारा पुष्टित ✓' : 'Confirmed by Driver ✓';
  String get passengerConfirmedStamp => isHindi ? 'यात्री द्वारा पुष्टित ✓' : 'Confirmed by Passenger ✓';
  String get pendingConfirmationStamp => isHindi ? 'पुष्टि प्रतीक्षित ⏳' : 'Confirmation Pending ⏳';
  String get confirmAgreementButton => isHindi ? 'मेरी ओर से पुष्टि करें (Confirm)' : 'Confirm Travel Agreement';
  String get bothConfirmedBanner => isHindi ? 'सहमति पत्र दोनों पक्षों द्वारा पुष्टित है! ✓' : 'Agreement is fully confirmed by both parties! ✓';
  String get chatWithPartnerButton => isHindi ? 'चालक / यात्री से बातचीत करें (Chat)' : 'Chat with Driver / Passenger';
  String get viewRouteInMapsButton => isHindi ? 'Google Maps में मार्ग देखें (मुफ़्त)' : 'View Route in Google Maps (Free)';
  String get agreementEmptyState => isHindi ? 'इस अनुरोध के लिए समन्वय पत्र तैयार किया जा रहा है...' : 'Preparing travel agreement for this request...';
  String get cancelText => isHindi ? 'रद्द करें' : 'Cancel';
  String get confirmText => isHindi ? 'पुष्टि करें' : 'Confirm';
  String get saveText => isHindi ? 'सहेजें' : 'Save';
  String get logoutText => isHindi ? 'लॉग आउट' : 'Log Out';
  String get logoutConfirmText => isHindi ? 'क्या आप वाकई लॉग आउट करना चाहते हैं?' : 'Are you sure you want to log out?';
  String get interfaceLanguageText => isHindi ? 'इंटरफ़ेस भाषा' : 'Interface Language';

  // Dynamic Form Fields & Labels
  String get originCityLabel => isHindi ? 'प्रस्थान शहर (Departure City) *' : 'Departure City *';
  String get originCityHint => isHindi ? 'शहर या इलाके का नाम (उदा. Pune, Hinjawadi)' : 'City or area name (e.g. Pune, Hinjawadi)';
  String get originCityRequired => isHindi ? 'कृपया प्रस्थान शहर दर्ज करें' : 'Please enter departure city';
  String get originAreaLabel => isHindi ? 'प्रस्थान क्षेत्र / इलाका (वैकल्पिक)' : 'Pickup Area / Landmark (Optional)';
  String get originAreaHint => isHindi ? 'उदा. हिंजवड़ी, एयरपोर्ट, रेलवे स्टेशन' : 'e.g. Hinjawadi, Airport, Railway Station';

  String get destinationCityLabel => isHindi ? 'गंतव्य शहर (Destination City) *' : 'Destination City *';
  String get destinationCityHint => isHindi ? 'शहर या इलाके का नाम (उदा. Mumbai, Dadar)' : 'City or area name (e.g. Mumbai, Dadar)';
  String get destinationCityRequired => isHindi ? 'कृपया गंतव्य शहर दर्ज करें' : 'Please enter destination city';
  String get destinationAreaLabel => isHindi ? 'गंतव्य क्षेत्र / इलाका (वैकल्पिक)' : 'Drop Area / Landmark (Optional)';
  String get destinationAreaHint => isHindi ? 'उदा. दादर, वैशाली नगर, बस स्टैंड' : 'e.g. Dadar, Vaishali Nagar, Bus Stand';

  String get travelDateLabel => isHindi ? 'यात्रा की तारीख (Date) *' : 'Travel Date *';
  String get travelTimeLabel => isHindi ? 'समय (वैकल्पिक)' : 'Time (Optional)';
  String get flexibleTimeLabel => isHindi ? 'समय में लचीलापन है (Flexible Time)' : 'Timing is flexible';
  String get flexibleTimeBadge => isHindi ? 'लचीला समय' : 'Flexible Time';

  String get totalSeatsLabel => isHindi ? 'उपलब्ध सीटें (Available Seats)' : 'Available Seats';
  String get seatsRequestedLabel => isHindi ? 'आवश्यक सीटें (Seats Needed)' : 'Seats Needed';
  String get contributionAmountLabel => isHindi ? 'सहयोग राशि (₹) (वैकल्पिक)' : 'Contribution Amount (₹) (Optional)';
  String get notesLabel => isHindi ? 'अतिरिक्त विवरण या शर्तें (वैकल्पिक)' : 'Additional Notes / Preferences (Optional)';
  String get notesHint => isHindi ? 'उदा. 1 बैग की जगह है, AC चालू रहेगा' : 'e.g. Space for 1 bag, AC will be on';

  String get vehicleTypeLabel => isHindi ? 'वाहन का प्रकार (Vehicle Type):' : 'Vehicle Type:';
  String get vehicleCarLabel => isHindi ? 'कार (Car)' : 'Car';
  String get vehicleBikeLabel => isHindi ? 'बाइक (Bike)' : 'Bike';
  String get vehicleOtherLabel => isHindi ? 'अन्य / साझा (Other)' : 'Other / Shared';
  String get vehicleAnyLabel => isHindi ? 'कोई भी वाहन (Any)' : 'Any Vehicle';

  String get createRidePageTitle => isHindi ? 'सवारी प्रकाशित करें (Offer Ride)' : 'Offer a Ride';
  String get createPassengerRequestPageTitle => isHindi ? 'यात्रा की आवश्यकता पोस्ट करें' : 'Post Ride Request';
  String get publishRideButtonText => isHindi ? 'सवारी साझा करें (Offer Ride)' : 'Publish Ride Offer';
  String get publishPassengerRequestButtonText => isHindi ? 'यात्रा आवश्यकता पोस्ट करें' : 'Publish Ride Request';
  String get deleteRideButtonText => isHindi ? 'सवारी हटाएं (Delete Ride)' : 'Delete Ride';
  String get deleteRequestButtonText => isHindi ? 'अनुरोध हटाएं (Delete Request)' : 'Delete Request';

  String get locationSuggestionsTitle => isHindi ? 'स्थान सुझाव (Live Suggestions)' : 'Live Suggestions';
  String get viewInMapsTooltip => isHindi ? 'Google Maps में देखें (मुफ़्त)' : 'View in Google Maps (Free)';
  String get freeMapSuggestionsBadge => isHindi ? 'मुफ़्त नक्शा सुझाव (0 लागत)' : 'Free Map Suggestions (0 Cost)';
  String get openInMapsText => isHindi ? 'Maps पर खोलें' : 'Open in Maps';

  String seatsAvailableFormat(int available, int total, int booked) =>
      isHindi ? 'उपलब्ध: $available / $total सीटें ($booked बुक)' : 'Available: $available / $total seats ($booked booked)';
  String seatsNeededFormat(int seats) =>
      isHindi ? '$seats सीटें आवश्यक' : '$seats seats needed';

  String get rideActiveBadge => isHindi ? 'सक्रिय (Open)' : 'Active (Open)';
  String get rideFullBadge => isHindi ? 'सीटें भर चुकी हैं (Full)' : 'Full (Closed)';
  String get requestStatusOpen => isHindi ? 'सक्रिय (Open)' : 'Active (Open)';
  String get requestStatusMatched => isHindi ? 'सवारी मिली (Matched)' : 'Matched';
  String get riderDetailsButton => isHindi ? 'यात्री व विवरण' : 'Ride Details';
  String get sendRequestButton => isHindi ? 'सवारी का अनुरोध करें' : 'Request Ride';
  String get seatsFullButton => isHindi ? 'सीटें भर चुकी हैं (Full)' : 'Seats Full';

  // Authentication
  String get signInTab => isHindi ? 'साइन इन (Sign In)' : 'Sign In';
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

  // Form Fields & Labels (Fallback)
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
}

final stringsProvider = Provider<AppStrings>((ref) {
  final lang = ref.watch(appLanguageProvider);
  return AppStrings(lang);
});
