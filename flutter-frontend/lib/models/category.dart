class Category {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final bool isActive;
  final int? productsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.icon,
    required this.isActive,
    this.productsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      description: json['description'],
      icon: json['icon'],
      isActive: json['is_active'] ?? true,
      productsCount: json['products_count'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'icon': icon,
      'is_active': isActive,
      'products_count': productsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
