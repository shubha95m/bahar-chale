import 'package:flutter/material.dart';
import '../../../../app/theme/app_theme.dart';
import '../../../../core/localization/app_strings.dart';

class TermsAndConditionsDialog extends StatelessWidget {
  final bool isHindi;

  const TermsAndConditionsDialog({super.key, this.isHindi = true});

  static void show(BuildContext context, {bool isHindi = true}) {
    showDialog(
      context: context,
      builder: (ctx) => TermsAndConditionsDialog(isHindi: isHindi),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 620),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gavel_rounded, color: AppTheme.primaryGreen, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isHindi ? 'नियम, शर्तें व कानूनी सहमति' : 'Terms, Conditions & Legal Consent',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        Text(
                          isHindi ? 'भारतीय सूचना प्रौद्योगिकी अधिनियम 2000 एवं DPDP अधिनियम 2023' : 'Under IT Act 2000 & DPDP Act 2023 (India)',
                          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: isHindi ? _buildHindiTerms() : _buildEnglishTerms(),
              ),
            ),

            // Footer / Close Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    isHindi ? 'मैं समझ गया / स्वीकार करता हूँ' : 'I Understand & Agree',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHindiTerms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('1. मंच का स्वरूप (Platform Nature - Non-Commercial Carpooling)'),
        _buildBody(
          '«बाहर चलें» केवल साथी यात्रियों और चालकों को परस्पर जोड़ने वाला एक समुदाय-आधारित डिजिटल समन्वय मंच (Technology Intermediary) है। '
          'यह कोई व्यावसायिक टैक्सी, मोटर कैब एग्रीगेटर या परिवहन सेवा प्रदाता नहीं है। '
          'यह मंच मोटर वाहन अधिनियम 1988 के अंतर्गत स्वैच्छिक सह-यात्रा (Peer-to-Peer Carpooling / Cost Sharing) के उद्देश्य से बनाया गया है, '
          'जहाँ ईंधन एवं टोल खर्च का बंटवारा यात्रियों के आपसी विवेक पर निर्भर है।',
        ),
        const SizedBox(height: 14),

        _buildSectionHeader('2. चालक व वाहन दायित्व (Driver & Vehicle Compliance)'),
        _buildBody(
          'वाहन चालक प्रमाणित करता है कि उसके पास वैध ड्राइविंग लाइसेंस (Valid DL), सक्रिय वाहन पंजीकरण (RC), वैध बीमा पॉलिसी (Motor Insurance), '
          'और प्रदूषण नियंत्रण प्रमाण पत्र (PUC) उपलब्ध है। चालक सभी भारतीय यातायात नियमों (बाइक पर हेलमेट, कार में सीटबेल्ट, गति सीमा) का पूर्ण पालन करेगा '
          'और किसी भी प्रकार के नशे अथवा असावधानी से वाहन नहीं चलाएगा।',
        ),
        const SizedBox(height: 14),

        _buildSectionHeader('3. आपसी सहमति व व्यक्तिगत जोखिम (Mutual Discretion & Personal Risk)'),
        _buildBody(
          'सभी यात्री और चालक अपनी व्यक्तिगत समझ, संतुष्टि और विवेक के आधार पर यात्रा में शामिल होते हैं। '
          'मंच किसी भी सह-यात्री के व्यक्तिगत आचरण, चरित्र या पृष्ठभूमि की कोई गारंटी नहीं देता। '
          'यात्रा के दौरान अथवा यात्रा से पूर्व परस्पर समन्वय, समय और सुरक्षा की जिम्मेदारी स्वयं यात्रियों की है।',
        ),
        const SizedBox(height: 14),

        _buildSectionHeader('4. देयता की सीमा व क्षतिपूर्ति (Limitation of Liability & Disclaimer)'),
        _buildBody(
          '«बाहर चलें» मंच, इसके निर्माता अथवा संचालक किसी भी सड़क दुर्घटना, शारीरिक चोट, वाहन खराबी, समय की हानि, सामान की चोरी अथवा '
          'यात्रियों के बीच होने वाले किसी भी व्यक्तिगत अथवा वित्तीय विवाद के लिए कानूनी या आर्थिक रूप से उत्तरदायी नहीं होंगे। '
          'उपयोगकर्ता मंच को सभी कानूनी दावों से पूर्णतः मुक्त (Hold Harmless) रखने की सहमति देता है।',
        ),
        const SizedBox(height: 14),

