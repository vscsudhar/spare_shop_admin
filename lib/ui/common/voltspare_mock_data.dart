import 'package:flutter/material.dart';
import 'voltspare_models.dart';

// Categories
const List<CategoryModel> mockCategories = [
  CategoryModel(
      id: 'cat_battery',
      name: 'EV Battery & Power',
      icon: Icons.battery_charging_full_rounded),
  CategoryModel(
      id: 'cat_engine',
      name: 'Engine & Transmission',
      icon: Icons.settings_rounded),
  CategoryModel(
      id: 'cat_brakes', name: 'Brake System', icon: Icons.disc_full_rounded),
  CategoryModel(
      id: 'cat_electrical',
      name: 'Electricals & Lights',
      icon: Icons.lightbulb_rounded),
  CategoryModel(
      id: 'cat_chassis',
      name: 'Body & Chassis',
      icon: Icons.motorcycle_rounded),
  CategoryModel(
      id: 'cat_tyres',
      name: 'Tyres & Suspension',
      icon: Icons.blur_circular_rounded),
];

// Brands
const List<VehicleBrandModel> mockEvBrands = [
  VehicleBrandModel(id: 'ola', name: 'Ola'),
  VehicleBrandModel(id: 'ather', name: 'Ather'),
  VehicleBrandModel(id: 'tvs_ev', name: 'TVS iQube'),
  VehicleBrandModel(id: 'bajaj_ev', name: 'Bajaj Chetak'),
  VehicleBrandModel(id: 'hero_ev', name: 'Hero Vida'),
  VehicleBrandModel(id: 'ampere', name: 'Ampere'),
];

const List<VehicleBrandModel> mockPetrolBrands = [
  VehicleBrandModel(id: 'hero', name: 'Hero'),
  VehicleBrandModel(id: 'honda', name: 'Honda'),
  VehicleBrandModel(id: 'tvs', name: 'TVS'),
  VehicleBrandModel(id: 'bajaj', name: 'Bajaj'),
  VehicleBrandModel(id: 'yamaha', name: 'Yamaha'),
  VehicleBrandModel(id: 'suzuki', name: 'Suzuki'),
];

// Vehicles
const List<VehicleModel> mockVehicles = [
  VehicleModel(
      id: 'veh_ola_s1',
      brand: 'Ola',
      name: 'S1 Pro Gen 2',
      year: '2023',
      type: VehicleType.ev),
  VehicleModel(
      id: 'veh_ola_s1_air',
      brand: 'Ola',
      name: 'S1 Air',
      year: '2023',
      type: VehicleType.ev),
  VehicleModel(
      id: 'veh_ather_450x',
      brand: 'Ather',
      name: '450X Gen 3',
      year: '2022',
      type: VehicleType.ev),
  VehicleModel(
      id: 'veh_tvs_iqube',
      brand: 'TVS',
      name: 'iQube S',
      year: '2022',
      type: VehicleType.ev),
  VehicleModel(
      id: 'veh_hero_splendor',
      brand: 'Hero',
      name: 'Splendor Plus',
      year: '2021',
      type: VehicleType.petrol),
  VehicleModel(
      id: 'veh_honda_activa',
      brand: 'Honda',
      name: 'Activa 6G',
      year: '2022',
      type: VehicleType.petrol),
  VehicleModel(
      id: 'veh_tvs_apache',
      brand: 'TVS',
      name: 'Apache RTR 160',
      year: '2020',
      type: VehicleType.petrol),
  VehicleModel(
      id: 'veh_bajaj_pulsar',
      brand: 'Bajaj',
      name: 'Pulsar 150',
      year: '2019',
      type: VehicleType.petrol),
  VehicleModel(
      id: 'veh_yamaha_r15',
      brand: 'Yamaha',
      name: 'R15 V4',
      year: '2022',
      type: VehicleType.petrol),
];

