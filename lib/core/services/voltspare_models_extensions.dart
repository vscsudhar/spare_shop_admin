import 'package:flutter/material.dart';
import 'package:spare_shop_admin/ui/common/voltspare_models.dart';

// Extension methods to serialize and deserialize backend JSON data to UI Models

extension VehicleBrandModelExtension on VehicleBrandModel {
  static VehicleBrandModel fromJson(Map<String, dynamic> json) {
    return VehicleBrandModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      logoAsset: json['logo'] ?? json['logoAsset'],
    );
  }
}

extension VehicleModelExtension on VehicleModel {
  static VehicleModel fromJson(Map<String, dynamic> json) {
    final typeString = (json['type'] ?? 'Universal').toString().toLowerCase();
    final type =
        typeString.contains('ev') ? VehicleType.ev : VehicleType.petrol;

    return VehicleModel(
      id: json['_id'] ?? json['id'] ?? '',
      brand: json['brand'] ?? '',
      name: json['name'] ?? '',
      year: json['year']?.toString() ?? '',
      type: type,
    );
  }
}

extension CategoryModelExtension on CategoryModel {
  static CategoryModel fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      icon: _getIconForCategory(json['name'] ?? ''),
    );
  }

  static IconData _getIconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('engine')) return Icons.settings;
    if (lower.contains('brake')) return Icons.stop_circle;
    if (lower.contains('electrical') ||
        lower.contains('battery') ||
        lower.contains('plug')) {
      return Icons.electric_bolt;
    }
    if (lower.contains('body')) return Icons.directions_bike;
    return Icons.build;
  }
}

extension ProductModelExtension on ProductModel {
  static ProductModel fromJson(Map<String, dynamic> json) {
    // backend sellingPrice is in paise (int). UI expects double in rupees.
    final pricePaise = json['sellingPrice'] ?? 0;
    final mrpPaise = json['mrp'] ?? pricePaise;
    final purchasePricePaise = json['purchasePrice'] ?? 0;
    final taxPercentageVal = (json['taxPercentage'] ?? 18.0).toDouble();

    final imageList = json['images'] as List<dynamic>? ?? [];
    final String? imageAsset = imageList.isNotEmpty
        ? (imageList[0] is Map ? imageList[0]['url'] : imageList[0] as String?)
        : null;

    final categoryMap = json['category'];
    String categoryId = '';
    String categoryName = '';
    if (categoryMap is Map) {
      categoryId = categoryMap['_id'] ?? categoryMap['id'] ?? '';
      categoryName = categoryMap['name'] ?? '';
    } else {
      categoryId = categoryMap?.toString() ?? '';
    }

    final compatibilitiesList = json['compatibilities'] as List<dynamic>? ?? [];
    final List<String> compatibleIds = [];
    String fitmentText = '';
    String typeTag = 'Universal'; // EV, Petrol, Universal

    for (var comp in compatibilitiesList) {
      if (comp is Map) {
        final brandMap = comp['brand'];
        final modelMap = comp['model'];
        final brandName = brandMap is Map ? brandMap['name'] : '';
        final modelName = modelMap is Map ? modelMap['name'] : '';
        final modelId =
            modelMap is Map ? (modelMap['_id'] ?? modelMap['id'] ?? '') : '';
        if (modelId.isNotEmpty) {
          compatibleIds.add(modelId.toString());
        }

        if (fitmentText.isEmpty) {
          if (brandName != null &&
              brandName.isNotEmpty &&
              modelName != null &&
              modelName.isNotEmpty) {
            fitmentText = '$brandName $modelName';
          } else if (modelName != null && modelName.isNotEmpty) {
            fitmentText = modelName;
          }
        }

        final modelType =
            modelMap is Map ? modelMap['type']?.toString().toLowerCase() : '';
        if (modelType == 'ev' ||
            brandName?.toString().toLowerCase() == 'ola' ||
            brandName?.toString().toLowerCase() == 'ather') {
          typeTag = 'EV';
        } else if (modelType == 'petrol' ||
            brandName?.toString().toLowerCase() == 'honda') {
          typeTag = 'Petrol';
        }
      }
    }

    // Fallback: Check category name for type detection if compatibilities didn't specify it
    if (typeTag == 'Universal' && categoryName.isNotEmpty) {
      final catLower = categoryName.toLowerCase();
      if (catLower.contains('electrical') || catLower.contains('ev')) {
        typeTag = 'EV';
      } else if (catLower.contains('engine') || catLower.contains('petrol')) {
        typeTag = 'Petrol';
      }
    }

    // Fallback: Check brand field
    if (typeTag == 'Universal') {
      final brandLower = (json['brand'] ?? '').toString().toLowerCase();
      if (brandLower.contains('ola') || brandLower.contains('ather')) {
        typeTag = 'EV';
      } else if (brandLower.contains('honda') ||
          brandLower.contains('activa')) {
        typeTag = 'Petrol';
      }
    }

    final fitmentBadge = fitmentText.isNotEmpty ? fitmentText : 'Universal Fit';

    return ProductModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      price: pricePaise / 100.0,
      originalPrice: mrpPaise / 100.0,
      rating: (json['rating'] ?? 4.5).toDouble(),
      description: json['description'] ?? '',
      categoryId: categoryId,
      isFavorite: json['isFavorite'] ?? false,
      compatibleVehicleIds: compatibleIds,
      fitmentBadge: fitmentBadge,
      imageAsset: imageAsset,
      stockCount: json['currentStock'] ?? 0,
      purchasePrice: purchasePricePaise / 100.0,
      taxPercentage: taxPercentageVal,
      vehicleType: typeTag,
      locationBin: json['locationBin'],
    );
  }
}

