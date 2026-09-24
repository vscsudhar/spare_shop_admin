import 'location_models.dart';

class LocationInventoryItem {
  final String id;
  final String productId;
  final String productName;
  final String sku;
  final String category;
  final String brand;
  final String vehicleType;
  final double price;
  final String imageUrl;
  final int quantity;
  final String availabilityStatus; // 'IN_STOCK' or 'OUT_OF_STOCK'
  final DateTime? updatedAt;

  const LocationInventoryItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.sku,
    required this.category,
    required this.brand,
    required this.vehicleType,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.availabilityStatus,
    this.updatedAt,
  });

  bool get isInStock => quantity > 0;
  String get statusDisplay => isInStock ? 'In Stock' : 'Out of Stock';

  factory LocationInventoryItem.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] as num?)?.toInt() ?? 0;

    final rawStatus = json['availabilityStatus']?.toString();
    final status = (rawStatus != null && rawStatus.isNotEmpty)
        ? rawStatus
        : (qty > 0 ? 'IN_STOCK' : 'OUT_OF_STOCK');

    String prodId = (json['productId'] ?? '').toString();
    String prodName = (json['productName'] ?? '').toString();
    String sku = (json['sku'] ?? '').toString();
    String category = (json['category'] ?? '').toString();
    String brand = (json['brand'] ?? '').toString();
    String vehicleType = (json['vehicleType'] ?? '').toString();
    double price = (json['price'] as num?)?.toDouble() ?? 0.0;
    String imageUrl = (json['imageUrl'] ?? '').toString();

    if (json['productId'] is Map) {
      final p = json['productId'] as Map;
      prodId = (p['_id'] ?? p['id'] ?? prodId).toString();
      if (prodName.isEmpty && p['name'] != null) prodName = p['name'].toString();
      if (sku.isEmpty && p['sku'] != null) sku = p['sku'].toString();
      if (category.isEmpty && p['category'] != null) {
        category = p['category'] is Map
            ? (p['category']['name'] ?? p['category']['_id'] ?? '').toString()
            : p['category'].toString();
      }
      if (brand.isEmpty && p['brand'] != null) brand = p['brand'].toString();
      if (price == 0.0 && p['price'] != null) {
        price = (p['price'] as num?)?.toDouble() ?? 0.0;
      }
      if (imageUrl.isEmpty && p['imageUrl'] != null) {
        imageUrl = p['imageUrl'].toString();
      }
    }

    if (prodName.isEmpty) {
      prodName = 'Unknown Product';
    }

    return LocationInventoryItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      productId: prodId,
      productName: prodName,
      sku: sku,
      category: category,
      brand: brand,
      vehicleType: vehicleType,
      price: price,
      imageUrl: imageUrl,
      quantity: qty,
      availabilityStatus: status,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'sku': sku,
      'category': category,
      'brand': brand,
      'vehicleType': vehicleType,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'availabilityStatus': availabilityStatus,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  LocationInventoryItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? sku,
    String? category,
    String? brand,
    String? vehicleType,
    double? price,
    String? imageUrl,
    int? quantity,
    String? availabilityStatus,
    DateTime? updatedAt,
  }) {
    return LocationInventoryItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      sku: sku ?? this.sku,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      vehicleType: vehicleType ?? this.vehicleType,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LocationInventoryResponse {
  final LocationModel? location;
  final List<LocationInventoryItem> items;

  const LocationInventoryResponse({
    this.location,
    required this.items,
  });

  int get totalProducts => items.length;
  int get inStockCount => items.where((i) => i.isInStock).length;
  int get outOfStockCount => items.where((i) => !i.isInStock).length;

  factory LocationInventoryResponse.fromJson(dynamic json) {
    if (json is List) {
      return LocationInventoryResponse(
        location: null,
        items: json
            .whereType<Map>()
            .map((item) =>
                LocationInventoryItem.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
      );
    }

    if (json is! Map) {
      return const LocationInventoryResponse(items: []);
    }

    LocationModel? loc;
    if (json['location'] is Map) {
      loc = LocationModel.fromJson(
          Map<String, dynamic>.from(json['location'] as Map));
    }

    final rawItems = json['items'] ?? json['inventory'] ?? json['data'];
    final List<LocationInventoryItem> list = [];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          list.add(
              LocationInventoryItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    return LocationInventoryResponse(
      location: loc,
      items: list,
    );
  }
}
