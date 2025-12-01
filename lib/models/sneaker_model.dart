class SneakerModel {
  final String id;
  final String sneakerName;
  final String brandName;
  final String description;
  final String sneakerUrl;
  final String photoUrl;
  final double? price;
  final String? currency;
  final String? priceRaw;
  final String? sourceFile;
  final String? metadataOriginalRowHash;
  final Map<String, dynamic>? metadata;
  final double averageRating;
  final int ratingCount;
  final int postCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SneakerModel({
    required this.id,
    required this.sneakerName,
    required this.brandName,
    this.description = '',
    this.sneakerUrl = '',
    this.photoUrl = '',
    this.price,
    this.currency,
    this.priceRaw,
    this.sourceFile,
    this.metadataOriginalRowHash,
    this.metadata,
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

    String? safeOptionalString(dynamic value) {
      final result = safeString(value);
      return result.isEmpty ? null : result;
    }

    double? safeNullableDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        final sanitized = value.replaceAll(RegExp(r'[^0-9\.-]'), '');
        return double.tryParse(sanitized);
      }
      return null;
    }

    Map<String, dynamic>? metadataMap;
    final metadataValue = json['metadata'];
    if (metadataValue is Map<String, dynamic>) {
      metadataMap = Map<String, dynamic>.from(metadataValue);
    }

    String? metadataImageFrom(Map<String, dynamic>? map) {
      if (map == null || map.isEmpty) return null;

      String? normalize(dynamic value) {
        if (value is String) {
          final trimmed = value.trim();
          return trimmed.isEmpty ? null : trimmed;
        }
        return null;
      }

      final directImage = normalize(
        map['primaryImage'] ?? map['image'] ?? map['mainImage'],
      );
      if (directImage != null) return directImage;

      final imagesValue = map['images'];
      if (imagesValue is List) {
        for (final entry in imagesValue) {
          if (entry is String) {
            final normalized = normalize(entry);
            if (normalized != null) return normalized;
          } else if (entry is Map<String, dynamic>) {
            final normalized = normalize(
              entry['url'] ?? entry['src'] ?? entry['image'],
            );
            if (normalized != null) return normalized;
          }
        }
      } else {
        final normalized = normalize(imagesValue);
        if (normalized != null) return normalized;
      }

      return null;
    }

    final resolvedBrand = safeString(json['brand'] ?? json['brandName']);
    final resolvedName = safeString(json['name'] ?? json['sneakerName']);
    String resolvedImage = safeString(
      json['photoUrl'] ??
          json['image'] ??
          json['imageUrl'] ??
          json['mainImage'],
    );
    if (resolvedImage.isEmpty) {
      resolvedImage = metadataImageFrom(metadataMap) ?? '';
    }
    final resolvedPriceRaw = safeOptionalString(
      json['priceRaw'] ?? json['priceFormatted'] ?? json['priceDisplay'],
    );
    final resolvedSourceFile = safeOptionalString(
      json['sourceFile'] ?? metadataMap?['importSource'],
    );
    final resolvedRowHash = safeOptionalString(
      metadataMap?['originalRowHash'] ?? json['originalRowHash'],
    );

    return SneakerModel(
      id: safeString(json['_id'] ?? json['id']),
      sneakerName: resolvedName,
      brandName: resolvedBrand,
      description: safeString(json['description']),
      sneakerUrl: safeString(
        json['sneakerUrl'] ?? json['productUrl'] ?? json['url'] ?? json['link'],
      ),
      photoUrl: resolvedImage,
      price: safeNullableDouble(json['price'] ?? json['retailPrice']),
      currency: safeOptionalString(json['currency']),
      priceRaw: resolvedPriceRaw,
      sourceFile: resolvedSourceFile,
      metadataOriginalRowHash: resolvedRowHash,
      metadata: metadataMap,
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
      'description': description,
      'sneakerUrl': sneakerUrl,
      'photoUrl': photoUrl,
      'price': price,
      'currency': currency,
      'priceRaw': priceRaw,
      'sourceFile': sourceFile,
      'metadataOriginalRowHash': metadataOriginalRowHash,
      'metadata': metadata,
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
    String? description,
    String? sneakerUrl,
    String? photoUrl,
    double? price,
    String? currency,
    String? priceRaw,
    String? sourceFile,
    String? metadataOriginalRowHash,
    Map<String, dynamic>? metadata,
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
      description: description ?? this.description,
      sneakerUrl: sneakerUrl ?? this.sneakerUrl,
      photoUrl: photoUrl ?? this.photoUrl,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      priceRaw: priceRaw ?? this.priceRaw,
      sourceFile: sourceFile ?? this.sourceFile,
      metadataOriginalRowHash:
          metadataOriginalRowHash ?? this.metadataOriginalRowHash,
      metadata: metadata ?? this.metadata,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      postCount: postCount ?? this.postCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