extension CartItemModelExtension on CartItemModel {
  static CartItemModel fromJson(Map<String, dynamic> json) {
    final productMap = json['product'] as Map<String, dynamic>? ?? {};
    return CartItemModel(
      id: json['_id'] ?? json['id'] ?? '',
      product: ProductModelExtension.fromJson(productMap),
      quantity: json['quantity'] ?? 1,
    );
  }
}

extension AddressModelExtension on AddressModel {
  static AddressModel fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      addressLine: json['addressLine'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'addressLine': addressLine,
      'isDefault': isDefault,
    };
  }
}

extension OrderModelExtension on OrderModel {
  static OrderModel fromJson(Map<String, dynamic> json) {
    final statusString = (json['status'] ?? 'pending').toString().toLowerCase();
    OrderStatus status = OrderStatus.processing;
    if (statusString == 'shipped') {
      status = OrderStatus.shipped;
    } else if (statusString == 'delivered') {
      status = OrderStatus.delivered;
    } else if (statusString == 'cancelled') {
      status = OrderStatus.cancelled;
    }

    final itemsList = json['items'] as List<dynamic>? ?? [];
    final items = itemsList.map((item) {
      final productMap = item['productSnapshot'] ?? {};
      productMap['_id'] = item['product']; // Map product ID correctly
      return CartItemModel(
        id: item['_id'] ?? item['id'] ?? '',
        product: ProductModelExtension.fromJson(productMap),
        quantity: item['quantity'] ?? 1,
      );
    }).toList();

    final addressMap = json['shippingAddress'] as Map<String, dynamic>? ?? {};

    return OrderModel(
      id: json['_id'] ?? json['id'] ?? '',
      orderNumber: json['orderNumber'] ?? '',
      date: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      status: status,
      items: items,
      total: (json['grandTotal'] ?? 0) / 100.0,
      address: AddressModelExtension.fromJson(addressMap),
      paymentMethod: json['paymentMethod'] ?? 'cod',
    );
  }
}

extension RareQuotationModelExtension on RareQuotationModel {
  static RareQuotationModel fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final partName =
        itemsList.isNotEmpty ? (itemsList[0]['partName'] ?? '') : '';

    return RareQuotationModel(
      id: json['_id'] ?? json['id'] ?? '',
      partName: partName,
      price: (json['subTotal'] ?? 0) / 100.0,
      shippingCharge: (json['shippingCharge'] ?? 0) / 100.0,
      gst: (json['gst'] ?? 0) / 100.0,
      discount: (json['discount'] ?? 0) / 100.0,
      grandTotal: (json['grandTotal'] ?? 0) / 100.0,
      deliveryTimeline: json['deliveryTimeline'] ?? '3-5 Days',
      expiryDate: DateTime.tryParse(json['expiryDate'] ?? '') ??
          DateTime.now().add(const Duration(days: 7)),
      adminNotes: json['adminNotes'],
      status: json['status'] ?? 'pending',
    );
  }
}

