import 'user_model.dart';
import 'sneaker_model.dart';

class PostModel {
  final String id;
  final String userId;
  final String? sneakerId;
  final String mainImage;
  final List<String> additionalImages;
  final String brandName;
  final String sneakerName;
  final String description;
  final String? purchaseLink;
  final String? purchaseAddress;
  final double? price;
  final int? year;
  final List<String> likes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? user;
  final SneakerModel? sneaker;

  PostModel({
    required this.id,
    required this.userId,
    this.sneakerId,
    required this.mainImage,
    required this.additionalImages,
    required this.brandName,
    required this.sneakerName,
    required this.description,
    this.purchaseLink,
    this.purchaseAddress,
    this.price,
    this.year,
    required this.likes,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.sneaker,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Helper function to safely get string value
    String safeString(dynamic value) {
      if (value is String) return value;
      if (value is Map || value is List) return '';
      return value?.toString() ?? '';
    }

    // Helper function to safely get string list
    List<String> safeStringList(dynamic value) {
      if (value is List) {
        return value.map((e) => e is String ? e : e?.toString() ?? '').toList();
      }
      return [];
    }

    // Helper function to safely extract ID from object or return string
    String safeId(dynamic value) {
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        return value['_id'] ?? value['id'] ?? '';
      }
      return value?.toString() ?? '';
    }

    return PostModel(
      id: safeString(json['_id'] ?? json['id']),
      userId: safeId(json['userId']), // Handle both string and object format
      sneakerId: json['sneakerId'] != null ? safeId(json['sneakerId']) : null,
      mainImage: safeString(json['mainImage']),
      additionalImages: safeStringList(json['additionalImages']),
      brandName: safeString(json['brandName']),
      sneakerName: safeString(json['sneakerName']),
      description: safeString(json['description']),
      purchaseLink: json['purchaseLink'] is String
          ? json['purchaseLink']
          : null,
      purchaseAddress: json['purchaseAddress'] is String
          ? json['purchaseAddress']
          : null,
      price: json['price']?.toDouble(),
      year: json['year'] is int ? json['year'] : null,
      likes: safeStringList(json['likes']),
      createdAt: DateTime.parse(
        json['createdAt'] is String
            ? json['createdAt']
            : DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] is String
            ? json['updatedAt']
            : DateTime.now().toIso8601String(),
      ),
      user: json['userId'] != null && json['userId'] is Map<String, dynamic>
          ? UserModel.fromJson(json['userId'])
          : null,
      sneaker:
          json['sneakerId'] != null && json['sneakerId'] is Map<String, dynamic>
          ? SneakerModel.fromJson(json['sneakerId'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'sneakerId': sneakerId,
      'mainImage': mainImage,
      'additionalImages': additionalImages,
      'brandName': brandName,
      'sneakerName': sneakerName,
      'description': description,
      'purchaseLink': purchaseLink,
      'purchaseAddress': purchaseAddress,
      'price': price,
      'year': year,
      'likes': likes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'user': user?.toJson(),
      'sneaker': sneaker?.toJson(),
    };
  }

  int get likeCount => likes.length;

  bool isLikedBy(String userId) => likes.contains(userId);

  PostModel copyWith({
    String? id,
    String? userId,
    String? sneakerId,
    String? mainImage,
    List<String>? additionalImages,
    String? brandName,
    String? sneakerName,
    String? description,
    String? purchaseLink,
    String? purchaseAddress,
    double? price,
    int? year,
    List<String>? likes,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? user,
    SneakerModel? sneaker,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sneakerId: sneakerId ?? this.sneakerId,
      mainImage: mainImage ?? this.mainImage,
      additionalImages: additionalImages ?? this.additionalImages,
      brandName: brandName ?? this.brandName,
      sneakerName: sneakerName ?? this.sneakerName,
      description: description ?? this.description,
      purchaseLink: purchaseLink ?? this.purchaseLink,
      purchaseAddress: purchaseAddress ?? this.purchaseAddress,
      price: price ?? this.price,
      year: year ?? this.year,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      sneaker: sneaker ?? this.sneaker,
    );
  }
}
