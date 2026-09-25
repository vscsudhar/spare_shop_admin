import 'package:intl/intl.dart';

class SuggestionModel {
  final String id;
  final String name;
  final String phone;
  final String suggestion;
  final String status;
  final String? adminNotes;
  final DateTime createdAt;
  final String? userEmail;

  const SuggestionModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.suggestion,
    required this.status,
    this.adminNotes,
    required this.createdAt,
    this.userEmail,
  });

  String get formattedDate {
    return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt);
  }

  factory SuggestionModel.fromJson(Map<String, dynamic> json) {
    String? email;
    if (json['user'] is Map) {
      email = json['user']['email']?.toString();
    }
    return SuggestionModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      suggestion: (json['suggestion'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      adminNotes: json['adminNotes']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      userEmail: email,
    );
  }
}
