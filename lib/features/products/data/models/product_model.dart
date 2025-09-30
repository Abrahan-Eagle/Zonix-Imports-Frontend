/// Modelo de datos para Productos
/// Representa un producto en el catálogo de Zonix Imports
class ProductModel {
  final int id;
  final int commerceId;
  final int? categoryId;
  final String name;
  final String sku;
  final String description;
  final String modality; // wholesale, retail, preorder, dropshipping, referral
  final double basePrice;
  final int stock;
  final int? minWholesaleQuantity;
  final double? wholesalePrice;
  final String? preorderEta;
  final int? originProductId;
  final String? image;
  final String? videoUrl;
  final double? weight;
  final List<double>? dimensions;
  final bool available;
  final String createdAt;
  final String updatedAt;

  const ProductModel({
    required this.id,
    required this.commerceId,
    this.categoryId,
    required this.name,
    required this.sku,
    required this.description,
    required this.modality,
    required this.basePrice,
    required this.stock,
    this.minWholesaleQuantity,
    this.wholesalePrice,
    this.preorderEta,
    this.originProductId,
    this.image,
    this.videoUrl,
    this.weight,
    this.dimensions,
    required this.available,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crear ProductModel desde JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      commerceId: json['commerce_id'] ?? 0,
      categoryId: json['category_id'],
      name: json['name'] ?? '',
      sku: json['sku'] ?? '',
      description: json['description'] ?? '',
      modality: json['modality'] ?? 'retail',
      basePrice: double.tryParse(json['base_price']?.toString() ?? '0') ?? 0.0,
      stock: json['stock'] ?? 0,
      minWholesaleQuantity: json['min_wholesale_quantity'],
      wholesalePrice: json['wholesale_price'] != null
          ? double.tryParse(json['wholesale_price'].toString())
          : null,
      preorderEta: json['preorder_eta'],
      originProductId: json['origin_product_id'],
      image: json['image'],
      videoUrl: json['video_url'],
      weight: json['weight'] != null
          ? double.tryParse(json['weight'].toString())
          : null,
      dimensions: json['dimensions'] != null
          ? List<double>.from(json['dimensions']
              .map((x) => double.tryParse(x.toString()) ?? 0.0))
          : null,
      available: json['available'] ?? true,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  /// Convertir ProductModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commerce_id': commerceId,
      'category_id': categoryId,
      'name': name,
      'sku': sku,
      'description': description,
      'modality': modality,
      'base_price': basePrice,
      'stock': stock,
      'min_wholesale_quantity': minWholesaleQuantity,
      'wholesale_price': wholesalePrice,
      'preorder_eta': preorderEta,
      'origin_product_id': originProductId,
      'image': image,
      'video_url': videoUrl,
      'weight': weight,
      'dimensions': dimensions,
      'available': available,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Crear copia del modelo con campos modificados
  ProductModel copyWith({
    int? id,
    int? commerceId,
    int? categoryId,
    String? name,
    String? sku,
    String? description,
    String? modality,
    double? basePrice,
    int? stock,
    int? minWholesaleQuantity,
    double? wholesalePrice,
    String? preorderEta,
    int? originProductId,
    String? image,
    String? videoUrl,
    double? weight,
    List<double>? dimensions,
    bool? available,
    String? createdAt,
    String? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      commerceId: commerceId ?? this.commerceId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      description: description ?? this.description,
      modality: modality ?? this.modality,
      basePrice: basePrice ?? this.basePrice,
      stock: stock ?? this.stock,
      minWholesaleQuantity: minWholesaleQuantity ?? this.minWholesaleQuantity,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      preorderEta: preorderEta ?? this.preorderEta,
      originProductId: originProductId ?? this.originProductId,
      image: image ?? this.image,
      videoUrl: videoUrl ?? this.videoUrl,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      available: available ?? this.available,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Obtener precio final (precio mayorista si aplica, sino precio base)
  double get finalPrice => wholesalePrice ?? basePrice;

  /// Verificar si tiene precio mayorista
  bool get hasWholesalePrice =>
      wholesalePrice != null && wholesalePrice! < basePrice;

  /// Calcular porcentaje de ahorro con precio mayorista
  double get savingsPercentage {
    if (!hasWholesalePrice) return 0.0;
    return ((basePrice - wholesalePrice!) / basePrice) * 100;
  }

  /// Verificar si está en stock
  bool get inStock => stock > 0 && available;

  /// Obtener imagen principal
  String get primaryImage => image ?? '';

  /// Obtener todas las imágenes
  List<String> get allImages {
    List<String> imageList = [];
    if (image != null && image!.isNotEmpty) {
      imageList.add(image!);
    }
    return imageList;
  }

  /// Formatear precio como string
  String get formattedPrice => '\$${basePrice.toStringAsFixed(2)}';

  /// Formatear precio final como string
  String get formattedFinalPrice => '\$${finalPrice.toStringAsFixed(2)}';

  /// Obtener stock como string
  String get stockStatus {
    if (!available) return 'No disponible';
    if (stock <= 0) return 'Agotado';
    if (stock <= 5) return 'Últimas unidades';
    return 'En stock';
  }

  /// Obtener modalidad como string legible
  String get modalityText {
    switch (modality) {
      case 'wholesale':
        return 'Mayorista';
      case 'retail':
        return 'Detal';
      case 'preorder':
        return 'Pre-orden';
      case 'dropshipping':
        return 'Dropshipping';
      case 'referral':
        return 'Referido';
      default:
        return 'Detal';
    }
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
    return 'ProductModel(id: $id, name: $name, basePrice: $basePrice, stock: $stock, available: $available)';
  }
}
