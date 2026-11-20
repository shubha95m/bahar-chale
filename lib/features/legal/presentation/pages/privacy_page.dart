import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/language_switcher_button.dart';

class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final isHindi = s.isHindi;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isHindi ? 'गोपनीयता नीति (Privacy Policy)' : 'Privacy Policy',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: const [
          LanguageSwitcherButton(),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.security_rounded, color: Colors.blue.shade700, size: 16),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                isHindi
                                    ? 'डिजिटल व्यक्तिगत डेटा संरक्षण अधिनियम 2023 (DPDP Act)'
                                    : 'Digital Personal Data Protection Act 2023 Compliant',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        isHindi ? 'बाहर चलें गोपनीयता नीति (Privacy Policy)' : 'Bahar Chale Privacy Policy',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isHindi
                          ? 'अंतिम अद्यतन: 20 नवम्बर 2026 • डेटा संरक्षण एवं उपयोगकर्ता सुरक्षा मानक'
                          : 'Last Updated: 20 November 2026 • Data Protection & Trust Framework',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                      const Divider(height: 32),

                      _buildSection(
                        title: isHindi ? '1. हमारा सिद्धांत: डेटा का सम्मान एवं गोपनीयता' : '1. Philosophy: Privacy by Design & Zero Monetization',
                        content: isHindi
                            ? 'बाहर चलें (Bahar Chale) आपकी गोपनीयता का सम्मान करता है। हम गैर-व्यावसायिक समुदाय हैं। हम आपके व्यक्तिगत डेटा को कभी भी किसी विज्ञापनदाता या तीसरे पक्ष को नहीं बेचते हैं और न ही विपणन (मार्केटिंग) उद्देश्यों के लिए साझा करते हैं।'
                            : 'Bahar Chale is dedicated to privacy by design. We operate as a mutual community initiative. We NEVER sell, license, rent, monetize, or trade your personal data with third-party advertising networks, data brokers, or marketing companies.',
                      ),

                      _buildSection(
                        title: isHindi ? '2. एकत्र किया जाने वाला डेटा' : '2. Personal Data We Collect',
                        content: isHindi
                            ? 'प्लेटफॉर्म के सुरक्षित संचालन हेतु हम केवल आवश्यक डेटा एकत्र करते हैं:\n'
                              '• खाता विवरण: आपका पूरा नाम, वैध व्यक्तिगत ईमेल पता, पासवर्ड (अपरिवर्तनीय हैश के रूप में सुरक्षित), एवं गृह नगर।\n'
                              '• प्रोफ़ाइल फोटो: सहयात्रियों के बीच वास्तविक पहचान सुनिश्चित करने के लिए स्पष्ट सेल्फी या पोर्ट्रेट तस्वीर।\n'
                              '• सरकारी पहचान पत्र: आधार कार्ड (सामने और पीछे), पैन कार्ड या ड्राइविंग लाइसेंस।\n'
                              '• यात्रा विवरण: प्रस्थान शहर, गंतव्य, तारीख, समय, सीट उपलब्धता या आवश्यकता, और वाहन का प्रकार।\n'
                              '• तकनीकी लॉग: सहमति का समय, IP पता एवं ऐप संस्करण (कानूनी अनुपालन हेतु)।'
                            : 'We collect only strictly necessary data to facilitate safe rides:\n'
                              '• Account Details: Full name, verified genuine email address, securely hashed password, and preferred home city.\n'
                              '• Profile Picture: A clear portrait or selfie photo to verify physical traveler authenticity.\n'
                              '• Government ID Documents: Aadhaar Card (front & back), PAN Card (front), or Driving License (front).\n'
                              '• Travel Information: Departure city, destination, travel dates, times, vehicle category, and seat count.\n'
                              '• Regulatory Audit Logs: Timestamp of consent, IP address, and platform version for CERT-In / DPDP Act compliance.',
                      ),

                      _buildSection(
                        title: isHindi ? '3. सरकारी दस्तावेज रिकॉर्ड और डेटा सुरक्षा (Govt Document Record & Security)' : '3. Government Document Record & Data Security',
                        content: isHindi
                            ? 'सरकारी दस्तावेज रिकॉर्ड प्रणाली कैसे कार्य करती है:\n'
                              '• आधार: 12-अंकों के संख्या प्रारूप की वैधता जांची जाती है। सामने और पीछे दोनों तरफ की फोटो सुरक्षित संग्रहीत की जाती है।\n'
                              '• पैन एवं DL: आयकर विभाग एवं राज्य आरटीओ 10 से 16 अक्षरों के प्रारूप मानकों की जांच की जाती है।\n'
                              '• एन्क्रिप्शन एवं मास्किंग: पहचान पत्र की संख्या को अन्य यात्रियों से पूरी तरह छिपाया (Mask) जाता है (उदा. XXXX XXXX 1234, ABCDE****F, RJ09****5545)। कच्चा नंबर डेटाबेस से अन्य उपयोगकर्ताओं को कभी नहीं दिखाया जाता।\n'
                              '• हैश तकनीक: डुप्लिकेट और फर्जी खातों को रोकने के लिए आईडी नंबर का SHA-256 वन-वे क्रिप्टोग्राफिक हैश संग्रहीत किया जाता है।\n'
                              '• आरएलएस (Row Level Security): डेटाबेस स्तर पर सुरक्षित नीतियां (RLS Policies) सुनिश्चित करती हैं कि केवल अधिकृत सिस्टम ही डेटा तक पहुंच सके।'
                            : 'How our Government Document Record protects users:\n'
                              '• Aadhaar Integrity: Checked for 12-digit format validity. Both front and back photos securely retained in protected storage.\n'
                              '• PAN & DL Structure: Evaluated against Indian Income Tax and State RTO standards (10 to 16 alphanumeric characters).\n'
                              '• Full Masking: All UI views display only masked IDs (e.g., "XXXX XXXX 1234", "ABCDE****F", "RJ09****5545"). Raw government ID numbers are never displayed in the open community interface.\n'
                              '• Cryptographic Hashing: We compute one-way SHA-256 cryptographic hashes of ID numbers to prevent duplicate registrations without storing plaintext identifiers.\n'
                              '• Row Level Security (RLS): Supabase enterprise Postgres RLS policies ensure document storage is strictly isolated and inaccessible to unauthorized actors.',
                      ),

                      _buildSection(
                        title: isHindi ? '4. डेटा उपयोग का उद्देश्य एवं रीयल-टाइम सूचनाएं' : '4. Purpose of Data Processing & Real-Time Alerts',
                        content: isHindi
                            ? 'आपके डेटा का उपयोग केवल निम्नलिखित आवश्यक उद्देश्यों के लिए किया जाता है:\n'
                              '• सहयात्रियों और चालकों के बीच सुरक्षित यात्रा समन्वय स्थापित करना।\n'
                              '• फर्जी, रोबोटिक या असामाजिक प्रोफाइल से समुदाय की रक्षा करना।\n'
                              '• सत्यापित सरकारी दस्तावेज रिकॉर्ड स्थिति (✓ Govt Document Record) प्रदर्शित कर विश्वास का निर्माण करना।\n'
                              '• रीयल-टाइम यात्रा सूचनाएं: यात्रा रद्दीकरण, सीट पुष्टि अथवा महत्वपूर्ण यात्रा परिवर्तनों की त्वरित सूचना वेब और डिवाइस पर भेजना (बिना किसी विपणन या विज्ञापन ट्रैकिंग के)।'
                            : 'Your information is processed strictly for legitimate interests under DPDP Act 2023:\n'
                              '• Facilitating mutual communication and travel coordination between verified members.\n'
                              '• Preventing impersonation, fraudulent accounts, or automated bot usage.\n'
                              '• Displaying trust indicators ("✓ Govt Document Record") to help travelers make informed choices.\n'
                              '• Real-time Trip Notifications: Instant push/web notification delivery for trip cancellations, seat confirmations, and route alerts without any third-party ad tracking or telemetry abuse.',
                      ),

                      _buildSection(
                        title: isHindi ? '5. डेटा साझाकरण की सीमाएं' : '5. Data Disclosure & Third Parties',
                        content: isHindi
                            ? 'हम आपका डेटा केवल उसी सहयात्री को दिखाते हैं जिसके साथ आपकी सवारी का समन्वय हुआ है (केवल नाम, फोटो और मास्क्ड आईडी)। हम किसी भी परिस्थिति में डेटा तीसरे पक्षों को नहीं देते, केवल सक्षम भारतीय अदालत या कानून प्रवर्तन एजेंसी के वैध नोटिस के तहत कानूनी बाध्यता होने पर ही सहयोग किया जाता है।'
                            : 'Data is shared only with co-travelers directly matched with your trip (displaying name, avatar, vehicle type, and masked ID badge). We do not disclose data to any outside party, except when strictly required by a valid judicial warrant or legal order from authorized Indian law enforcement authorities under applicable law.',
                      ),

                      _buildSection(
                        title: isHindi ? '6. खाता निष्कासन एवं डेटा प्रतिधारण (Retention & Account Removal)' : '6. Account Removal & Data Retention',
                        content: isHindi
                            ? 'उपयोगकर्ता अपनी प्रोफ़ाइल से कभी भी "खाता हटाएं" का चयन कर सकते हैं:\n'
                              '• खाता तत्काल निष्क्रिय (is_active = false) कर दिया जाता है और सक्रिय राइड्स रद्द हो जाती हैं।\n'
                              '• भारतीय कंप्यूटर आपातकालीन प्रतिक्रिया टीम (CERT-In) और साइबर सुरक्षा निर्देशों के तहत, धोखाधड़ी की रोकथाम और सुरक्षा ऑडिट हेतु आवश्यक लॉग्स विधिक अवधि तक सुरक्षित रखे जाते हैं।\n'
                              '• यदि आप उसी ईमेल से भविष्य में पुनः साइन अप करते हैं, तो नए सिरे से ओटीपी और पहचान सत्यापन की प्रक्रिया से गुजरना होगा।'
                            : 'Users may remove or deactivate their account at any time via Profile Settings:\n'
                              '• The account is immediately marked inactive (is_active = false, account_status = suspended) and active rides are cancelled.\n'
                              '• Pursuant to Indian CERT-In cybersecurity directions and legal retention requirements, security audit logs are preserved for fraud prevention and regulatory accountability.\n'
                              '• If an individual re-registers with the same email in the future, a fresh onboarding cycle (OTP, password, and ID verification) is conducted.',
                      ),

                      _buildSection(
                        title: isHindi ? '7. आपके अधिकार (User Rights under DPDP Act 2023)' : '7. User Rights under Digital Personal Data Protection Act 2023',
                        content: isHindi
                            ? 'डीपीडीपी अधिनियम, 2023 के तहत आपको अपने व्यक्तिगत डेटा के संबंध में सूचना प्राप्त करने, त्रुटियों को सुधारने, सहमति वापस लेने और शिकायत दर्ज करने का पूर्ण अधिकार है।'
                            : 'Under the Digital Personal Data Protection Act 2023, data principals enjoy the right to access summaries of personal data processed, request correction or updating of inaccurate data, withdraw consent, and seek grievance redressal.',
                      ),

                      _buildSection(
                        title: isHindi ? '8. शिकायत अधिकारी एवं संपर्क' : '8. Grievance Redressal Officer',
                        content: isHindi
                            ? 'डेटा सुरक्षा संबंधी किसी भी प्रश्न, अनुरोध या शिकायत हेतु हमारे शिकायत अधिकारी से संपर्क करें:\n'
                              'ईमेल: baharchale20@gmail.com\n'
                              'विषय: Data Privacy Inquiry - Bahar Chale'
                            : 'For inquiries, data access requests, or grievance redressal under DPDP Act 2023, please contact:\n'
                              'Email: baharchale20@gmail.com\n'
                              'Subject: Data Privacy Inquiry - Bahar Chale',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.55),
          ),
        ],
      ),
    );
  }
}
