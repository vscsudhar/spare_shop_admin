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
    String? parentId;
    String? parentName;

    final parent = json['parentCategory'];
    if (parent is Map) {
      parentId = (parent['_id'] ?? parent['id'] ?? '').toString();
      parentName = parent['name']?.toString();
    } else if (parent is String && parent.isNotEmpty) {
      parentId = parent;
    }

    return CategoryModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      icon: _getIconForCategory((json['name'] ?? '').toString()),
      slug: (json['slug'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      type: (json['type'] ?? 'Universal').toString(),
      active: json['active'] is bool ? json['active'] as bool : true,
      parentCategoryId: parentId,
      parentCategoryName: parentName,
      productCount: (json['productCount'] ?? json['productsCount'] ?? 0) is num
          ? ((json['productCount'] ?? json['productsCount'] ?? 0) as num)
              .toInt()
          : 0,
      image: json['image']?.toString(),
    );
  }

  static IconData _getIconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('engine')) return Icons.settings;
    if (lower.contains('brake')) return Icons.stop_circle;
    if (lower.contains('electrical') ||
        lower.contains('battery') ||
        lower.contains('plug') ||
        lower.contains('charge') ||
        lower.contains('wire')) {
      return Icons.electric_bolt;
    }
    if (lower.contains('suspension') || lower.contains('shock')) {
      return Icons.airline_seat_recline_extra;
    }
    if (lower.contains('body') ||
        lower.contains('frame') ||
        lower.contains('chassis')) {
      return Icons.directions_bike;
    }
    if (lower.contains('wheel') ||
        lower.contains('tyre') ||
        lower.contains('tire')) {
      return Icons.radio_button_checked;
    }
    if (lower.contains('filter') ||
        lower.contains('oil') ||
        lower.contains('fluid')) {
      return Icons.opacity;
    }
    if (lower.contains('light') ||
        lower.contains('headlight') ||
        lower.contains('tail')) {
      return Icons.lightbulb_outline;
    }
    return Icons.category_rounded;
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
    final compatibilitiesList = (json['compatibleVehicles'] ??
            json['compatibilities']) as List<dynamic>? ??
        [];
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
        } else if (modelType == 'petrol' || bName.toLowerCase() == 'honda') {
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
    String addr = json['addressLine']?.toString() ?? '';
    if (addr.isEmpty) {
      final parts = [
        json['addressLine1'],
        json['addressLine2'],
        json['city'],
        json['state'],
        json['postalCode']
      ]
          .where((p) => p != null && p.toString().trim().isNotEmpty)
          .map((p) => p.toString().trim())
          .toList();
      addr = parts.join(', ');
    }

    return AddressModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['recipientName'] ?? json['name'] ?? 'Customer').toString(),
      phone: (json['phone'] ?? '').toString(),
      addressLine: addr,
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

    final rawItemsList = json['items'];
    final List<dynamic> itemsList = rawItemsList is List ? rawItemsList : [];
    final items = itemsList.map((item) {
      if (item is! Map) {
        return const CartItemModel(
          id: '',
          product: ProductModel(
            id: '',
            name: 'Item',
            price: 0,
            originalPrice: 0,
            rating: 5,
            description: '',
            categoryId: '',
            fitmentBadge: 'Universal Fit',
          ),
          quantity: 1,
        );
      }
      final itemMap = Map<String, dynamic>.from(item);

      final Map<String, dynamic> productMap = itemMap['productSnapshot'] is Map
          ? Map<String, dynamic>.from(itemMap['productSnapshot'] as Map)
          : <String, dynamic>{};

      if (itemMap['product'] is Map) {
        final pMap = Map<String, dynamic>.from(itemMap['product'] as Map);
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
      } else if (itemMap['product'] != null) {
        productMap['_id'] = itemMap['product'].toString();
      }

      return CartItemModel(
        id: (itemMap['_id'] ?? itemMap['id'] ?? '').toString(),
        product: ProductModelExtension.fromJson(productMap),
        quantity: itemMap['quantity'] is num
            ? (itemMap['quantity'] as num).toInt()
            : 1,
      );
    }).toList();

    final Map<String, dynamic> addressMap = json['shippingAddress'] is Map
        ? Map<String, dynamic>.from(json['shippingAddress'] as Map)
        : (json['address'] is Map
            ? Map<String, dynamic>.from(json['address'] as Map)
            : <String, dynamic>{});

    double orderTotal = 0.0;
    final rawTotal = json['grandTotal'] ?? json['total'];
    if (rawTotal is num) {
      orderTotal =
          rawTotal > 1000 ? (rawTotal.toDouble() / 100.0) : rawTotal.toDouble();
    }

    String? locationId;
    String? locationName;

    // Check top-level json
    if (json['locationId'] is Map) {
      locationId =
          (json['locationId']['_id'] ?? json['locationId']['id'])?.toString();
      locationName = json['locationId']['name']?.toString();
    } else if (json['locationId'] != null) {
      locationId = json['locationId'].toString();
    } else if (json['location'] is Map) {
      locationId =
          (json['location']['_id'] ?? json['location']['id'])?.toString();
      locationName = json['location']['name']?.toString();
    } else if (json['location'] != null) {
      locationId = json['location'].toString();
    }

    // Check hub / assignedHub keys on order root
    if (locationId == null || locationId.isEmpty) {
      if (json['hub'] is Map) {
        locationId = (json['hub']['_id'] ?? json['hub']['id'])?.toString();
        locationName ??= json['hub']['name']?.toString();
      } else if (json['hubId'] != null) {
        locationId = json['hubId'].toString();
      } else if (json['assignedHub'] is Map) {
        locationId = (json['assignedHub']['_id'] ?? json['assignedHub']['id'])
            ?.toString();
        locationName ??= json['assignedHub']['name']?.toString();
      } else if (json['hubLocation'] is Map) {
        locationId = (json['hubLocation']['_id'] ?? json['hubLocation']['id'])
            ?.toString();
        locationName ??= json['hubLocation']['name']?.toString();
      }
    }

    // Check shippingAddress / address object for locationId or hub assignments
    if (locationId == null || locationId.isEmpty) {
      if (addressMap['locationId'] != null) {
        locationId = addressMap['locationId'].toString();
      } else if (addressMap['location'] is Map) {
        locationId =
            (addressMap['location']['_id'] ?? addressMap['location']['id'])
                ?.toString();
        locationName ??= addressMap['location']['name']?.toString();
      } else if (addressMap['location'] != null) {
        locationId = addressMap['location'].toString();
      } else if (addressMap['hub'] is Map) {
        locationId =
            (addressMap['hub']['_id'] ?? addressMap['hub']['id'])?.toString();
        locationName ??= addressMap['hub']['name']?.toString();
      } else if (addressMap['assignedHub'] is Map) {
        locationId = (addressMap['assignedHub']['_id'] ??
                addressMap['assignedHub']['id'])
            ?.toString();
        locationName ??= addressMap['assignedHub']['name']?.toString();
      } else if (addressMap['hubLocation'] is Map) {
        locationId = (addressMap['hubLocation']['_id'] ??
                addressMap['hubLocation']['id'])
            ?.toString();
        locationName ??= addressMap['hubLocation']['name']?.toString();
      }
    }

    // Extract location name if not already found
    if (locationName == null || locationName.isEmpty) {
      if (json['locationName'] != null &&
          json['locationName'].toString().isNotEmpty) {
        locationName = json['locationName'].toString();
      } else if (json['hubName'] != null &&
          json['hubName'].toString().isNotEmpty) {
        locationName = json['hubName'].toString();
      } else if (addressMap['locationName'] != null &&
          addressMap['locationName'].toString().isNotEmpty) {
        locationName = addressMap['locationName'].toString();
      } else if (addressMap['serviceHub'] != null &&
          addressMap['serviceHub'].toString().isNotEmpty) {
        locationName = addressMap['serviceHub'].toString();
      } else if (addressMap['nearHub'] != null &&
          addressMap['nearHub'].toString().isNotEmpty) {
        locationName = addressMap['nearHub'].toString();
      } else if (addressMap['nearestHub'] != null &&
          addressMap['nearestHub'].toString().isNotEmpty) {
        locationName = addressMap['nearestHub'].toString();
      }
    }

    final rawChannel = (json['channel'] ?? '').toString().toLowerCase().trim();
    String channel = 'app';
    if (rawChannel == 'pos' ||
        rawChannel == 'in_store' ||
        rawChannel == 'store_pos' ||
        rawChannel == 'store') {
      channel = 'pos';
    } else if (rawChannel == 'app' ||
        rawChannel == 'online' ||
        rawChannel == 'mobile' ||
        rawChannel == 'mobile_app') {
      channel = 'app';
    } else {
      // Heuristic fallback for orders without explicit channel property
      final orderNumber = (json['orderNumber'] ?? '').toString().toUpperCase();
      final street = (addressMap['addressLine1'] ??
              addressMap['street'] ??
              addressMap['address'] ??
              '')
          .toString()
          .toUpperCase();
      final recipient =
          (addressMap['recipientName'] ?? addressMap['name'] ?? '')
              .toString()
              .toUpperCase();
      if (orderNumber.contains('POS') ||
          street.contains('POS') ||
          street.contains('STORE COUNTER') ||
          recipient.contains('WALK-IN')) {
        channel = 'pos';
      } else {
        channel = 'app';
      }
    }

    return OrderModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      orderNumber: (json['orderNumber'] ?? '').toString(),
      date: DateTime.tryParse(
              (json['createdAt'] ?? json['date'] ?? '').toString()) ??
          DateTime.now(),
      status: status,
      items: items,
      total: orderTotal,
      address: AddressModelExtension.fromJson(addressMap),
      paymentMethod: (json['paymentMethod'] ?? 'cod').toString(),
      locationId: locationId,
      locationName: locationName,
      channel: channel,
    );
  }
}

