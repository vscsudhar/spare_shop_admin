import 'package:flutter/material.dart';

enum AdminTicketStatus {
  open,
  pending,
  resolved,
  closed;

  String get displayName {
    switch (this) {
      case AdminTicketStatus.open:
        return 'Open';
      case AdminTicketStatus.pending:
        return 'Pending';
      case AdminTicketStatus.resolved:
        return 'Resolved';
      case AdminTicketStatus.closed:
        return 'Closed';
    }
  }

  Color get color {
    switch (this) {
      case AdminTicketStatus.open:
        return const Color(0xFF0070F3);
      case AdminTicketStatus.pending:
        return const Color(0xFFFF9800);
      case AdminTicketStatus.resolved:
        return const Color(0xFF00B156);
      case AdminTicketStatus.closed:
        return const Color(0xFF757575);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AdminTicketStatus.open:
        return const Color(0xFFEBF5FF);
      case AdminTicketStatus.pending:
        return const Color(0xFFFFF4E5);
      case AdminTicketStatus.resolved:
        return const Color(0xFFE8F8F0);
      case AdminTicketStatus.closed:
        return const Color(0xFFF0F0F0);
    }
  }

  static AdminTicketStatus fromString(String? status) {
    if (status == null) return AdminTicketStatus.open;
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return AdminTicketStatus.pending;
      case 'resolved':
        return AdminTicketStatus.resolved;
      case 'closed':
        return AdminTicketStatus.closed;
      case 'open':
      default:
        return AdminTicketStatus.open;
    }
  }
}

class AdminTicketAttachment {
  final String url;
  final DateTime uploadedAt;

  const AdminTicketAttachment({
    required this.url,
    required this.uploadedAt,
  });

  factory AdminTicketAttachment.fromJson(Map<String, dynamic> json) {
    return AdminTicketAttachment(
      url: json['url']?.toString() ?? '',
      uploadedAt: json['uploadedAt'] != null
          ? DateTime.tryParse(json['uploadedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class AdminTicketMessage {
  final String id;
  final String ticketId;
  final String senderId;
  final String senderName;
  final String? senderImage;
  final String senderRole;
  final String message;
  final List<AdminTicketAttachment> attachments;
  final bool isRead;
  final DateTime createdAt;

  bool get isAdminOrStaff => senderRole == 'admin' || senderRole == 'staff';
  bool get isCustomer => senderRole == 'customer';

  const AdminTicketMessage({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.senderName,
    this.senderImage,
    required this.senderRole,
    required this.message,
    this.attachments = const [],
    this.isRead = false,
    required this.createdAt,
  });

  factory AdminTicketMessage.fromJson(Map<String, dynamic> json) {
    final senderObj = json['sender'];
    String sId = '';
    String sName = 'Customer';
    String? sImage;

    if (senderObj is Map<String, dynamic>) {
      sId = (senderObj['_id'] ?? senderObj['id'] ?? '').toString();
      sName = senderObj['name']?.toString() ?? 'User';
      sImage = senderObj['profileImage']?.toString();
    } else if (senderObj is String) {
      sId = senderObj;
    }

    final rawAttachments = json['attachments'];
    final List<AdminTicketAttachment> attachmentsList = [];
    if (rawAttachments is List) {
      for (final a in rawAttachments) {
        if (a is Map<String, dynamic>) {
          attachmentsList.add(AdminTicketAttachment.fromJson(a));
        } else if (a is String) {
          attachmentsList.add(
            AdminTicketAttachment(url: a, uploadedAt: DateTime.now()),
          );
        }
      }
    }

    return AdminTicketMessage(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      ticketId: (json['ticket'] ?? '').toString(),
      senderId: sId,
      senderName: sName,
      senderImage: sImage,
      senderRole: json['senderRole']?.toString() ?? 'customer',
      message: json['message']?.toString() ?? '',
      attachments: attachmentsList,
      isRead: json['isRead'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class AdminSupportTicket {
  final String id;
  final String ticketNumber;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String? customerImage;
  final String subject;
  final String category;
  final String description;
  final AdminTicketStatus status;
  final String priority;
  final List<AdminTicketAttachment> photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdminSupportTicket({
    required this.id,
    required this.ticketNumber,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.customerImage,
    required this.subject,
    required this.category,
    required this.description,
    required this.status,
    this.priority = 'medium',
    this.photos = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory AdminSupportTicket.fromJson(Map<String, dynamic> json) {
    final userObj = json['user'];
    String uId = '';
    String uName = 'Customer';
    String uEmail = '';
    String uPhone = '';
    String? uImage;

    if (userObj is Map<String, dynamic>) {
      uId = (userObj['_id'] ?? userObj['id'] ?? '').toString();
      uName = userObj['name']?.toString() ?? 'Customer';
      uEmail = userObj['email']?.toString() ?? '';
      uPhone = userObj['phone']?.toString() ?? '';
      uImage = userObj['profileImage']?.toString();
    } else if (userObj is String) {
      uId = userObj;
    }

    final rawPhotos = json['photos'];
    final List<AdminTicketAttachment> photoList = [];
    if (rawPhotos is List) {
      for (final p in rawPhotos) {
        if (p is Map<String, dynamic>) {
          photoList.add(AdminTicketAttachment.fromJson(p));
        } else if (p is String) {
          photoList
              .add(AdminTicketAttachment(url: p, uploadedAt: DateTime.now()));
        }
      }
    }

    return AdminSupportTicket(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      ticketNumber: json['ticketNumber']?.toString() ?? 'TKT-0000',
      customerId: uId,
      customerName: uName,
      customerEmail: uEmail,
      customerPhone: uPhone,
      customerImage: uImage,
      subject: json['subject']?.toString() ?? 'Support Ticket',
      category: json['category']?.toString() ?? 'General',
      description: json['description']?.toString() ?? '',
      status: AdminTicketStatus.fromString(json['status']?.toString()),
      priority: json['priority']?.toString() ?? 'medium',
      photos: photoList,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  AdminSupportTicket copyWith({
    String? id,
    String? ticketNumber,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerImage,
    String? subject,
    String? category,
    String? description,
    AdminTicketStatus? status,
    String? priority,
    List<AdminTicketAttachment>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminSupportTicket(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      customerImage: customerImage ?? this.customerImage,
      subject: subject ?? this.subject,
      category: category ?? this.category,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      photos: photos ?? this.photos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
