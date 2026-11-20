import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/widgets/language_switcher_button.dart';

class TermsPage extends ConsumerWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(stringsProvider);
    final isHindi = s.isHindi;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isHindi ? 'नियम व शर्तें (Terms & Conditions)' : 'Terms & Conditions',
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
                          color: AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.gavel_rounded, color: AppTheme.primaryGreen, size: 16),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                isHindi ? 'कानूनी समझौता • संस्करण v1.0-2026' : 'Legal Agreement • Version v1.0-2026',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        isHindi ? 'बाहर चलें सेवा की शर्तें (Terms of Service)' : 'Bahar Chale Terms of Service',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isHindi
                          ? 'अंतिम अद्यतन: 20 नवम्बर 2026 • सूचना प्रौद्योगिकी अधिनियम 2000 एवं मोटर वाहन अधिनियम 1988 के तहत'
                          : 'Last Updated: 20 November 2026 • Under Information Technology Act 2000 & Motor Vehicles Act 1988',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                      const Divider(height: 32),

                      _buildSection(
                        title: isHindi ? '1. प्लेटफॉर्म की प्रकृति एवं मध्यस्थ की स्थिति' : '1. Nature of Platform & Intermediary Status',
                        content: isHindi
                            ? 'बाहर चलें (Bahar Chale) एक गैर-व्यावसायिक, सामुदायिक कारपूलिंग और आपसी यात्रा समन्वय प्लेटफॉर्म है। यह भारतीय सूचना प्रौद्योगिकी अधिनियम, 2000 की धारा 79 के अंतर्गत एक "मध्यस्थ" (Intermediary) के रूप में कार्य करता है। यह कोई टैक्सी, कैब, किराए की गाड़ी या वाणिज्यिक परिवहन सेवा नहीं है। हम स्वयं वाहन नहीं चलाते हैं और न ही ड्राइवरों को नियोजित करते हैं।'
                            : 'Bahar Chale is a non-commercial, community-driven carpooling and mutual travel assistance platform operating as an "Intermediary" under Section 79 of the Indian Information Technology Act, 2000 and Information Technology (Intermediary Guidelines and Digital Media Ethics Code) Rules, 2021. Bahar Chale is NOT a taxi, cab, for-hire commercial transport service, or transport operator. Bahar Chale neither owns vehicles nor employs drivers.',
                      ),

                      _buildSection(
                        title: isHindi ? '2. मोटर वाहन अधिनियम 1988 एवं गैर-व्यावसायिक लागत साझेदारी' : '2. Motor Vehicles Act 1988 & Non-Commercial Cost Sharing',
                        content: isHindi
                            ? 'प्लेटफॉर्म पर यात्राएं मोटर वाहन अधिनियम, 1988 की धारा 66 के तहत गैर-व्यावसायिक साझा यात्राओं के सिद्धांतों के अनुरूप हैं। यात्रियों द्वारा दी जाने वाली कोई भी सहयोग राशि केवल वास्तविक ईंधन और टोल खर्चों की आपसी साझेदारी है, कोई वाणिज्यिक लाभ या किराया नहीं है। किसी भी प्रकार के व्यावसायिक लाभ अर्जन पर पूर्णतः प्रतिबंध है।'
                            : 'All coordinated rides comply with non-commercial ride-sharing principles under Section 66 of the Motor Vehicles Act, 1988. Any contribution shared between co-travelers is strictly limited to voluntary cost-sharing for actual fuel and toll expenses. Profit-making, commercial passenger fare collection, or commercial fleet usage is strictly prohibited.',
                      ),

                      _buildSection(
                        title: isHindi ? '3. सरकारी दस्तावेज रिकॉर्ड एवं अनिवार्य सुरक्षा द्वार (Govt Document Record Requirement)' : '3. Mandatory Government Document Record & Community Trust Gate',
                        content: isHindi
                            ? 'यात्रियों और वाहन चालकों की आपसी सुरक्षा और विश्वसनीयता के लिए, प्लेटफॉर्म पर सवारी प्रस्तुत करने (Driver Offer) अथवा सवारी अनुरोध / सीट बुक करने (Passenger Request/Booking) से पूर्व सरकारी दस्तावेज रिकॉर्ड दर्ज करना अनिवार्य है:\n'
                              '• आधार कार्ड: 12-अंकों के संख्या प्रारूप की वैधता जांची जाती है। सामने और पीछे दोनों तरफ की फोटो अपलोड की जाती है। सार्वजनिक प्रदर्शन में नंबर पूरी तरह सुरक्षित व गुप्त (XXXX XXXX 1234) रहता है।\n'
                              '• पैन कार्ड: 10-अक्षरों के मानक प्रारूप की जांच की जाती है।\n'
                              '• ड्राइविंग लाइसेंस: 10 से 16 अक्षरों के वैध भारतीय राज्य आरटीओ प्रारूप की जांच की जाती है।\n'
                              '• फोटो मिलान व हैशिंग: डुप्लिकेट पंजीकरण रोकने के लिए SHA-256 क्रिप्टोग्राफिक हैश का उपयोग किया जाता है। संवेदनशील संख्या कभी किसी अन्य सहयात्री को नहीं दिखाई जाती।\n'
                              'यदि उपयोगकर्ता साइन अप के समय इसे छोड़ते हैं (Skip), तो पहली बार सवारी प्रस्तुत करने या खोजने/बुक करने पर अनिवार्य दस्तावेज रिकॉर्ड पूरा करना आवश्यक होगा।'
                            : 'To guarantee mutual safety, physical transparency, and trusted rides, recording a valid Indian Government Document Record is a mandatory prerequisite before offering a ride (Driver) or booking/requesting seats (Passenger):\n'
                              '• Aadhaar Card: Validated for 12-digit format. Front and back photos required. Strictly masked (XXXX XXXX 1234) in all traveler views.\n'
                              '• PAN Card: Validated for 10-character standard format. Masked (ABCDE****F).\n'
                              '• Driving License (DL): Validated for 10 to 16 alphanumeric characters across Indian RTO codes. Masked (RJ09****5545).\n'
                              '• Cryptographic Security: ID numbers are hashed with one-way SHA-256 to prevent duplicate identities while guaranteeing raw ID numbers remain strictly private.\n'
                              'Users who skipped document upload at initial signup must complete this Government Document Record before creating or reserving community trips.',
                      ),

                      _buildSection(
                        title: isHindi ? '4. चालक (Driver) के दायित्व एवं कानूनी योग्यता' : '4. Driver Obligations & Legal Eligibility',
                        content: isHindi
                            ? 'सवारी की पेशकश करने वाले प्रत्येक चालक का यह कानूनी दायित्व है कि:\n'
                              '• उसके पास संबंधित वाहन श्रेणी का वैध एवं स्थायी ड्राइविंग लाइसेंस हो।\n'
                              '• वाहन का वैध पंजीकरण प्रमाण पत्र (RC), तृतीय-पक्ष या व्यापक वाहन बीमा, और वैध प्रदूषण नियंत्रण प्रमाण पत्र (PUC) हो।\n'
                              '• चालक कभी भी शराब, नशीले पदार्थों या दवाओं के प्रभाव में वाहन न चलाए।\n'
                              '• यातायात नियमों और गति सीमाओं का पूर्णतः पालन किया जाए।'
                            : 'Any member offering a ride warrants and covenants that:\n'
                              '• They hold a valid, active permanent Driving License for the appropriate vehicle class.\n'
                              '• The vehicle possesses valid Registration (RC), active Vehicle Insurance, and valid Pollution Under Control (PUC) certificate.\n'
                              '• The driver shall never operate a vehicle under the influence of alcohol, drugs, or impairing medication.\n'
                              '• All Indian road and traffic safety laws shall be strictly observed.',
                      ),

                      _buildSection(
                        title: isHindi ? '5. सहयात्री (Passenger) के दायित्व' : '5. Passenger Obligations',
                        content: isHindi
                            ? 'सवारी अनुरोध करने वाले यात्रियों का दायित्व है कि:\n'
                              '• वे निर्धारित समय पर पिकअप स्थल पर उपस्थित हों।\n'
                              '• वाहन में शांति और शालीनता बनाए रखें।\n'
                              '• किसी भी गैर-कानूनी वस्तु या प्रतिबंधित सामग्री का परिवहन न करें।\n'
                              '• चालक व अन्य सहयात्रियों के साथ सम्मानपूर्वक व्यवहार करें।'
                            : 'Passengers requesting rides undertake to:\n'
                              '• Arrive punctually at agreed pickup points.\n'
                              '• Maintain respectful decorum and vehicle cleanliness.\n'
                              '• Never carry prohibited, flammable, hazardous, or illegal contraband.\n'
                              '• Treat fellow travelers and drivers with mutual dignity and respect.',
                      ),

                      _buildSection(
                        title: isHindi ? '6. शून्य सहिष्णुता (Zero Tolerance Policy)' : '6. Zero Tolerance Policy',
                        content: isHindi
                            ? 'बाहर चलें प्लेटफॉर्म पर किसी भी प्रकार के दुर्व्यवहार, उत्पीड़न, लैंगिक अनुचित व्यवहार, जातिगत या धार्मिक भेदभाव, हिंसा या रैश ड्राइविंग के प्रति शून्य सहिष्णुता (Zero Tolerance) की नीति है। ऐसी किसी भी शिकायत पर यूजर का खाता तत्काल निलंबित किया जाएगा और आवश्यक होने पर कानून प्रवर्तन एजेंसियों को रिपोर्ट किया जाएगा।'
                            : 'Bahar Chale enforces strict zero tolerance against harassment, inappropriate conduct, gender-based discrimination, hate speech, violence, reckless driving, or extortion. Any verified violation results in immediate permanent account suspension and cooperation with Indian law enforcement authorities.',
                      ),

                      _buildSection(
                        title: isHindi ? '7. खाता समाप्ति, निलंबन एवं पुनः पंजीकरण' : '7. Account Termination, Suspension & Re-registration',
                        content: isHindi
                            ? 'उपयोगकर्ता किसी भी समय अपनी प्रोफ़ाइल में "खाता हटाएं / निष्क्रिय करें" विकल्प द्वारा अपना खाता निलंबित कर सकते हैं। खाता निलंबित होने पर आगामी सभी राइड्स रद्द कर दी जाती हैं। यदि वही उपयोगकर्ता भविष्य में उसी ईमेल से पुनः साइन अप करता है, तो उसे नए सिरे से ईमेल OTP, पासवर्ड निर्माण और पहचान सत्यापन पूरा करना होगा। सुरक्षा व ऑडिट हेतु पिछले पंजीकरण का इतिहास सुरक्षित रखा जाता है।'
                            : 'Users may suspend or remove their account at any time via the "Delete / Remove Account" setting in Profile. Upon suspension, all active rides are automatically cancelled, and the account status is updated to suspended. If a user subsequently registers again using the same email address, they must undergo full OTP email verification, password setup, and ID verification anew. Historical security logs are retained for fraud prevention.',
                      ),

                      _buildSection(
                        title: isHindi ? '8. निष्पक्ष रद्दीकरण नीति एवं रीयल-टाइम सूचना (Fair Cancellation & Real-Time Alerts)' : '8. Fair Cancellation & Real-Time Notifications Policy',
                        content: isHindi
                            ? 'सामुदायिक विश्वसनीयता बनाए रखने हेतु रद्दीकरण नियम निम्नवत हैं:\n'
                              '• असंबद्ध यात्राएं (No Linked Members): यदि किसी सवारी या यात्रा अनुरोध से कोई अन्य सहयात्री नहीं जुड़ा है, तो उपयोगकर्ता उसे बिना किसी चेतावनी या पेनल्टी स्ट्राइक के तत्काल हटा सकते हैं।\n'
                              '• संबद्ध यात्राएं (Linked Travelers): यदि सहयात्रियों ने सीट आरक्षित की है, तो रद्दीकरण पर चेतावनी दिखाई जाती है और प्लेटफॉर्म से जुड़े सभी प्रभावित सदस्यों को तत्काल रीयल-टाइम सूचना भेजी जाती है ताकि वे समय रहते वैकल्पिक यात्रा व्यवस्था कर सकें।\n'
                              '• दुरुपयोग रोकथाम: संबद्ध यात्राओं को बार-बार अंतिम समय पर रद्द करने पर विश्वसनीयता समीक्षा अथवा खाता अस्थायी रूप से निलंबित किया जा सकता है।'
                            : 'To balance convenience with mutual community reliability:\n'
                              '• Unlinked Trips: If no other co-travelers are joined or booked on a ride or travel request, the creator may delete it immediately without penalty, strike, or warning dialog.\n'
                              '• Linked Trips: If fellow travelers have confirmed seats, cancellation triggers a cautionary policy prompt and immediately dispatches real-time automated notifications to all affected co-travelers to arrange alternative transit.\n'
                              '• Abuse Prevention: Habitual short-notice cancellations of confirmed bookings with linked passengers may result in account trust review or temporary suspension.',
                      ),

                      _buildSection(
                        title: isHindi ? '9. देयता की सीमा एवं दायित्व मुक्ति (Limitation of Liability)' : '9. Limitation of Liability & Disclaimers',
                        content: isHindi
                            ? 'बाहर चलें एक निःशुल्क प्रौद्योगिकी संचार मंच है। उपयोगकर्ताओं के बीच यात्रा के दौरान होने वाली किसी भी दुर्घटना, व्यक्तिगत चोट, संपत्ति की हानि, देरी या विवाद के लिए प्लेटफॉर्म, उसके डेवलपर या संचालक कानूनी रूप से उत्तरदायी नहीं होंगे। उपयोगकर्ता अपनी स्वेच्छा और आपसी सहमति से यात्रा करते हैं।'
                            : 'Bahar Chale provides free community coordination software on an "as is" and "as available" basis. To the maximum extent permitted under applicable law, Bahar Chale, its creators, and operators shall not be liable for any direct, indirect, incidental, or consequential damages resulting from road incidents, accidents, vehicle breakdowns, delays, theft, personal injury, or user disputes. Members travel voluntarily by mutual consent.',
                      ),

                      _buildSection(
                        title: isHindi ? '10. विवाद निवारण एवं क्षेत्राधिकार' : '10. Governing Law & Dispute Resolution',
                        content: isHindi
                            ? 'ये शर्तें भारत के कानूनों द्वारा शासित होंगी। किसी भी कानूनी विवाद की स्थिति में अनन्य क्षेत्राधिकार नई दिल्ली, भारत की अदालतों का होगा।'
                            : 'These Terms of Service are governed by and construed in accordance with the laws of the Republic of India. The courts of competent jurisdiction at New Delhi, India shall have exclusive jurisdiction over all disputes arising out of or related to these Terms.',
                      ),

                      _buildSection(
                        title: isHindi ? '11. शिकायत अधिकारी (Grievance Officer)' : '11. Grievance Officer & Contact',
                        content: isHindi
                            ? 'आईटी (मध्यवर्ती दिशानिर्देश) नियम, 2021 के अनुपालन में, किसी भी शिकायत या कानूनी प्रश्न के लिए संपर्क करें:\n'
                              'ईमेल: baharchale20@gmail.com\n'
                              'शिकायत अधिकारी: लीगल व कंप्लायंस टीम, बाहर चलें'
                            : 'In compliance with Information Technology (Intermediary Guidelines) Rules, 2021, you may contact our designated Grievance Officer:\n'
                              'Email: baharchale20@gmail.com\n'
                              'Designation: Grievance & Compliance Officer, Bahar Chale',
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
