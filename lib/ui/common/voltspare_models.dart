import 'package:flutter/material.dart';

enum VehicleType { ev, petrol }

class VehicleBrandModel {
  final String id;
  final String name;
  final String? logoAsset;

  const VehicleBrandModel({
    required this.id,
    required this.name,
    this.logoAsset,
  });
}

class VehicleModel {
  final String id;
  final String brand;
  final String brandId;
  final String name;
  final String year;
  final VehicleType type;

  const VehicleModel({
    required this.id,
    required this.brand,
    this.brandId = '',
    required this.name,
    required this.year,
    required this.type,
  });

  String get displayName => name.isNotEmpty ? name : '$brand ($year)';
}

class CompatibleVehicleEntry {
  final String brandId;
  final String brandName;
  final String modelId;
  final String modelName;

  const CompatibleVehicleEntry({
    required this.brandId,
    required this.brandName,
    required this.modelId,
    required this.modelName,
  });

  Map<String, String> toJson() => {
        'brand': brandId,
        'model': modelId,
      };
}

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final String slug;
  final String description;
  final String type; // 'EV', 'Petrol', 'Universal'
  final bool active;
  final String? parentCategoryId;
  final String? parentCategoryName;
  final int productCount;
  final String? image;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    this.slug = '',
    this.description = '',
    this.type = 'Universal',
    this.active = true,
    this.parentCategoryId,
    this.parentCategoryName,
    this.productCount = 0,
    this.image,
  });

  CategoryModel copyWith({
    String? id,
    String? name,
    IconData? icon,
    String? slug,
    String? description,
    String? type,
    bool? active,
    String? parentCategoryId,
    String? parentCategoryName,
    int? productCount,
    String? image,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      type: type ?? this.type,
      active: active ?? this.active,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      parentCategoryName: parentCategoryName ?? this.parentCategoryName,
      productCount: productCount ?? this.productCount,
      image: image ?? this.image,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description.isNotEmpty) 'description': description,
      'type': type,
      'active': active,
      if (parentCategoryId != null && parentCategoryId!.isNotEmpty)
        'parentCategory': parentCategoryId,
      if (image != null && image!.isNotEmpty) 'image': image,
    };
  }
}

class ProductModel {
  final String id;
  final String name;
  final double price;
  final double? originalPrice;
  final double rating;
  final String description;
  final String categoryId;
  final bool isFavorite;
  final List<String> compatibleVehicleIds;
  final String? fitmentBadge; // e.g. "Direct Fit", "Compatible"
  final String? imageAsset;
  final int stockCount;
  final double purchasePrice;
  final double taxPercentage;
  final String vehicleType; // 'EV', 'Petrol', 'Universal'
  final String? locationBin;
  final String fitType; // 'vehicle_specific' or 'universal'
  final bool stockManaged;
  final List<CompatibleVehicleEntry> compatibleVehicles;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.description,
    required this.categoryId,
    this.isFavorite = false,
    this.compatibleVehicleIds = const [],
    this.fitmentBadge,
    this.imageAsset,
    this.stockCount = 10,
    this.purchasePrice = 0.0,
    this.taxPercentage = 18.0,
    this.vehicleType = 'Universal',
    this.locationBin,
    this.fitType = 'vehicle_specific',
    this.stockManaged = true,
    this.compatibleVehicles = const [],
  });

  String get deliveryText {
    if (stockManaged) {
      if (stockCount > 0) {
        final now = DateTime.now();
        if (now.hour < 15) {
          return 'Same Day Delivery';
        } else {
          return 'Next Day Delivery';
        }
      } else {
        return 'Out of Stock';
      }
    } else {
      return 'Available on Order (Delivery in 2 Days)';
    }
  }

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    double? originalPrice,
    double? rating,
    String? description,
    String? categoryId,
    bool? isFavorite,
    List<String>? compatibleVehicleIds,
    String? fitmentBadge,
    String? imageAsset,
    int? stockCount,
    double? purchasePrice,
    double? taxPercentage,
    String? vehicleType,
    String? locationBin,
    String? fitType,
    bool? stockManaged,
    List<CompatibleVehicleEntry>? compatibleVehicles,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      rating: rating ?? this.rating,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      isFavorite: isFavorite ?? this.isFavorite,
      compatibleVehicleIds: compatibleVehicleIds ?? this.compatibleVehicleIds,
      fitmentBadge: fitmentBadge ?? this.fitmentBadge,
      imageAsset: imageAsset ?? this.imageAsset,
      stockCount: stockCount ?? this.stockCount,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      vehicleType: vehicleType ?? this.vehicleType,
      locationBin: locationBin ?? this.locationBin,
      fitType: fitType ?? this.fitType,
      stockManaged: stockManaged ?? this.stockManaged,
      compatibleVehicles: compatibleVehicles ?? this.compatibleVehicles,
    );
  }
}

class CartItemModel {
  final String id;
  final ProductModel product;
  final int quantity;

  const CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
  });

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class AddressModel {
  final String id;
  final String name;
  final String phone;
  final String addressLine;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.addressLine,
    this.isDefault = false,
  });
}

enum PaymentType { upi, card, cod }

class PaymentOptionModel {
  final String name;
  final IconData icon;
  final PaymentType type;

  const PaymentOptionModel({
    required this.name,
    required this.icon,
    required this.type,
  });
}

enum OrderStatus { processing, shipped, delivered, cancelled }

