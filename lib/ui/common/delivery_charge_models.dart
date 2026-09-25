class DeliveryChargeModel {
  final String id;
  final double fromAmount;
  final double? toAmount;
  final double deliveryCharge;
  final String? locationId;
  final String? locationName;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DeliveryChargeModel({
    required this.id,
    required this.fromAmount,
    this.toAmount,
    required this.deliveryCharge,
    this.locationId,
    this.locationName,
    this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  bool get isFreeDelivery => deliveryCharge == 0;
  bool get isUnbounded => toAmount == null;

  String get tierDisplay {
    if (toAmount == null) {
      return '₹${fromAmount.toInt()} and above';
    } else if (fromAmount == 0) {
      return 'Under ₹${toAmount!.toInt()}';
    } else {
      return '₹${fromAmount.toInt()} - ₹${toAmount!.toInt()}';
    }
  }

  String get chargeDisplay {
    if (deliveryCharge == 0) {
      return 'FREE Delivery';
    }
    return '₹${deliveryCharge.toInt()}';
  }

  factory DeliveryChargeModel.fromJson(Map<String, dynamic> json) {
    return DeliveryChargeModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      fromAmount: (json['fromAmount'] ?? json['minAmount'] ?? 0).toDouble(),
      toAmount: json['toAmount'] != null ? (json['toAmount']).toDouble() : null,
      deliveryCharge:
          (json['deliveryCharge'] ?? json['charge'] ?? 0).toDouble(),
      locationId: json['locationId']?.toString(),
      locationName: json['locationName']?.toString() ?? 'All Locations (HQ)',
      description: json['description']?.toString(),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) '_id': id,
      'fromAmount': fromAmount,
      'toAmount': toAmount,
      'deliveryCharge': deliveryCharge,
      'locationId': locationId,
      'locationName': locationName ?? 'All Locations (HQ)',
      'description': description,
      'isActive': isActive,
    };
  }

  DeliveryChargeModel copyWith({
    String? id,
    double? fromAmount,
    double? toAmount,
    double? deliveryCharge,
    String? locationId,
    String? locationName,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryChargeModel(
      id: id ?? this.id,
      fromAmount: fromAmount ?? this.fromAmount,
      toAmount: toAmount != null ? toAmount : this.toAmount,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<DeliveryChargeModel> defaultTiers() {
    return [
      DeliveryChargeModel(
        id: 'dc-tier-1',
        fromAmount: 0,
        toAmount: 399,
        deliveryCharge: 60,
        locationName: 'All Locations (HQ)',
        description: 'Standard delivery for small orders under ₹399',
        isActive: true,
      ),
      DeliveryChargeModel(
        id: 'dc-tier-2',
        fromAmount: 400,
        toAmount: 999,
        deliveryCharge: 100,
        locationName: 'All Locations (HQ)',
        description: 'Standard delivery for medium orders (₹400 - ₹999)',
        isActive: true,
      ),
      DeliveryChargeModel(
        id: 'dc-tier-3',
        fromAmount: 1000,
        toAmount: null,
        deliveryCharge: 0,
        locationName: 'All Locations (HQ)',
        description: 'Free Express delivery on orders ₹1,000 and above',
        isActive: true,
      ),
    ];
  }

  static double calculateFallback(double orderAmount) {
    if (orderAmount <= 0) return 0;
    if (orderAmount <= 399) return 60.0;
    if (orderAmount <= 999) return 100.0;
    return 0.0;
  }
}