extension RareQuotationModelExtension on RareQuotationModel {
  static RareQuotationModel fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final partName = itemsList.isNotEmpty
        ? (itemsList[0]['name'] ?? itemsList[0]['partName'] ?? '')
        : (json['partName'] ?? '');

    double parsePrice(dynamic val) {
      if (val == null) return 0.0;
      final num n = (val is num) ? val : (num.tryParse(val.toString()) ?? 0);
      final double d = n.toDouble();
      if (d <= 0) return 0.0;

      // If stored in paise (>= 10000, e.g. 120000 paise = ₹1200, 130000 paise = ₹1300)
      if (d >= 10000) {
        return d / 100.0;
      }
      // If stored directly in rupees (e.g. 1200, 1300, 1500) where dividing by 100 would produce 12, 13, 15
      if (d >= 100) {
        return d;
      }
      return d;
    }

    final double price = parsePrice(json['subTotal'] ??
        (itemsList.isNotEmpty ? itemsList[0]['unitPrice'] : null) ??
        json['price']);
    final double shipping =
        parsePrice(json['deliveryFee'] ?? json['shippingCharge']);
    final double gst = parsePrice(json['taxAmount'] ?? json['gst']);
    final double discount = parsePrice(json['discount']);
    double grandTotal = parsePrice(json['grandTotal']);