// Products
const List<ProductModel> mockProducts = [
  // EV specific
  ProductModel(
    id: 'prod_ather_bat',
    name: 'Ather 450X Gen 3 Replacement Battery Pack',
    price: 37500.0,
    originalPrice: 42000.0,
    rating: 4.8,
    description:
        'Genuine Ather energy Lithium-ion battery pack. 3.7 kWh high performance capacity with smart BMS protection. Direct replacement for Ather 450X Gen 3 models.',
    categoryId: 'cat_battery',
    compatibleVehicleIds: ['veh_ather_450x'],
    fitmentBadge: 'Direct Fit',
    stockCount: 3,
  ),
  ProductModel(
    id: 'prod_ola_chg',
    name: 'Ola S1 Pro 750W Home Charger',
    price: 9499.0,
    originalPrice: 12000.0,
    rating: 4.6,
    description:
        'Fast home charger with 750W output power. Designed specifically for Ola S1 Pro and Ola S1 Air. Waterproof design with auto cut-off safety feature.',
    categoryId: 'cat_battery',
    compatibleVehicleIds: ['veh_ola_s1', 'veh_ola_s1_air'],
    fitmentBadge: 'OEM Accessory',
    stockCount: 8,
  ),
  ProductModel(
    id: 'prod_iqube_motor',
    name: 'TVS iQube 4.4kW Hub Motor Assembly',
    price: 14500.0,
    originalPrice: 16500.0,
    rating: 4.7,
    description:
        'Original BLDC hub motor assembly for TVS iQube. Features IP67 dust and water protection, maximum power output of 4.4kW. Includes wheel hub.',
    categoryId: 'cat_engine',
    compatibleVehicleIds: ['veh_tvs_iqube'],
    fitmentBadge: 'Direct Fit',
    stockCount: 2,
  ),
  // Petrol specific
  ProductModel(
    id: 'prod_piston_splendor',
    name: 'Hero Splendor Plus Engine Piston Kit',
    price: 1450.0,
    originalPrice: 1800.0,
    rating: 4.5,
    description:
        'Complete piston kit containing piston, rings, pin, and clips. Made of premium high-expansion alloy for maximum compression and long service life. Specifically for Hero Splendor 100cc engines.',
    categoryId: 'cat_engine',
    compatibleVehicleIds: ['veh_hero_splendor'],
    fitmentBadge: 'Direct Fit',
    stockCount: 15,
  ),
  ProductModel(
    id: 'prod_carb_activa',
    name: 'Honda Activa 6G Carburetor Assembly',
    price: 2650.0,
    originalPrice: 3200.0,
    rating: 4.4,
    description:
        'Keihin OEM carburetor assembly for Honda Activa 6G. Factory tuned for optimal fuel efficiency and smooth throttle response. Direct bolt-on installation.',
    categoryId: 'cat_engine',
    compatibleVehicleIds: ['veh_honda_activa'],
    fitmentBadge: 'Direct Fit',
    stockCount: 10,
  ),
  ProductModel(
    id: 'prod_disc_apache',
    name: 'TVS Apache RTR 160 Front Brake Disc Plate',
    price: 1599.0,
    originalPrice: 1999.0,
    rating: 4.6,
    description:
        'Premium quality ventilated brake disc plate. High friction stainless steel alloy provides superior heat dissipation and immediate stopping power under all weather conditions.',
    categoryId: 'cat_brakes',
    compatibleVehicleIds: ['veh_tvs_apache'],
    fitmentBadge: 'Direct Fit',
    stockCount: 12,
  ),
  ProductModel(
    id: 'prod_plug_pulsar',
    name: 'Bajaj Pulsar Dual-Spark Plug Kit (Set of 2)',
    price: 420.0,
    originalPrice: 500.0,
    rating: 4.8,
    description:
        'NGK laser iridium spark plug set for Pulsar dual-spark ignition. Ensures quick starts, cleaner combustion, and improved throttle response.',
    categoryId: 'cat_electrical',
    compatibleVehicleIds: ['veh_bajaj_pulsar'],
    fitmentBadge: 'Direct Fit',
    stockCount: 30,
  ),
  ProductModel(
    id: 'prod_filter_r15',
    name: 'Yamaha R15 V4 OEM High-Flow Air Filter',
    price: 350.0,
    originalPrice: 450.0,
    rating: 4.9,
    description:
        'Original Yamaha replacement air filter element. Traps micro dust particles while allowing maximum airflow to the engine intake system for top speed performance.',
    categoryId: 'cat_engine',
    compatibleVehicleIds: ['veh_yamaha_r15'],
    fitmentBadge: 'Direct Fit',
    stockCount: 25,
  ),
  // General parts
  ProductModel(
    id: 'prod_brake_pads',
    name: 'Premium Ceramic Front Brake Pads',
    price: 680.0,
    originalPrice: 850.0,
    rating: 4.5,
    description:
        'Ceramic composite brake pads for two-wheelers. Zero squeaking noise, low dust emission, and excellent thermal recovery. Fits disc models of Ola, Ather, Honda and TVS.',
    categoryId: 'cat_brakes',
    compatibleVehicleIds: [
      'veh_ola_s1',
      'veh_ather_450x',
      'veh_honda_activa',
      'veh_tvs_iqube'
    ],
    fitmentBadge: 'Compatible',
    stockCount: 40,
  ),
  ProductModel(
    id: 'prod_rear_mirrors',
    name: 'Carbon Fibre Texture Rear View Mirror Set',
    price: 890.0,
    originalPrice: 1200.0,
    rating: 4.3,
    description:
        'Universal 8mm/10mm rear view mirrors with aerodynamic carbon fibre texture finish. Wide angle convex lens offers excellent visibility.',
    categoryId: 'cat_chassis',
    compatibleVehicleIds: [
      'veh_ola_s1',
      'veh_ather_450x',
      'veh_honda_activa',
      'veh_hero_splendor',
      'veh_bajaj_pulsar'
    ],
    fitmentBadge: 'Universal Fit',
    stockCount: 18,
  ),
  ProductModel(
    id: 'prod_fork_seals',
    name: 'Front Fork Oil Seal and Dust Cap Kit',
    price: 340.0,
    originalPrice: 450.0,
    rating: 4.2,
    description:
        'Synthetic rubber oil seals with dual garter springs. Effectively seals fork oil and protects hydraulic dampers from mud and dust. Set contains 2 seals and 2 dust caps.',
    categoryId: 'cat_tyres',
    compatibleVehicleIds: [
      'veh_hero_splendor',
      'veh_honda_activa',
      'veh_tvs_apache',
      'veh_bajaj_pulsar'
    ],
    fitmentBadge: 'Compatible',
    stockCount: 50,
  ),
];

