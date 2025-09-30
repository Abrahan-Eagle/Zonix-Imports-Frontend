/// Modelo de datos para Categorías de productos
class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final int? parentId;
  final int level;
  final bool isActive;
  final int? productCount;
  final String createdAt;
  final String updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.parentId,
    required this.level,
    required this.isActive,
    this.productCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crear CategoryModel desde JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      image: json['image'],
      parentId: json['parent_id'],
      level: json['level'] ?? 1,
      isActive: json['is_active'] ?? true,
      productCount: json['product_count'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  /// Convertir CategoryModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'parent_id': parentId,
      'level': level,
      'is_active': isActive,
      'product_count': productCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Crear copia del modelo con campos modificados
  CategoryModel copyWith({
    int? id,
    String? name,
    String? description,
    String? image,
    int? parentId,
    int? level,
    bool? isActive,
    int? productCount,
    String? createdAt,
    String? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      parentId: parentId ?? this.parentId,
      level: level ?? this.level,
      isActive: isActive ?? this.isActive,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Verificar si es categoría principal (sin padre)
  bool get isMainCategory => parentId == null;

  /// Verificar si es subcategoría
  bool get isSubCategory => parentId != null;

  /// Obtener imagen o imagen por defecto
  String get displayImage => image ?? 'assets/images/default_category.png';

  /// Obtener cantidad de productos formateada
  String get formattedProductCount {
    if (productCount == null) return '';
    return '$productCount productos';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, level: $level, isActive: $isActive)';
  }
}
