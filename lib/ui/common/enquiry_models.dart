import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnquiryModel {
  final String id;
  final String? userId;
  final String name;
  final String phone;
  final String brand;
  final String model;
  final String partName;
  final String message;
  final String status; // 'pending', 'call_user', 'denied', 'completed'
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EnquiryModel({
    required this.id,
    this.userId,
    required this.name,
    required this.phone,
    this.brand = '',
    this.model = '',
    this.partName = '',
    this.message = '',
    this.status = 'pending',
    this.adminNotes,
    required this.createdAt,
    this.updatedAt,
  });

  String get formattedDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt.toLocal());
  }

  String get formattedDateOnly {
    return DateFormat('dd MMM yyyy').format(createdAt.toLocal());
  }

  String get formattedTimeOnly {
    return DateFormat('hh:mm a').format(createdAt.toLocal());
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'call_user':
        return 'Call User';
      case 'denied':
        return 'Denied User';
      case 'completed':
        return 'Completed';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'call_user':
        return const Color(0xFF3B82F6); // Blue
      case 'denied':
        return const Color(0xFFEF4444); // Red
      case 'completed':
        return const Color(0xFF10B981); // Green
      case 'pending':
      default:
        return const Color(0xFFF59E0B); // Amber / Orange
    }
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'call_user':
        return Icons.phone_in_talk_rounded;
      case 'denied':
        return Icons.cancel_outlined;
      case 'completed':
        return Icons.check_circle_outline_rounded;
      case 'pending':
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  factory EnquiryModel.fromJson(Map<String, dynamic> json) {
    String extractId = json['_id'] ?? json['id'] ?? '';
    String userName = json['name'] ?? '';
    String userPhone = json['phone'] ?? '';
    String? uId;

    if (json['user'] != null && json['user'] is Map<String, dynamic>) {
      final userObj = json['user'] as Map<String, dynamic>;
      uId = userObj['_id'] ?? userObj['id'];
      if (userName.isEmpty) userName = userObj['name'] ?? '';
      if (userPhone.isEmpty) userPhone = userObj['phone'] ?? '';
    }

    return EnquiryModel(
      id: extractId,
      userId: uId,
      name: userName,
      phone: userPhone,
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      partName: json['partName'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
      adminNotes: json['adminNotes'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'brand': brand,
        'model': model,
        'partName': partName,
        'message': message,
        'status': status,
        'adminNotes': adminNotes,
      };

  EnquiryModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? phone,
    String? brand,
    String? model,
    String? partName,
    String? message,
    String? status,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EnquiryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      partName: partName ?? this.partName,
      message: message ?? this.message,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
