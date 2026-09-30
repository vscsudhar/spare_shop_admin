/// Centralized Business Information & Application Constants for VoltSpare
class VoltSpareBusinessConfig {
  // Brand & Identity
  static const String appName = 'VoltSpare';
  static const String appTagline = 'Automotive Spares & EV Components Management';
  static const String storeName = 'VoltSpare Headquarters';
  static const String legalEntityName = 'VoltSpare Automotive Technologies Pvt. Ltd.';

  // Support & Contact Information
  static const String supportEmail = 'support@voltspare.com';
  static const String billingEmail = 'billing@voltspare.com';
  static const String supportPhone = '+91 99000 88000';
  static const String website = 'www.voltspare.com';
  static const String websiteFull = 'https://www.voltspare.com';

  // Default Business Location & Tax Details (Configurable via Admin Settings / Backend API)
  static const String defaultAddressLine1 = '12, MG Road, Landmark Block';
  static const String defaultAddressLine2 = 'Indiranagar Commercial Zone';
  static const String defaultCity = 'Bangalore';
  static const String defaultState = 'Karnataka';
  static const String defaultStateCode = '29';
  static const String defaultPincode = '560001';
  static const String defaultGstin = '29AAAAA0000A1Z1';
  static const String defaultPan = 'AAAAA0000A';

  // Map Coordinates
  static const double defaultLatitude = 12.9716;
  static const double defaultLongitude = 77.5946;

  // Invoice & Legal Defaults (Neutral and standard for VoltSpare)
  static const List<String> defaultInvoiceTerms = [
    'Goods once sold are covered under the applicable VoltSpare warranty and RMA policy.',
    'All disputes are subject to the jurisdiction of the local courts of the billing branch/state.',
    'This is an electronically generated tax invoice issued in accordance with applicable IT regulations.',
  ];

  static const String defaultWarrantyPolicy =
      'Products are covered under manufacturer warranty / VoltSpare verified RMA inspection.';

  static const String defaultReturnPolicy =
      'Returns & exchanges are subject to inspection and verification within the eligible return period.';
}

// UI Strings
const String ksHomeBottomSheetTitle = 'VoltSpare Operations';
const String ksHomeBottomSheetDescription =
    'Manage automobile spare parts, POS billing, real-time inventory, orders, and customer warranty support seamlessly.';
