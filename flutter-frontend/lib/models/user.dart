class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String role;
  final String? avatar;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
    required this.role,
    this.avatar,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      role: json['role'],
      avatar: json['avatar'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'role': role,
      'avatar': avatar,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get avatarUrl {
    if (avatar != null) {
      return 'http://localhost:8000/storage/$avatar';
    }
    return '';
  }

  bool get isSeller => role == 'seller';
  bool get isBuyer => role == 'buyer';
}
