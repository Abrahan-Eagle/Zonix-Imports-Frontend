/// Modelo de datos para Productos
/// Representa un producto en el catálogo de Zonix Imports
class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String? image;
  final List<String>? images;
  final String category;
  final int categoryId;
  final String brand;
  final String sku;
  final int stock;
  final bool isActive;
  final String status;
  final String condition; // new, used, refurbished
  final double? weight;
  final String? dimensions;
  final Map<String, dynamic>? specifications;
  final List<String>? tags;
  final double? rating;
  final int? reviewCount;
  final String? vendorName;
  final int? vendorId;
  final String createdAt;
  final String updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    this.image,
    this.images,
    required this.category,
    required this.categoryId,
    required this.brand,
    required this.sku,
    required this.stock,
    required this.isActive,
    required this.status,
    required this.condition,
    this.weight,
    this.dimensions,
    this.specifications,
    this.tags,
    this.rating,
    this.reviewCount,
    this.vendorName,
    this.vendorId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crear ProductModel desde JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      discountPrice: json['discount_price'] != null ? (json['discount_price'] as num).toDouble() : null,
      image: json['image'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      category: json['category'] ?? '',
      categoryId: json['category_id'] ?? 0,
      brand: json['brand'] ?? '',
      sku: json['sku'] ?? '',
      stock: json['stock'] ?? 0,
      isActive: json['is_active'] ?? true,
      status: json['status'] ?? 'active',
      condition: json['condition'] ?? 'new',
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      dimensions: json['dimensions'],
      specifications: json['specifications'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'],
      vendorName: json['vendor_name'],
      vendorId: json['vendor_id'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  /// Convertir ProductModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'image': image,
      'images': images,
      'category': category,
      'category_id': categoryId,
      'brand': brand,
      'sku': sku,
      'stock': stock,
      'is_active': isActive,
      'status': status,
      'condition': condition,
      'weight': weight,
      'dimensions': dimensions,
      'specifications': specifications,
      'tags': tags,
      'rating': rating,
      'review_count': reviewCount,
      'vendor_name': vendorName,
      'vendor_id': vendorId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Crear copia del modelo con campos modificados
  ProductModel copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? image,
    List<String>? images,
    String? category,
    int? categoryId,
    String? brand,
    String? sku,
    int? stock,
    bool? isActive,
    String? status,
    String? condition,
    double? weight,
    String? dimensions,
    Map<String, dynamic>? specifications,
    List<String>? tags,
    double? rating,
    int? reviewCount,
    String? vendorName,
    int? vendorId,
    String? createdAt,
    String? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      image: image ?? this.image,
      images: images ?? this.images,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      brand: brand ?? this.brand,
      sku: sku ?? this.sku,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      condition: condition ?? this.condition,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      specifications: specifications ?? this.specifications,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      vendorName: vendorName ?? this.vendorName,
      vendorId: vendorId ?? this.vendorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Obtener precio final (con descuento si aplica)
  double get finalPrice => discountPrice ?? price;

  /// Verificar si tiene descuento
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  /// Calcular porcentaje de descuento
  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return ((price - discountPrice!) / price) * 100;
  }

  /// Verificar si está en stock
  bool get inStock => stock > 0 && isActive;

  /// Obtener imagen principal
  String get primaryImage => image ?? (images?.isNotEmpty == true ? images!.first : '');

  /// Obtener todas las imágenes
  List<String> get allImages {
    List<String> imageList = [];
    if (image != null && image!.isNotEmpty) {
      imageList.add(image!);
    }
    if (images != null) {
      imageList.addAll(images!);
    }
    return imageList;
  }

  /// Formatear precio como string
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  /// Formatear precio con descuento como string
  String get formattedDiscountPrice => '\$${finalPrice.toStringAsFixed(2)}';

  /// Obtener stock como string
  String get stockStatus {
    if (!isActive) return 'No disponible';
    if (stock <= 0) return 'Agotado';
    if (stock <= 5) return 'Últimas unidades';
    return 'En stock';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ProductModel(id: $id, name: $name, price: $price, stock: $stock, isActive: $isActive)';
  }
}
