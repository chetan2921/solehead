class SneakerModel {
  final String id;
  final String sneakerName;
  final String brandName;
  final double averageRating;
  final int ratingCount;
  final int postCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SneakerModel({
    required this.id,
    required this.sneakerName,
    required this.brandName,
    required this.averageRating,
    required this.ratingCount,
    required this.postCount,
    this.createdAt,
    this.updatedAt,
  });

  factory SneakerModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely get string value
    String safeString(dynamic value) {
      if (value is String) return value;
      if (value is Map || value is List) return '';
      return value?.toString() ?? '';
    }

    // Helper function to safely get int value
    int safeInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is double) return value.toInt();
      return 0;
    }

    // Helper function to safely get double value
    double safeDouble(dynamic value) {
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return SneakerModel(
      id: safeString(json['_id'] ?? json['id']),
      sneakerName: safeString(json['sneakerName']),
      brandName: safeString(json['brandName']),
      averageRating: safeDouble(json['averageRating']),
      ratingCount: safeInt(json['ratingCount']),
      postCount: safeInt(json['postCount']),
      createdAt: json['createdAt'] != null && json['createdAt'] is String
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null && json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sneakerName': sneakerName,
      'brandName': brandName,
      'averageRating': averageRating,
      'ratingCount': ratingCount,
      'postCount': postCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  SneakerModel copyWith({
    String? id,
    String? sneakerName,
    String? brandName,
    double? averageRating,
    int? ratingCount,
    int? postCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SneakerModel(
      id: id ?? this.id,
      sneakerName: sneakerName ?? this.sneakerName,
      brandName: brandName ?? this.brandName,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      postCount: postCount ?? this.postCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