// Address
const List<AddressModel> mockAddresses = [
  AddressModel(
    id: 'addr_1',
    name: 'Home Address',
    phone: '+91 98765 43210',
    addressLine:
        'Flat 402, Green Meadows, Sector 5, HSR Layout, Bengaluru, Karnataka - 560102',
    isDefault: true,
  ),
  AddressModel(
    id: 'addr_2',
    name: 'Office Address',
    phone: '+91 98765 43210',
    addressLine:
        'Building B, Tech Park IT corridor, Bellandur, Bengaluru, Karnataka - 560103',
    isDefault: false,
  ),
];

// Payment Options
const List<PaymentOptionModel> mockPaymentOptions = [
  PaymentOptionModel(
      name: 'Google Pay / PhonePe (UPI)',
      icon: Icons.account_balance_wallet_rounded,
      type: PaymentType.upi),
  PaymentOptionModel(
      name: 'Credit / Debit Card',
      icon: Icons.credit_card_rounded,
      type: PaymentType.card),
  PaymentOptionModel(
      name: 'Cash on Delivery (COD)',
      icon: Icons.payments_rounded,
      type: PaymentType.cod),
];

// Tracking step list
const List<OrderTrackingStepModel> mockTrackingSteps = [
  OrderTrackingStepModel(
    title: 'Order Confirmed',
    description: 'Your payment was successful and the order was validated.',
    timeString: 'Today, 10:15 AM',
    isCompleted: true,
  ),
  OrderTrackingStepModel(
    title: 'Packed & Ready',
    description: 'Your spare parts have been packed at our Bengaluru Hub.',
    timeString: 'Today, 12:30 PM',
    isCompleted: true,
    isCurrent: true,
  ),
  OrderTrackingStepModel(
    title: 'Shipped via Express',
    description: 'Out for transit via Bluedart. Airway bill #BD728392.',
    timeString: 'Pending Transit',
    isCompleted: false,
  ),
  OrderTrackingStepModel(
    title: 'Delivered',
    description: 'Items delivered to HSR Layout address.',
    timeString: 'Expected Tomorrow',
    isCompleted: false,
  ),
];

