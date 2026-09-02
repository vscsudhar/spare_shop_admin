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

    final brandVal = json['brand'];
    String brandId = '';
    String brandName = '';
    if (brandVal is Map) {
      brandId = (brandVal['_id'] ?? brandVal['id'] ?? '').toString();
      brandName = (brandVal['name'] ?? '').toString();
    } else {
      brandId = brandVal?.toString() ?? '';
      brandName = brandId;
    }

    return VehicleModel(
      id: json['_id'] ?? json['id'] ?? '',
      brand: brandName,
      brandId: brandId,
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

    final fitType = (json['fitType'] ?? 'vehicle_specific').toString();
    final stockManaged = json['stockManaged'] ?? true;
    final compatibilitiesList = (json['compatibleVehicles'] ?? json['compatibilities']) as List<dynamic>? ?? [];
    final List<CompatibleVehicleEntry> compatibleVehicles = [];
    final List<String> compatibleIds = [];
    String typeTag = 'Universal'; // EV, Petrol, Universal

    for (var comp in compatibilitiesList) {
      if (comp is Map) {
        final brandMap = comp['brand'];
        final modelMap = comp['model'];
        String bId = '';
        String bName = '';
        String mId = '';
        String mName = '';

        if (brandMap is Map) {
          bId = (brandMap['_id'] ?? brandMap['id'] ?? '').toString();
          bName = (brandMap['name'] ?? '').toString();
        } else if (brandMap is String) {
          bId = brandMap;
          bName = brandMap;
        }

        if (modelMap is Map) {
          mId = (modelMap['_id'] ?? modelMap['id'] ?? '').toString();
          mName = (modelMap['name'] ?? '').toString();
        } else if (modelMap is String) {
          mId = modelMap;
          mName = modelMap;
        }

        if (bId.isNotEmpty || mId.isNotEmpty) {
          compatibleVehicles.add(CompatibleVehicleEntry(
            brandId: bId,
            brandName: bName,
            modelId: mId,
            modelName: mName,
          ));
        }
        if (mId.isNotEmpty) {
          compatibleIds.add(mId);
        }

        final modelType =
            modelMap is Map ? modelMap['type']?.toString().toLowerCase() : '';
        if (modelType == 'ev' ||
            bName.toLowerCase() == 'ola' ||
            bName.toLowerCase() == 'ather') {
          typeTag = 'EV';
        } else if (modelType == 'petrol' ||
            bName.toLowerCase() == 'honda') {
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

    // Determine badge format per requirement 21:
    // Universal example: Universal Fit
    // Vehicle-specific example: Ola • S1X Gen 3
    // Multiple: Ola S1X Gen 3 +2 more
    String fitmentBadge = 'Universal Fit';
    if (fitType == 'universal' || compatibleVehicles.isEmpty) {
      fitmentBadge = 'Universal Fit';
    } else {
      final first = compatibleVehicles.first;
      final String firstText;
      if (first.brandName.isNotEmpty && first.modelName.isNotEmpty) {
        firstText = '${first.brandName} • ${first.modelName}';
      } else if (first.modelName.isNotEmpty) {
        firstText = first.modelName;
      } else {
        firstText = first.brandName;
      }

      if (compatibleVehicles.length == 1) {
        fitmentBadge = firstText;
      } else {
        fitmentBadge = '$firstText +${compatibleVehicles.length - 1} more';
      }
    }

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
      fitType: fitType,
      stockManaged: stockManaged,
      compatibleVehicles: compatibleVehicles,
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
    if (statusString == 'shipped' || statusString == 'out_for_delivery') {
      status = OrderStatus.shipped;
    } else if (statusString == 'delivered') {
      status = OrderStatus.delivered;
    } else if (statusString == 'cancelled' || statusString == 'returned') {
      status = OrderStatus.cancelled;
    } else {
      status = OrderStatus.processing;
    }

    final itemsList = json['items'] as List<dynamic>? ?? [];
    final items = itemsList.map((item) {
      final productMap = item['productSnapshot'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(item['productSnapshot'])
          : (item['productSnapshot'] is Map
              ? Map<String, dynamic>.from(item['productSnapshot'] as Map)
              : <String, dynamic>{});

      if (item['product'] is Map) {
        final pMap = item['product'] as Map<String, dynamic>;
        productMap['_id'] = (pMap['_id'] ?? pMap['id'] ?? '').toString();
        if (!productMap.containsKey('name') || productMap['name'] == null) {
          productMap['name'] = pMap['name'];
        }
        if (!productMap.containsKey('sellingPrice') ||
            productMap['sellingPrice'] == null) {
          productMap['sellingPrice'] = pMap['sellingPrice'];
        }
        if (!productMap.containsKey('images') || productMap['images'] == null) {
          productMap['images'] = pMap['images'];
        }
      } else if (item['product'] != null) {
        productMap['_id'] = item['product'].toString();
      }

      return CartItemModel(
        id: (item['_id'] ?? item['id'] ?? '').toString(),
        product: ProductModelExtension.fromJson(productMap),
        quantity: item['quantity'] is num ? (item['quantity'] as num).toInt() : 1,
      );
    }).toList();

    final addressMap = json['shippingAddress'] as Map<String, dynamic>? ?? {};

    double orderTotal = 0.0;
    final rawTotal = json['grandTotal'] ?? json['total'];
    if (rawTotal is num) {
      orderTotal = rawTotal.toDouble();
    }

    return OrderModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      orderNumber: (json['orderNumber'] ?? '').toString(),
      date: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      status: status,
      items: items,
      total: orderTotal,
      address: AddressModelExtension.fromJson(addressMap),
      paymentMethod: json['paymentMethod'] ?? 'cod',
    );
  }
}

extension RareQuotationModelExtension on RareQuotationModel {
  static RareQuotationModel fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final partName = itemsList.isNotEmpty
        ? (itemsList[0]['name'] ?? itemsList[0]['partName'] ?? '')
        : (json['partName'] ?? '');

    return RareQuotationModel(
      id: json['_id'] ?? json['id'] ?? '',
      partName: partName,
      price: (json['subTotal'] ?? 0) / 100.0,
      shippingCharge:
          (json['deliveryFee'] ?? json['shippingCharge'] ?? 0) / 100.0,
      gst: (json['taxAmount'] ?? json['gst'] ?? 0) / 100.0,
      discount: (json['discount'] ?? 0) / 100.0,
      grandTotal: (json['grandTotal'] ?? 0) / 100.0,
      deliveryTimeline: json['deliveryTimeline'] ?? '3-5 Days',
      expiryDate:
          DateTime.tryParse(json['expiresAt'] ?? json['expiryDate'] ?? '') ??
              DateTime.now().add(const Duration(days: 7)),
      adminNotes: json['adminNotes'],
      status: json['status'] ?? 'pending',
    );
  }
}

extension RareProductRequestModelExtension on RareProductRequestModel {
  static RareProductRequestModel fromJson(Map<String, dynamic> json) {
    final statusString =
        (json['status'] ?? 'submitted').toString().toLowerCase().trim();
    RareRequestStatus status = RareRequestStatus.submitted;
    if (statusString == 'searching') {
      status = RareRequestStatus.searching;
    } else if (statusString == 'found') {
      status = RareRequestStatus.found;
    } else if (statusString == 'quotation_sent' ||
        statusString == 'quotationsent') {
      status = RareRequestStatus.quotationSent;
    } else if (statusString == 'negotiation') {
      status = RareRequestStatus.negotiation;
    } else if (statusString == 'approved') {
      status = RareRequestStatus.approved;
    } else if (statusString == 'cancelled') {
      status = RareRequestStatus.cancelled;
    } else if (statusString == 'converted_to_order' ||
        statusString == 'convertedtoorder') {
      status = RareRequestStatus.convertedToOrder;
    } else {
      // Handles 'pending', 'open', or any legacy/unrecognized status gracefully
      status = RareRequestStatus.submitted;
    }

    // Safely extract vehicle info whether nested in `vehicle` map or at top level
    VehicleModel vehicle;
    if (json['vehicle'] is Map<String, dynamic>) {
      vehicle = VehicleModelExtension.fromJson(
          json['vehicle'] as Map<String, dynamic>);
    } else {
      final typeString = (json['vehicleType'] ?? json['type'] ?? 'universal')
          .toString()
          .toLowerCase();
      final type =
          typeString.contains('ev') ? VehicleType.ev : VehicleType.petrol;
      vehicle = VehicleModel(
        id: (json['vehicleId'] ?? '').toString(),
        brand: (json['vehicleBrand'] ?? json['brand'] ?? '').toString(),
        name: (json['vehicleModel'] ?? json['model'] ?? '').toString(),
        year: (json['vehicleYear'] ?? json['year'] ?? '').toString(),
        type: type,
      );
    }

    final quotationJson = json['activeQuotation'] as Map<String, dynamic>?;
    final quotation = quotationJson != null
        ? RareQuotationModelExtension.fromJson(quotationJson)
        : null;

    final rawImages = json['images'];
    final List<String> imageList = [];
    if (rawImages is List) {
      for (final im in rawImages) {
        if (im is Map) {
          final url = (im['url'] ?? '').toString();
          if (url.isNotEmpty) imageList.add(url);
        } else if (im != null) {
          final s = im.toString();
          if (s.isNotEmpty) imageList.add(s);
        }
      }
    }

    // Customer / User info mapping
    String cName = '';
    String cPhone = '';
    if (json['user'] is Map) {
      cName = (json['user']['name'] ?? '').toString();
      cPhone = (json['user']['phone'] ?? '').toString();
    }
    if (cName.isEmpty) {
      cName = (json['customerName'] ?? json['customer'] ?? '').toString();
    }
    if (cPhone.isEmpty) {
      cPhone = (json['customerPhone'] ?? json['phone'] ?? '').toString();
    }

    final title = (json['title'] ??
            json['productName'] ??
            json['partName'] ??
            'Rare Spare Part')
        .toString();
    final desc = (json['description'] ?? json['notes'] ?? '').toString();

    return RareProductRequestModel(
      id: (json['_id'] ?? json['id'] ?? json['ticketId'] ?? '').toString(),
      customerName: cName.isNotEmpty ? cName : 'Customer',
      phone: cPhone,
      vehicle: vehicle,
      partName: title,
      description: desc,
      quantity:
          json['quantity'] is num ? (json['quantity'] as num).toInt() : 1,
      urgency: (json['urgency'] ?? 'medium').toString(),
      budget: json['budget'] != null && json['budget'] is num
          ? ((json['budget'] as num) / 100.0)
          : null,
      images: imageList,
      notes: json['notes']?.toString(),
      status: status,
      date: DateTime.tryParse((json['createdAt'] ??
                  json['requestedAt'] ??
                  json['date'] ??
                  '')
              .toString()) ??
          DateTime.now(),
      quotation: quotation,
      cancellationReason: json['cancellationReason']?.toString() ??
          (json['cancellation'] is Map
              ? json['cancellation']['reason']?.toString()
              : null),
      orderId: json['convertedOrder'] is Map
          ? (json['convertedOrder']['orderNumber'] ??
              json['convertedOrder']['_id']?.toString())
          : (json['convertedOrder']?.toString() ?? json['orderId']?.toString()),
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

    final readByList =
        (json['readBy'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
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
