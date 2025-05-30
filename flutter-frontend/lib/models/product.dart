import 'user.dart';
import 'category.dart';

class Product {
  final int id;
  final int userId;
  final int categoryId;
  final String title;
  final String description;
  final double price;
  final String condition;
  final String location;
  final double? latitude;
  final double? longitude;
  final List<String> images;
  final String status;
  final int views;
  final bool isFeatured;
  final User? user;
  final Category? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.price,
    required this.condition,
    required this.location,
    this.latitude,
    this.longitude,
    required this.images,
    required this.status,
    required this.views,
    required this.isFeatured,
    this.user,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      userId: json['user_id'],
      categoryId: json['category_id'],
      title: json['title'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      condition: json['condition'],
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : [],
      status: json['status'],
      views: json['views'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'description': description,
      'price': price,
      'condition': condition,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'status': status,
      'views': views,
      'is_featured': isFeatured,
      'user': user?.toJson(),
      'category': category?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  List<String> get imageUrls {
    // For sample data, images are already full URLs
    // For API data, prepend the storage URL
    if (images.isNotEmpty && images.first.startsWith('http')) {
      return images;
    }
    return images.map((image) => 'http://localhost:8000/storage/$image').toList();
  }

  String get mainImageUrl {
    if (images.isNotEmpty) {
      // For sample data, images are already full URLs
      if (images.first.startsWith('http')) {
        return images.first;
      }
      return 'http://localhost:8000/storage/${images.first}';
    }
    return '';
  }

  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}';
  }

  bool get isActive => status == 'active';
  bool get isSold => status == 'sold';
  bool get isInactive => status == 'inactive';

  String get conditionDisplay {
    switch (condition) {
      case 'new':
        return 'New';
      case 'used':
        return 'Used';
      case 'refurbished':
        return 'Refurbished';
      default:
        return condition;
    }
  }
}