// Chat Quotation Messages
final RareQuotationModel mockQuotation = RareQuotationModel(
  id: 'quot_01',
  partName: 'Rare Original Ola S1 Side Stand Sensor (V1)',
  price: 2490.0,
  shippingCharge: 100.0,
  gst: 450.0,
  discount: 50.0,
  grandTotal: 2990.0,
  deliveryTimeline: '4 - 5 Days Delivery',
  expiryDate: DateTime.now().add(const Duration(days: 3)),
  status: 'pending',
);

final List<RareChatMessageModel> mockChatMessages = [
  RareChatMessageModel(
    id: 'msg_1',
    message:
        'Hello VoltSpare support! I am looking for the original side stand sensor for my Ola S1 Gen 1 scooter. It is currently not showing as available in stock anywhere.',
    sender: RareChatSender.customer,
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    messageType: RareChatMessageType.text,
  ),
  RareChatMessageModel(
    id: 'msg_2',
    message:
        'Thank you for reaching out to VoltSpare Rare Request service. Let me verify the warehouse inventory for the Ola S1 Side Stand Sensor (V1) for you. Please hold.',
    sender: RareChatSender.admin,
    timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
    messageType: RareChatMessageType.text,
  ),
  RareChatMessageModel(
    id: 'msg_3',
    message:
        'Great news! We found a direct-fit factory replacement unit at our supplier warehouse. I am generating a price quotation for you right now.',
    sender: RareChatSender.admin,
    timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    messageType: RareChatMessageType.text,
  ),
  RareChatMessageModel(
    id: 'msg_4',
    message:
        'Here is the quotation for your requested part. You can approve it to convert this directly into an order, or cancel the request if you no longer need it.',
    sender: RareChatSender.admin,
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    messageType: RareChatMessageType.quotation,
    quotation: mockQuotation,
  ),
];

// Global Mock Quotations List
final List<RareQuotationModel> mockQuotationList = [
  mockQuotation,
  RareQuotationModel(
    id: 'quot_02',
    partName: 'Ather 450X High-Tension Drive Belt',
    price: 3200.0,
    shippingCharge: 100.0,
    gst: 576.0,
    discount: 76.0,
    grandTotal: 3800.0,
    deliveryTimeline: '2 Days Delivery',
    expiryDate: DateTime.now().add(const Duration(days: 3)),
    status: 'approved',
  ),
  RareQuotationModel(
    id: 'quot_03',
    partName: 'TVS iQube Hub Motor Cover Guard',
    price: 1850.0,
    shippingCharge: 100.0,
    gst: 333.0,
    discount: 33.0,
    grandTotal: 2250.0,
    deliveryTimeline: '1 Week Delivery',
    expiryDate: DateTime.now().add(const Duration(days: 3)),
    status: 'cancelled',
  ),
];