    if (grandTotal == 0 && price > 0) {
      grandTotal = price + shipping + gst - discount;
    }

    return RareQuotationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      partName: partName.toString(),
      price: price,
      shippingCharge: shipping,
      gst: gst,
      discount: discount,
      grandTotal: grandTotal,
      deliveryTimeline: (json['deliveryTimeline'] ?? '3-5 Days').toString(),
      expiryDate:
          DateTime.tryParse(json['expiresAt'] ?? json['expiryDate'] ?? '') ??
              DateTime.now().add(const Duration(days: 7)),
      adminNotes: json['adminNotes']?.toString(),
      status: (json['status'] ?? 'pending').toString(),
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
    if (json['vehicle'] is Map) {
      final vMap = Map<String, dynamic>.from(json['vehicle'] as Map);
      vehicle = VehicleModelExtension.fromJson(vMap);
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

    RareQuotationModel? quotation;
    if (json['activeQuotation'] is Map) {
      quotation = RareQuotationModelExtension.fromJson(
        Map<String, dynamic>.from(json['activeQuotation'] as Map),
      );
    }

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
      final uMap = json['user'];
      cName = (uMap['name'] ?? '').toString();
      cPhone = (uMap['phone'] ?? '').toString();
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
      quantity: json['quantity'] is num ? (json['quantity'] as num).toInt() : 1,
      urgency: (json['urgency'] ?? 'medium').toString(),
      budget: json['budget'] != null && json['budget'] is num
          ? ((json['budget'] as num) / 100.0)
          : null,
      images: imageList,
      notes: json['notes']?.toString(),
      status: status,
      date: DateTime.tryParse(
              (json['createdAt'] ?? json['requestedAt'] ?? json['date'] ?? '')
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
      locationId: (json['locationId'] ??
              (json['location'] is Map
                  ? json['location']['_id'] ?? json['location']['id']
                  : null))
          ?.toString(),
      locationName: (json['locationName'] ??
              (json['location'] is Map ? json['location']['name'] : null))
          ?.toString(),
      channel: (json['channel'] ?? 'online').toString(),
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

    RareQuotationModel? quotation;
    if (json['quotation'] is Map) {
      quotation = RareQuotationModelExtension.fromJson(
        Map<String, dynamic>.from(json['quotation'] as Map),
      );
    }

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
