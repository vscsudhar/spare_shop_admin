/// VoltSpare Centralized Legal Content & Statutory Policies
///
/// Compliant with:
/// - Consumer Protection Act, 2019
/// - Consumer Protection (E-Commerce) Rules, 2020
/// - Information Technology Act, 2000 & applicable rules
/// - Digital Personal Data Protection Act, 2023 (DPDPA)

class LegalConfig {
  static const String appName = 'VoltSpare';
  static const String appTagline = 'Automotive Spares & EV Components Management';
  static const String legalEntityName = 'VoltSpare Automotive Technologies Pvt. Ltd.';
  static const String effectiveDate = 'October 1, 2026';
  static const String lastUpdatedDate = 'October 1, 2026';
  static const String supportEmail = 'support@voltspare.com';
  static const String supportPhone = '+91 99000 88000';
  static const String grievanceEmail = 'grievance@voltspare.com';
  static const String privacyEmail = 'privacy@voltspare.com';
  static const String grievanceOfficerName = 'VoltSpare Grievance Redressal Officer';
  static const String grievanceAddress = 'VoltSpare Operations & Redressal Cell, India';
  static const String governingLaw = 'The laws of the Republic of India';
  static const String jurisdiction =
      'Competent courts in India having jurisdiction, subject to applicable consumer protection laws and mandatory statutory forums';
}

class LegalSection {
  final String id;
  final String title;
  final String summary;
  final List<String> bulletPoints;
  final String? detailedText;

  const LegalSection({
    required this.id,
    required this.title,
    required this.summary,
    required this.bulletPoints,
    this.detailedText,
  });
}

class VoltSpareTermsAndConditions {
  static const String title = 'Terms & Conditions';
  static const String preamble =
      'Welcome to VoltSpare. These Terms and Conditions ("Terms") govern your access to and use of the VoltSpare mobile application, web administrative portals, and related digital services (collectively, the "Platform"). By accessing, registering an account, or placing an order on VoltSpare, you agree to be bound by these Terms.';

