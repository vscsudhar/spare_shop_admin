class AdminNotificationItem {
  final String id;
  final String title;
  final String message;
  final String? image;
  final String type;
  final String targetAudience;
  final bool read;
  final DateTime? createdAt;
  final NotificationRecipient? user;
  final NotificationSender? sentBy;
  final String? referenceId;
  final String? referenceType;

  AdminNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    this.image,
    required this.type,
    this.targetAudience = 'individual',
    this.read = false,
    this.createdAt,
    this.user,
    this.sentBy,
    this.referenceId,
    this.referenceType,
  });

  factory AdminNotificationItem.fromJson(Map<String, dynamic> json) {
    NotificationRecipient? userObj;
    if (json['user'] is Map<String, dynamic>) {
      userObj = NotificationRecipient.fromJson(json['user']);
    }

    NotificationSender? senderObj;
    if (json['sentBy'] is Map<String, dynamic>) {
      senderObj = NotificationSender.fromJson(json['sentBy']);
    }

    DateTime? parsedDate;
    if (json['createdAt'] != null) {
      parsedDate = DateTime.tryParse(json['createdAt'].toString());
    }

    return AdminNotificationItem(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Notification',
      message: json['message']?.toString() ?? '',
      image: json['image']?.toString(),
      type: json['type']?.toString() ?? 'promotional',
      targetAudience: json['targetAudience']?.toString() ?? 'individual',
      read: json['read'] == true,
      createdAt: parsedDate,
      user: userObj,
      sentBy: senderObj,
      referenceId: json['referenceId']?.toString(),
      referenceType: json['referenceType']?.toString(),
    );
  }
}

class NotificationRecipient {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;

  NotificationRecipient({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
  });

  factory NotificationRecipient.fromJson(Map<String, dynamic> json) {
    return NotificationRecipient(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Customer',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      profileImage: json['profileImage']?.toString(),
    );
  }
}

class NotificationSender {
  final String id;
  final String name;
  final String email;

  NotificationSender({
    required this.id,
    required this.name,
    required this.email,
  });

  factory NotificationSender.fromJson(Map<String, dynamic> json) {
    return NotificationSender(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Admin',
      email: json['email']?.toString() ?? '',
    );
  }
}

class CustomerNotificationTarget {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;

  CustomerNotificationTarget({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
  });

  factory CustomerNotificationTarget.fromJson(Map<String, dynamic> json) {
    return CustomerNotificationTarget(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Customer',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      profileImage: json['profileImage']?.toString(),
    );
  }
}

class NotificationTemplate {
  final String id;
  final String title;
  final String message;
  final String? image;
  final String type;
  final String categoryTag;
  final String iconCode;

  const NotificationTemplate({
    required this.id,
    required this.title,
    required this.message,
    this.image,
    required this.type,
    required this.categoryTag,
    required this.iconCode,
  });

  static const List<NotificationTemplate> defaultTemplates = [
    NotificationTemplate(
      id: 'weekend_sale',
      title: 'Weekend Super Sale: 20% Off EV Spares! ⚡',
      message:
          'Upgrade your ride! Enjoy flat 20% off on all batteries, brake pads, and motors this weekend only. Use code WEEKEND20 at checkout.',
      image:
          'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=600',
      type: 'promotional',
      categoryTag: 'Weekend Sale',
      iconCode: 'sale',
    ),
    NotificationTemplate(
      id: 'new_arrivals',
      title: 'Fresh Stock Alert: Genuine EV Spares Arrived! 📦',
      message:
          'High-demand replacement parts, controllers, and chargers are now back in stock. Shop before they sell out!',
      image:
          'https://images.unsplash.com/photo-1486006920555-c77dce18193b?w=600',
      type: 'broadcast',
      categoryTag: 'New Arrivals',
      iconCode: 'inventory',
    ),
    NotificationTemplate(
      id: 'festive_offer',
      title: 'Festive Mega Savings: Up to 30% Off! 🎁',
      message:
          'Celebrate with VoltSpare! Special festive discounts on all bike accessories, LED headlights, and electrical parts.',
      image:
          'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=600',
      type: 'promotional',
      categoryTag: 'Festive Deal',
      iconCode: 'gift',
    ),
    NotificationTemplate(
      id: 'maintenance_reminder',
      title: 'Time for a Tune-up? Genuine Parts at Best Prices 🔧',
      message:
          'Keep your two-wheeler in top condition. Inspect brakes, drive belts, and filters with VoltSpare certified spares.',
      image:
          'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=600',
      type: 'promotional',
      categoryTag: 'Maintenance',
      iconCode: 'tuneup',
    ),
    NotificationTemplate(
      id: 'rare_sourcing',
      title: "Can't Find That Vintage or Rare Part? We Source It! 🔍",
      message:
          'Submit a Sourcing Request on the VoltSpare app and our procurement experts will locate it for you nationwide.',
      image:
          'https://images.unsplash.com/photo-1619642751034-765dfdf7c58e?w=600',
      type: 'rare_product_chat',
      categoryTag: 'Rare Parts',
      iconCode: 'search',
    ),
    NotificationTemplate(
      id: 'free_delivery',
      title: 'Free Delivery on All Orders Today! 🚚',
      message:
          'No minimum order value! Order any spare part today and enjoy free express home delivery across all locations.',
      image:
          'https://images.unsplash.com/photo-1526367790999-0150786686a2?w=600',
      type: 'promotional',
      categoryTag: 'Free Delivery',
      iconCode: 'shipping',
    ),
  ];
}