extension RareProductRequestModelExtension on RareProductRequestModel {
  static RareProductRequestModel fromJson(Map<String, dynamic> json) {
    final statusString = (json['status'] ?? 'submitted').toString();
    RareRequestStatus status = RareRequestStatus.submitted;
    if (statusString == 'searching') {
      status = RareRequestStatus.searching;
    } else if (statusString == 'found') {
      status = RareRequestStatus.found;
    } else if (statusString == 'quotation_sent') {
      status = RareRequestStatus.quotationSent;
    } else if (statusString == 'negotiation') {
      status = RareRequestStatus.negotiation;
    } else if (statusString == 'approved') {
      status = RareRequestStatus.approved;
    } else if (statusString == 'cancelled') {
      status = RareRequestStatus.cancelled;
    } else if (statusString == 'converted_to_order') {
      status = RareRequestStatus.convertedToOrder;
    }

    final vehicleJson = json['vehicle'] as Map<String, dynamic>? ?? {};
    final vehicle = VehicleModelExtension.fromJson(vehicleJson);

    final quotationJson = json['activeQuotation'] as Map<String, dynamic>?;
    final quotation = quotationJson != null
        ? RareQuotationModelExtension.fromJson(quotationJson)
        : null;

    final imageList = json['images'] as List<dynamic>? ?? [];

    return RareProductRequestModel(
      id: json['_id'] ?? json['id'] ?? '',
      customerName: json['user'] is Map ? (json['user']['name'] ?? '') : '',
      phone: json['user'] is Map ? (json['user']['phone'] ?? '') : '',
      vehicle: vehicle,
      partName: json['title'] ?? '',
      description: json['description'] ?? '',
      quantity: json['quantity'] ?? 1,
      urgency: json['urgency'] ?? 'medium',
      budget: json['budget'] != null ? (json['budget'] / 100.0) : null,
      images: imageList
          .map((im) => im is Map ? (im['url'] ?? '').toString() : im.toString())
          .toList(),
      notes: json['notes'],
      status: status,
      date: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      quotation: quotation,
      cancellationReason: json['cancellationReason'],
      orderId: json['orderId'],
    );
  }
}

extension RareChatMessageModelExtension on RareChatMessageModel {
  static RareChatMessageModel fromJson(Map<String, dynamic> json) {
    final senderString = (json['senderType'] ?? 'system').toString();
    RareChatSender sender = RareChatSender.system;
    if (senderString == 'customer') {
      sender = RareChatSender.customer;
    } else if (senderString == 'admin') {
      sender = RareChatSender.admin;
    }

    final typeString = (json['messageType'] ?? 'text').toString();
    RareChatMessageType messageType = RareChatMessageType.text;
    if (typeString == 'image') {
      messageType = RareChatMessageType.image;
    } else if (typeString == 'quotation') {
      messageType = RareChatMessageType.quotation;
    } else if (typeString == 'status_update') {
      messageType = RareChatMessageType.statusUpdate;
    } else if (typeString == 'product_found') {
      messageType = RareChatMessageType.productFound;
    }

    final imagesList =
        json['imageUrl'] != null ? [json['imageUrl'].toString()] : <String>[];

    final quotationMap = json['quotation'] as Map<String, dynamic>?;
    final quotation = quotationMap != null
        ? RareQuotationModelExtension.fromJson(quotationMap)
        : null;

    final readByList = (json['readBy'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];
    final receivedByList = (json['receivedBy'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>[];

    return RareChatMessageModel(
      id: json['_id'] ?? json['id'] ?? '',
      message: json['message'] ?? '',
      sender: sender,
      timestamp: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      messageType: messageType,
      images: imagesList,
      quotation: quotation,
      readBy: readByList,
      receivedBy: receivedByList,
    );
  }
}

extension SupplierModelExtension on SupplierModel {
  static SupplierModel fromJson(Map<String, dynamic> json) {
    final compList = json['categories'] as List<dynamic>? ?? [];
    final List<String> cats = compList.map((c) => c.toString()).toList();

    // Map vehicleCategories array to EV/Petrol flags
    final List<dynamic> vehicleCats = json['vehicleCategories'] ?? [];
    final suppliesEv =
        vehicleCats.contains('EV') || vehicleCats.contains('Universal');
    final suppliesPetrol =
        vehicleCats.contains('Petrol') || vehicleCats.contains('Universal');

    // Extract first contact person
    final contactsList = json['contacts'] as List<dynamic>? ?? [];
    final firstContact = contactsList.isNotEmpty ? contactsList.first : {};
    final contactPersonName = firstContact['name'] ?? '';

    return SupplierModel(
      id: json['_id'] ?? json['id'] ?? '',
      companyName: json['name'] ?? '',
      contactPerson: contactPersonName,
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      gstNumber: json['gstNumber'] ?? '',
      categories: cats,
      suppliesEvParts: suppliesEv,
      suppliesPetrolParts: suppliesPetrol,
      isActive: json['status'] == 'active',
      outstandingAmountInPaise: json['outstandingBalance'] ?? 0,
      lastPurchaseDate: DateTime.tryParse(json['updatedAt'] ?? ''),
    );
  }
}
