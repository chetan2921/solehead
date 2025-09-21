class UserModel {
  final String id;
  final String username;
  final String email;
  final String profilePhoto;
  final int totalSneakerCount;
  final int followers;
  final int following;
  final int? postCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.profilePhoto,
    required this.totalSneakerCount,
    required this.followers,
    required this.following,
    this.postCount,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
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

    return UserModel(
      id: safeString(json['_id'] ?? json['id']),
      username: safeString(json['username']),
      email: safeString(json['email']),
      profilePhoto: safeString(json['profilePhoto']),
      totalSneakerCount: safeInt(json['totalSneakerCount']),
      followers: safeInt(json['followers']),
      following: safeInt(json['following']),
      postCount: json['postCount'] is int ? json['postCount'] : null,
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
      'username': username,
      'email': email,
      'profilePhoto': profilePhoto,
      'totalSneakerCount': totalSneakerCount,
      'followers': followers,
      'following': following,
      'postCount': postCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? profilePhoto,
    int? totalSneakerCount,
    int? followers,
    int? following,
    int? postCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      totalSneakerCount: totalSneakerCount ?? this.totalSneakerCount,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      postCount: postCount ?? this.postCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