  static const List<LegalSection> sections = [
    LegalSection(
      id: 'tc_1',
      title: '1. About VoltSpare',
      summary: 'Platform for EV and petrol two-wheeler spare parts.',
      bulletPoints: [
        'VoltSpare is an online e-commerce platform that enables customers to browse, discover, and purchase spare parts, components, accessories, and maintenance products for electric vehicles (EV) and petrol two-wheelers.',
        'We connect vehicle owners, mechanics, fleet operators, and automotive enthusiasts with relevant vehicle parts through our digital catalog and fulfillment network.',
        'VoltSpare endeavors to provide accurate product listings and reliable fulfillment services in accordance with these Terms.',
      ],
      detailedText:
          'VoltSpare operates as a specialized online two-wheeler spare parts platform. While we partner with authorized suppliers and quality manufacturers, product specifications, warranties, and performance standards are governed by the respective manufacturer policies and product-level details provided on the Platform.',
    ),
    LegalSection(
      id: 'tc_2',
      title: '2. Account Registration & Security',
      summary: 'User account requirements, information accuracy, and credentials.',
      bulletPoints: [
        'To access certain features, save vehicle profiles, or place orders, you may register an account by providing accurate and complete information (including your name, mobile number, and email address).',
        'You are responsible for maintaining the confidentiality of your login credentials and OTPs, and for all activities that occur under your account.',
        'You agree to promptly update your account information in case of changes to your contact or delivery address details.',
        'VoltSpare does not store raw passwords in plain text or display authentication credentials in unencrypted form.',
      ],
    ),
    LegalSection(
      id: 'tc_3',
      title: '3. Product Information & Fitment Compatibility',
      summary: 'Vehicle fitment, product details, and compatibility verification.',
      bulletPoints: [
        'VoltSpare makes reasonable efforts to provide accurate product names, brand references, vehicle compatibility (by EV/petrol brand and model), pricing, technical descriptions, and images.',
        'Product images are for illustrative purposes and packaging or visual finish may occasionally vary depending on manufacturer batch updates.',
        'Vehicle fitment recommendations are provided as guidance based on catalog specifications. Customers are encouraged to verify vehicle model, variant, year of manufacture, and part dimensions prior to ordering.',
        'If you require assistance regarding part compatibility, our customer support and ticket assistance channels are available before order confirmation.',
      ],
    ),
    LegalSection(
      id: 'tc_4',
      title: '4. Product Availability & Hub Inventory',
      summary: 'Location-based inventory, hub fulfillment, and availability status.',
      bulletPoints: [
        'Product availability and estimated delivery timelines may vary based on your selected delivery address, nearest fulfillment hub inventory, order timing, and logistics feasibility.',
        'If an item becomes unavailable or out of stock after order submission, VoltSpare will notify you promptly and process an appropriate refund or alternate arrangement with your consent.',
        'Same-day, next-day, or scheduled delivery options apply only where specifically marked and when both the item and delivery address qualify under hub operational capacity.',
      ],
    ),
    LegalSection(
      id: 'tc_5',
      title: '5. Pricing, Applicable Taxes & Invoicing',
      summary: 'Transparent pricing, GST, delivery charges, and final payable amount.',
      bulletPoints: [
        'All prices are listed in Indian Rupees (INR) and clearly display applicable Goods and Services Tax (GST), delivery charges, discounts, and the final net payable total at checkout.',
        'The final amount displayed on the order review screen before payment authorization is the amount payable for the order.',
        'Invoices with itemized tax breakdowns (CGST/SGST/IGST where applicable) are generated digitally upon order confirmation and accessible within your account order history.',
        'VoltSpare reserves the right to correct manifest pricing errors caused by technical malfunctions before order fulfillment, with notice and refund options provided to the customer.',
      ],
    ),
    LegalSection(
      id: 'tc_6',
      title: '6. Orders & Order Confirmation',
      summary: 'Order placement, validation, status tracking, and cancellation terms.',
      bulletPoints: [
        'You may place an order by selecting desired products and completing the checkout process.',
        'An order confirmation with a unique Order ID will be generated upon successful order receipt and payment validation.',
        'VoltSpare may contact you regarding order confirmation, dispatch updates, address verification, or alternate part fitment where necessary.',
        'Orders are subject to product availability and payment verification. If an order cannot be fulfilled, you will be informed promptly and an appropriate refund will be initiated.',
      ],
    ),
    LegalSection(
      id: 'tc_7',
      title: '7. Payment Methods & Security',
      summary: 'Supported payment gateways, transaction validation, and fraud security.',
      bulletPoints: [
        'Payments may be processed through supported payment aggregators (e.g., UPI, debit/credit cards, net banking, and Cash on Delivery where eligible).',
        'VoltSpare receives payment confirmation and transaction reference numbers necessary to confirm orders, generate invoices, and handle refunds.',
        'VoltSpare does not store complete card numbers, CVV codes, UPI PINs, or banking passwords on its servers.',
        'In the event of payment failure or duplicate debits, resolution is coordinated with the payment gateway and your issuing bank according to standard banking timelines.',
      ],
    ),
    LegalSection(
      id: 'tc_8',
      title: '8. Delivery, Logistics & Fulfillment',
      summary: 'Delivery timelines, address validation, and service conditions.',
      bulletPoints: [
        'Delivery timelines depend on delivery location, distance from the assigned VoltSpare fulfillment hub, stock availability, dispatch slot, and operational conditions.',
        'The Platform calculates approximate travel distance between the delivery destination and the fulfillment hub to determine serviceability and delivery fee tiers.',
        'Delivery estimates are provided in good faith but are not absolute guarantees when affected by external circumstances (such as weather extremes, traffic restrictions, or logistics disruptions).',
        'Customers must ensure that an authorized person is available to receive the package at the provided delivery address.',
      ],
    ),
    LegalSection(
      id: 'tc_9',
      title: '9. Hub Radius & Location Serviceability',
      summary: 'Geographic service boundaries, hub assignment, and distance calculation.',
      bulletPoints: [
        'VoltSpare assigns orders to the appropriate fulfillment hub based on the delivery location coordinates (latitude and longitude).',
        'Each hub operates within a designated service radius to ensure reliable delivery times and fresh inventory logistics.',
        'Location information is used strictly for address validation, hub serviceability determination, delivery-distance calculation, and route logistics.',
        'VoltSpare does not continuously track customer devices in the background; location is referenced during address selection or checkout.',
      ],
    ),
    LegalSection(
      id: 'tc_10',
      title: '10. Returns, Refunds, Replacement & RMA Policy',
      summary: 'Eligibility criteria, verification inspection, return windows, and RMA.',
      bulletPoints: [
        'Return, refund, or exchange eligibility depends on the product category, condition upon arrival, and the specific return window stated on the product page.',
        'Eligible return scenarios include: defective or damaged products received, incorrect item or variant delivered, or unsealed/missing parts.',
        'To initiate a return or RMA inspection, customers must raise a request through the Platform support ticket system with supporting photos or unboxing verification where appropriate.',
        'Returned items must include original packaging, tags, barcodes, accessories, and user manuals without unauthorized disassembly or physical damage.',
        'Approved refunds are credited to the original payment source or designated account within standard banking settlement timeframes.',
      ],
    ),
    LegalSection(
      id: 'tc_11',
      title: '11. Warranty Terms',
      summary: 'Product-specific manufacturer warranty and RMA inspection coverage.',
      bulletPoints: [
        'Where a spare part carries a manufacturer warranty or VoltSpare verified warranty, the specific warranty period and terms are stated on the product details page.',
        'Warranty claims require proof of purchase (VoltSpare Tax Invoice) and adherence to manufacturer installation guidelines.',
        'Warranties do not cover damages caused by incorrect installation, improper vehicle modification, normal wear and tear, accident impact, or water damage on non-waterproof electrical components.',
      ],
    ),
    LegalSection(
      id: 'tc_12',
      title: '12. Customer Responsibilities',
      summary: 'Accurate details, vehicle compatibility checks, and receiving parcels.',
      bulletPoints: [
        'Provide accurate contact numbers, complete address landmarks, and recipient names.',
        'Carefully verify vehicle model, make year, and part compatibility prior to placing orders.',
        'Inspect packages upon arrival and notify customer support promptly if the packaging appears tampered with or damaged.',
        'Follow standard vehicle safety guidelines and utilize qualified technicians for complex mechanical or high-voltage electrical part installations.',
      ],
    ),
    LegalSection(
      id: 'tc_13',
      title: '13. Prohibited Conduct & Misuse',
      summary: 'Account integrity, fraud prevention, and platform safety.',
      bulletPoints: [
        'You agree not to create fraudulent accounts, provide false identity information, or abuse promotional coupons.',
        'You agree not to attempt unauthorized access, reverse engineer platform systems, or disrupt server infrastructure.',
        'You agree not to upload malicious attachments, defamatory content, or fraudulent payment receipts in chat or ticket support.',
        'VoltSpare reserves the right to suspend accounts engaged in abusive, fraudulent, or unlawful activities.',
      ],
    ),
    LegalSection(
      id: 'tc_14',
      title: '14. Intellectual Property Rights',
      summary: 'VoltSpare trademarks, software, logos, and third-party brand acknowledgments.',
      bulletPoints: [
        'The VoltSpare brand name, logo, app design, UI layouts, graphic assets, database schemas, and proprietary software are protected under applicable intellectual property laws.',
        'Vehicle brand names, manufacturer logos, and model names referenced on the Platform are used solely to indicate vehicle fitment and compatibility.',
        'All third-party trademarks and trade names remain the property of their respective owners.',
      ],
    ),
    LegalSection(
      id: 'tc_15',
      title: '15. Third-Party Services & Integrations',
      summary: 'Payment aggregators, map service providers, and cloud infrastructure.',
      bulletPoints: [
        'VoltSpare may integrate third-party services including payment gateways, map geocoding providers, notification delivery channels, and cloud hosting.',
        'Your use of services involving these providers is subject to their respective terms and privacy policies in addition to VoltSpare\'s Terms.',
        'VoltSpare is not liable for service outages caused solely by external third-party infrastructure beyond reasonable technical control.',
      ],
    ),
    LegalSection(
      id: 'tc_16',
      title: '16. Limitation of Liability & Service Availability',
      summary: 'Platform uptime, scheduled maintenance, and reasonable liability terms.',
      bulletPoints: [
        'VoltSpare strives to ensure maximum platform availability and uptime but does not warrant uninterrupted or error-free continuous service during necessary maintenance windows.',
        'To the extent permitted by law, VoltSpare is not liable for indirect, incidental, or consequential damages resulting from vehicle operation outside recommended manufacturer specifications.',
        'Nothing in these Terms limits or excludes liability that cannot lawfully be limited or excluded under applicable Indian consumer protection laws.',
      ],
    ),
    LegalSection(
      id: 'tc_17',
      title: '17. Statutory Consumer Protection Compliance',
      summary: 'Consumer Protection Act, 2019 and E-Commerce Rules, 2020 adherence.',
      bulletPoints: [
        'VoltSpare complies with the Consumer Protection Act, 2019 and the Consumer Protection (E-Commerce) Rules, 2020.',
        'The Platform provides transparent disclosures regarding product descriptions, country of origin / manufacturer info where applicable, total price breakdowns, warranty details, and return/refund procedures.',
        'Consumer statutory rights granted under mandatory Indian consumer laws remain fully intact and are not superseded by these Terms.',
      ],
    ),
    LegalSection(
      id: 'tc_18',
      title: '18. Customer Support & Grievance Redressal',
      summary: 'Grievance Officer details, support contact channels, and resolution timelines.',
      bulletPoints: [
        'In accordance with the Consumer Protection (E-Commerce) Rules, 2020 and Information Technology Act rules, VoltSpare has designated a Grievance Redressal Officer.',
        'Grievance Redressal Officer: ${LegalConfig.grievanceOfficerName}',
        'Grievance Email: ${LegalConfig.grievanceEmail}',
        'Support Email: ${LegalConfig.supportEmail} | Phone: ${LegalConfig.supportPhone}',
        'Grievances are acknowledged within 48 hours and redressed within statutory timelines (typically 30 days of receipt).',
      ],
    ),
    LegalSection(
      id: 'tc_19',
      title: '19. Modifications to Terms',
      summary: 'Periodic policy updates, notification of material changes, and effective dates.',
      bulletPoints: [
        'VoltSpare reserves the right to modify or update these Terms to reflect operational improvements, new features, or legislative amendments.',
        'Material updates will be notified through prominent app notices, banner alerts, or updated effective dates.',
        'Continued use of the Platform after the effective date of updated Terms constitutes acceptance of the modified Terms.',
        'Effective Date: ${LegalConfig.effectiveDate} | Last Updated: ${LegalConfig.lastUpdatedDate}',
      ],
    ),
    LegalSection(
      id: 'tc_20',
      title: '20. Governing Law & Dispute Resolution',
      summary: 'Laws of India and jurisdiction of competent courts.',
      bulletPoints: [
        'These Terms and any dispute arising from your use of VoltSpare are governed by and construed in accordance with the laws of the Republic of India.',
        'Subject to applicable consumer protection legislation and statutory consumer dispute redressal forums, disputes shall be submitted to the jurisdiction of competent courts in India.',
        'Parties are encouraged to first seek amicable resolution through our customer support and grievance redressal cell.',
      ],
    ),
  ];
}