// Shareable app state for UI mock phase
VehicleModel? currentSelectedVehicle = mockVehicles[2]; // Ather 450X default
List<VehicleModel> userVehicles = [mockVehicles[2]];
final List<CartItemModel> mockCartItems = [];
final List<OrderModel> mockOrderList = [
  OrderModel(
    id: 'ord_1',
    orderNumber: 'VS-2026-9812',
    date: DateTime.now().subtract(const Duration(days: 3)),
    status: OrderStatus.delivered,
    items: [
      CartItemModel(id: 'c1', product: mockProducts[0], quantity: 1),
      CartItemModel(id: 'c2', product: mockProducts[2], quantity: 2),
    ],
    total: 3450.0,
    address: mockAddresses[0],
    paymentMethod: 'UPI (GPay)',
  ),
  OrderModel(
    id: 'ord_2',
    orderNumber: 'VS-2026-9813',
    date: DateTime.now().subtract(const Duration(days: 1)),
    status: OrderStatus.shipped,
    items: [
      CartItemModel(id: 'c3', product: mockProducts[1], quantity: 1),
    ],
    total: 5999.0,
    address: mockAddresses[1],
    paymentMethod: 'Credit Card',
  ),
  OrderModel(
    id: 'ord_3',
    orderNumber: 'VS-2026-9814',
    date: DateTime.now().subtract(const Duration(hours: 4)),
    status: OrderStatus.processing,
    items: [
      CartItemModel(id: 'c4', product: mockProducts[4], quantity: 1),
    ],
    total: 1250.0,
    address: mockAddresses[0],
    paymentMethod: 'Cash on Delivery',
  ),
];

final List<SupplierModel> mockSuppliers = [
  SupplierModel(
    id: 'sup_1',
    companyName: 'EV Spare Tech India',
    contactPerson: 'Suresh Kumar',
    phone: '+91 98765 43210',
    email: 'suresh@evsparetech.in',
    address: '12, GST Road, Guindy',
    city: 'Chennai',
    state: 'Tamil Nadu',
    gstNumber: '33AAAAA1111A1Z1',
    categories: const ['Sensors', 'Controllers', 'Motors'],
    suppliesEvParts: true,
    suppliesPetrolParts: false,
    isActive: true,
    outstandingAmountInPaise: 1250000,
    lastPurchaseDate: DateTime.now().subtract(const Duration(days: 3)),
  ),
  SupplierModel(
    id: 'sup_2',
    companyName: 'Auto Parts Distributors',
    contactPerson: 'Ramesh Sharma',
    phone: '+91 91234 56789',
    email: 'ramesh@autoparts.co.in',
    address: '45, Link Road, Andheri West',
    city: 'Mumbai',
    state: 'Maharashtra',
    gstNumber: '27BBBBB2222B2Z2',
    categories: const ['Filters', 'Brakes', 'Cables'],
    suppliesEvParts: false,
    suppliesPetrolParts: true,
    isActive: true,
    outstandingAmountInPaise: 850000,
    lastPurchaseDate: DateTime.now().subtract(const Duration(days: 7)),
  ),
  SupplierModel(
    id: 'sup_3',
    companyName: 'Volt EV Logistics',
    contactPerson: 'Priya Rajan',
    phone: '+91 98989 89898',
    email: 'priya@voltev.com',
    address: '89, Outer Ring Road, HSR Layout',
    city: 'Bangalore',
    state: 'Karnataka',
    gstNumber: '29CCCCC3333C3Z3',
    categories: const ['Batteries', 'Chargers', 'Wiring Harness'],
    suppliesEvParts: true,
    suppliesPetrolParts: false,
    isActive: true,
    outstandingAmountInPaise: 0,
    lastPurchaseDate: DateTime.now().subtract(const Duration(days: 10)),
  ),
  SupplierModel(
    id: 'sup_4',
    companyName: 'Royal Automobile Spares',
    contactPerson: 'Amit Singh',
    phone: '+91 93456 78901',
    email: 'amit@royalspares.com',
    address: '15, Karol Bagh Market',
    city: 'New Delhi',
    state: 'Delhi',
    gstNumber: '07DDDDD4444D4Z4',
    categories: const ['Exhaust', 'Engine Valves', 'Spark Plugs'],
    suppliesEvParts: false,
    suppliesPetrolParts: true,
    isActive: false,
    outstandingAmountInPaise: 45000,
    lastPurchaseDate: DateTime.now().subtract(const Duration(days: 30)),
  ),
];