class OrderModel {
  final String id;
  final String orderNumber;
  final DateTime date;
  final OrderStatus status;
  final List<CartItemModel> items;
  final double total;
  final AddressModel address;
  final String paymentMethod;
  final String? locationId;
  final String? locationName;
  final String channel; // 'app', 'online', 'pos', 'in_store'

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.status,
    required this.items,
    required this.total,
    required this.address,
    required this.paymentMethod,
    this.locationId,
    this.locationName,
    this.channel = 'app',
  });

  bool get isPosOrder =>
      channel.toLowerCase() == 'pos' ||
      channel.toLowerCase() == 'in_store' ||
      orderNumber.toUpperCase().contains('POS');

  bool get isAppOrder => !isPosOrder;

  String get channelDisplayName => isPosOrder ? 'Store POS' : 'Mobile App';

  OrderModel copyWith({
    String? id,
    String? orderNumber,
    DateTime? date,
    OrderStatus? status,
    List<CartItemModel>? items,
    double? total,
    AddressModel? address,
    String? paymentMethod,
    String? locationId,
    String? locationName,
    String? channel,
  }) {
    return OrderModel(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      date: date ?? this.date,
      status: status ?? this.status,
      items: items ?? this.items,
      total: total ?? this.total,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      channel: channel ?? this.channel,
    );
  }
}

class OrderTrackingStepModel {
  final String title;
  final String description;
  final String timeString;
  final bool isCompleted;
  final bool isCurrent;

  const OrderTrackingStepModel({
    required this.title,
    required this.description,
    required this.timeString,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}

enum RareRequestStatus {
  submitted,
  searching,
  found,
  quotationSent,
  negotiation,
  approved,
  cancelled,
  convertedToOrder,
}

enum RareChatMessageType {
  text,
  image,
  quotation,
  statusUpdate,
  productFound,
}

enum RareChatSender {
  customer,
  admin,
  system,
}

class RareQuotationModel {
  final String id;
  final String partName;
  final double price;
  final double shippingCharge;
  final double gst;
  final double discount;
  final double grandTotal;
  final String deliveryTimeline;
  final DateTime expiryDate;
  final String? adminNotes;
  final String status; // 'pending', 'approved', 'declined'

  const RareQuotationModel({
    required this.id,
    required this.partName,
    required this.price,
    required this.shippingCharge,
    required this.gst,
    required this.discount,
    required this.grandTotal,
    required this.deliveryTimeline,
    required this.expiryDate,
    this.adminNotes,
    required this.status,
  });
}

class RareProductRequestModel {
  final String id;
  final String customerName;
  final String phone;
  final VehicleModel vehicle;
  final String? partName;
  final String description;
  final int quantity;
  final String urgency;
  final double? budget;
  final List<String> images;
  final String? notes;
  final RareRequestStatus status;
  final DateTime date;
  final RareQuotationModel? quotation;
  final String? cancellationReason;
  final String? orderId;
  final String? locationId;
  final String? locationName;
  final String channel; // 'online' or 'in_store'

  const RareProductRequestModel({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.vehicle,
    this.partName,
    required this.description,
    required this.quantity,
    required this.urgency,
    this.budget,
    required this.images,
    this.notes,
    required this.status,
    required this.date,
    this.quotation,
    this.cancellationReason,
    this.orderId,
    this.locationId,
    this.locationName,
    this.channel = 'online',
  });

  RareProductRequestModel copyWith({
    String? id,
    String? customerName,
    String? phone,
    VehicleModel? vehicle,
    String? partName,
    String? description,
    int? quantity,
    String? urgency,
    double? budget,
    List<String>? images,
    String? notes,
    RareRequestStatus? status,
    DateTime? date,
    RareQuotationModel? quotation,
    String? cancellationReason,
    String? orderId,
    String? locationId,
    String? locationName,
    String? channel,
  }) {
    return RareProductRequestModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      vehicle: vehicle ?? this.vehicle,
      partName: partName ?? this.partName,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      urgency: urgency ?? this.urgency,
      budget: budget ?? this.budget,
      images: images ?? this.images,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      date: date ?? this.date,
      quotation: quotation ?? this.quotation,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      orderId: orderId ?? this.orderId,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      channel: channel ?? this.channel,
    );
  }
}

class RareChatMessageModel {
  final String id;
  final String message;
  final RareChatSender sender;
  final DateTime timestamp;
  final RareChatMessageType messageType;
  final List<String>? images;
  final RareQuotationModel? quotation;
  final List<String> readBy;
  final List<String> receivedBy;

  const RareChatMessageModel({
    required this.id,
    required this.message,
    required this.sender,
    required this.timestamp,
    required this.messageType,
    this.images,
    this.quotation,
    this.readBy = const [],
    this.receivedBy = const [],
  });
}

class SupplierModel {
  final String id;
  final String companyName;
  final String contactPerson;
  final String phone;
  final String email;
  final String address;
  final String city;
  final String state;
  final String gstNumber;
  final List<String> categories;
  final bool suppliesEvParts;
  final bool suppliesPetrolParts;
  final bool isActive;
  final int outstandingAmountInPaise;
  final DateTime? lastPurchaseDate;

  const SupplierModel({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.address,
    required this.city,
    required this.state,
    required this.gstNumber,
    required this.categories,
    required this.suppliesEvParts,
    required this.suppliesPetrolParts,
    required this.isActive,
    required this.outstandingAmountInPaise,
    this.lastPurchaseDate,
  });
}