        _buildSectionHeader('5. डेटा गोपनीयता एवं सुरक्षा (DPDP Act 2023)'),
        _buildBody(
          'आपकी व्यक्तिगत जानकारी (नाम, ईमेल, शहर, संपर्क) केवल यात्रा समन्वय, OTP प्रमाणीकरण और सुरक्षा ऑडिट हेतु सुरक्षित रखी जाती है। '
          'हम आपका डेटा किसी भी तीसरे पक्ष को विज्ञापन या व्यावसायिक लाभ हेतु नहीं बेचते।',
        ),
        const SizedBox(height: 14),

        _buildSectionHeader('6. अधिकार क्षेत्र एवं कानूनी मान्यता (Governing Law & Jurisdiction)'),
        _buildBody(
          'यह सहमति भारतीय अनुबंध अधिनियम 1872 एवं सूचना प्रौद्योगिकी अधिनियम 2000 (धारा 10A) के अंतर्गत वैध इलेक्ट्रॉनिक अनुबंध है। '
          'इस संबंध में किसी भी विवाद का निपटारा भारत के विधिक अधिकार क्षेत्र में किया जाएगा।',
        ),
      ],
    );
  }

  Widget _buildEnglishTerms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('1. Nature of Platform (Community Carpool & Intermediary)'),
        _buildBody(
          'Bahar Chale is purely an electronic intermediary and community platform facilitating voluntary, peer-to-peer carpooling '
          'and ride-sharing among verified travelers. It is NOT a taxi service, commercial motor cab aggregator, or transport agency '
          'under the Motor Vehicles Act, 1988. Rides coordinated here are purely non-commercial, voluntary cost-sharing between peers.',
        ),
        const SizedBox(height: 14),

        _buildSectionHeader('2. Driver & Vehicle Warranties'),
        _buildBody(
          'Any user offering a ride warrants and represents that they possess a valid Driving License, active Vehicle Registration Certificate (RC), '
          'mandatory Third-Party Motor Insurance, and valid Pollution Under Control (PUC) certificate. Drivers strictly agree to comply with all '
          'Indian road safety laws, speed limits, mandatory helmets/seatbelts, and zero tolerance for alcohol or hazardous driving.',
        ),
        const SizedBox(height: 14),

        _buildSectionHeader('3. Mutual Discretion & Personal Assumption of Risk'),
        _buildBody(
          'Passengers and drivers connect and travel at their own mutual discretion, choice, and risk. Bahar Chale does not guarantee '
          'individual user behavior, punctuality, or personal background. Travelers are strongly encouraged to verify identity and coordinate '
          'safely via the built-in Travel Coordination Agreement.',
        ),
        const SizedBox(height: 14),

        _buildSectionHeader('4. Limitation of Liability & Platform Indemnity'),
        _buildBody(
          'Under no circumstances shall Bahar Chale, its founders, developers, or affiliates be liable for any road accidents, personal injuries, '
          'property loss, travel delays, vehicle breakdowns, or interpersonal disputes between travelers. Users agree to indemnify and hold harmless '
          'the platform from all third-party claims arising from their journeys.',
        ),
        const SizedBox(height: 14),

        _buildSectionHeader('5. Data Protection & Privacy (DPDP Act 2023)'),
        _buildBody(
          'User data (name, email, city, verification records) is collected and processed solely for ride coordination, OTP verification, '
          'and platform safety under the Digital Personal Data Protection Act, 2023. User data is never sold or rented to third-party advertisers.',
        ),
        const SizedBox(height: 14),

        _buildSectionHeader('6. Governing Law & Electronic Contract Enforceability'),
        _buildBody(
          'This agreement constitutes a valid and binding electronic contract under Section 10A of the Information Technology Act, 2000, '
          'and the Indian Contract Act, 1872. Any disputes shall be subject to the exclusive jurisdiction of the competent courts of India.',
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
    );
  }

  Widget _buildBody(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, height: 1.45, color: Color(0xFF334155)),
      ),
    );
  }
}
