class LocationModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusKm;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  String get radiusDisplay =>
      '${radiusKm.toStringAsFixed(radiusKm.truncateToDouble() == radiusKm ? 0 : 1)} KM';
  String get coordinatesDisplay =>
      '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    double lat = 0.0;
    double lng = 0.0;

    // Check if GeoJSON location coordinates are present: [longitude, latitude]
    if (json['location'] is Map && json['location']['coordinates'] is List) {
      final List<dynamic> coords = json['location']['coordinates'];
      if (coords.length >= 2) {
        lng = (coords[0] as num?)?.toDouble() ?? 0.0;
        lat = (coords[1] as num?)?.toDouble() ?? 0.0;
      }
    } else {
      lat = (json['latitude'] as num?)?.toDouble() ?? 0.0;
      lng = (json['longitude'] as num?)?.toDouble() ?? 0.0;
    }

    return LocationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      latitude: lat,
      longitude: lng,
      radiusKm: (json['radiusKm'] as num?)?.toDouble() ?? 20.0,
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
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radiusKm': radiusKm,
      'isActive': isActive,
    };
  }

  LocationModel copyWith({
    String? id,
    String? name,
    double? latitude,
    double? longitude,
    double? radiusKm,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