class VoltSparePrivacyPolicy {
  static const String title = 'Privacy Policy';
  static const String preamble =
      'VoltSpare ("we", "our", or "us") values your privacy and is committed to protecting your personal data. This Privacy Policy explains how we collect, use, process, share, store, and safeguard your personal information when you use our mobile application, web services, and customer platforms, in compliance with applicable Indian data protection laws including the Digital Personal Data Protection Act, 2023 (DPDPA).';

  static const List<LegalSection> sections = [
    LegalSection(
      id: 'pp_1',
      title: '1. Information We Collect',
      summary: 'Account details, delivery addresses, vehicle information, and location coordinates.',
      bulletPoints: [
        'Account Information: Full name, mobile phone number, email address, and saved vehicle garage details (make, model, variant).',
        'Delivery Details: Recipient contact name, phone number, complete address landmarks, pincode, and user-labeled address tags (e.g. Home, Garage, Workshop).',
        'Location Data: Latitude and longitude coordinates provided during address selection or pinpointed on map pickers to assign fulfillment hubs and compute delivery distance.',
        'Communication Records: Support ticket messages, chat history with support staff, feedback suggestions, and warranty RMA documentation.',
      ],
    ),
    LegalSection(
      id: 'pp_2',
      title: '2. Order & Transaction Information',
      summary: 'Purchased parts, invoices, order statuses, and return records.',
      bulletPoints: [
        'Details of spare parts ordered, quantities, unit prices, tax itemization, discounts applied, and delivery charges.',
        'Order fulfillment status, dispatch logs, courier tracking IDs, and delivery timestamps.',
        'Digitally generated tax invoices and transaction history linked to your account.',
        'Warranty claims, return requests, part inspection photos, and refund transaction references.',
      ],
    ),
    LegalSection(
      id: 'pp_3',
      title: '3. Payment Information Handling',
      summary: 'Payment reference data; no storage of sensitive card CVV or UPI PINs.',
      bulletPoints: [
        'Payment transactions are processed securely through RBI-compliant payment gateway partners.',
        'VoltSpare receives only the transaction status, payment mode, and gateway reference number required to validate your order and process refunds.',
        'VoltSpare does not collect or store full credit/debit card numbers, CVV numbers, UPI PINs, or net banking passwords.',
      ],
    ),
    LegalSection(
      id: 'pp_4',
      title: '4. Purpose of Data Processing',
      summary: 'How your data enables order fulfillment, customer support, and platform operations.',
      bulletPoints: [
        'Creating and managing your user account and saved vehicle profiles.',
        'Processing orders, verifying inventory, and coordinating dispatch with fulfillment hubs.',
        'Calculating accurate delivery distances, hub serviceability, and distance-based logistics fees.',
        'Providing real-time order tracking, delivery notifications, and customer support assistance.',
        'Generating statutory tax invoices and maintaining accounting/tax audit compliance.',
        'Processing product returns, RMA inspections, and issuing authorized refunds.',
        'Detecting and preventing fraudulent transactions, unauthorized access, and security breaches.',
      ],
    ),
    LegalSection(
      id: 'pp_5',
      title: '5. Location Data & Hub Serviceability Notice',
      summary: 'Explicit notice on how address coordinates are used for hub fulfillment radius.',
      bulletPoints: [
        'VoltSpare processes delivery address latitude and longitude coordinates strictly to determine the nearest operational fulfillment hub and verify that the destination falls within the hub\'s designated service radius.',
        'Coordinates are used to calculate route distance and estimate delivery arrival times.',
        'Location information is accessed only when you choose a delivery address or search for nearby hubs; VoltSpare does not perform continuous background device tracking.',
      ],
    ),
    LegalSection(
      id: 'pp_6',
      title: '6. Data Sharing & Third-Party Disclosures',
      summary: 'Strict need-to-know sharing with logistics, payment, and cloud providers.',
      bulletPoints: [
        'Delivery & Logistics Partners: Sharing recipient name, contact phone, and delivery address to deliver ordered spare parts.',
        'Payment Aggregators: Communicating transaction amounts and order IDs to process payments and refunds.',
        'Map & Geocoding Providers: Converting addresses to map coordinates for hub assignment and routing.',
        'Cloud Infrastructure & SMS/Notification Services: Hosting encrypted database records and dispatching transactional order updates.',
        'Legal & Statutory Authorities: Disclosing data only when required under applicable law, court order, or official regulatory directive.',
        'VoltSpare never sells, rents, or trades customer personal data to third parties for independent marketing.',
      ],
    ),
    LegalSection(
      id: 'pp_7',
      title: '7. Data Retention & Archival',
      summary: 'Retention for active service duration, accounting records, and statutory compliance.',
      bulletPoints: [
        'Personal data is retained for as long as your account is active and as necessary to fulfill orders and provide ongoing support.',
        'Tax invoices, transaction logs, and billing records are retained for statutory periods required under Indian tax and corporate laws.',
        'Upon account closure or deletion request, personal data is deleted or anonymized, except where retention is legally mandated for audit or dispute resolution.',
      ],
    ),
    LegalSection(
      id: 'pp_8',
      title: '8. Data Security Measures',
      summary: 'Encryption, secure access controls, and industry-standard protection.',
      bulletPoints: [
        'VoltSpare implements technical and organizational safeguards including HTTPS/TLS encryption for data in transit, secure hashed credential storage, and role-based access controls.',
        'Administrative consoles restrict access to customer data strictly to authorized staff on a role-specific, need-to-know basis.',
        'While we follow industry best practices, no digital transmission or storage method is completely infallible; we advise users to protect their account OTPs and passwords.',
      ],
    ),
    LegalSection(
      id: 'pp_9',
      title: '9. User Rights & Choices (DPDPA Compliance)',
      summary: 'Right to access, correct, update, withdraw consent, and request deletion.',
      bulletPoints: [
        'Right to Access: You can view your personal profile, vehicle garage, saved addresses, and order history anytime within the app.',
        'Right to Correction & Update: You may update or correct your profile information and saved addresses.',
        'Right to Erasure / Account Deletion: You can request account deletion, subject to statutory retention of tax and completed transaction records.',
        'Right to Withdraw Consent: Where processing relies on consent, you may withdraw consent for optional features.',
        'Right to Grievance Redressal: You may raise concerns or complaints regarding data handling with our Data Protection / Grievance Officer.',
      ],
    ),
    LegalSection(
      id: 'pp_10',
      title: '10. Children\'s Privacy',
      summary: 'Platform intended for adult vehicle owners and qualified operators.',
      bulletPoints: [
        'VoltSpare is not intended for individuals under 18 years of age without parental or legal guardian consent and supervision.',
        'We do not knowingly collect personal information directly from children.',
        'If we become aware that data of a minor has been collected without verifiable consent, we will take prompt steps to delete such data.',
      ],
    ),
    LegalSection(
      id: 'pp_11',
      title: '11. Cookies & Local App Storage',
      summary: 'Use of local tokens, secure session storage, and UI preference caching.',
      bulletPoints: [
        'The Platform uses local device storage and secure tokens to maintain your login session and preserve cart/vehicle preferences across app restarts.',
        'Web versions may utilize necessary functional cookies for session continuity and security.',
        'We do not use invasive third-party tracking cookies across unrelated external websites.',
      ],
    ),
    LegalSection(
      id: 'pp_12',
      title: '12. Third-Party Links & External Services',
      summary: 'Independent privacy policies of external services.',
      bulletPoints: [
        'The Platform may link to external services (such as payment gateway interfaces or courier tracking portals).',
        'VoltSpare is not responsible for the privacy practices of external third-party websites; we encourage you to review their policies.',
      ],
    ),
    LegalSection(
      id: 'pp_13',
      title: '13. Changes to Privacy Policy',
      summary: 'Policy versioning, notification of updates, and archived revisions.',
      bulletPoints: [
        'We may update this Privacy Policy from time to time to align with technical enhancements, operational updates, or legal requirements.',
        'Significant revisions will be announced through app notifications, banners, or email updates.',
        'Effective Date: ${LegalConfig.effectiveDate} | Last Updated: ${LegalConfig.lastUpdatedDate}',
      ],
    ),
    LegalSection(
      id: 'pp_14',
      title: '14. Privacy Grievance & Data Protection Contact',
      summary: 'Contact our Grievance Officer for privacy inquiries and data requests.',
      bulletPoints: [
        'For inquiries, data access requests, or privacy grievances, contact our Grievance Redressal Officer:',
        'Officer: ${LegalConfig.grievanceOfficerName}',
        'Email: ${LegalConfig.privacyEmail} (cc: ${LegalConfig.grievanceEmail})',
        'Postal Address: ${LegalConfig.grievanceAddress}',
        'Phone: ${LegalConfig.supportPhone}',
      ],
    ),
  ];
}
