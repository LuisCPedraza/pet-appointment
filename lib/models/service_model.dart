/// Representa un servicio veterinario activo (tabla `services`).
class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.name,
    this.description,
    required this.durationMinutes,
    required this.price,
    required this.isActive,
  });

  final String id;
  final String name;
  final String? description;
  final int durationMinutes;
  final double price;
  final bool isActive;

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 30,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    int? durationMinutes,
    double? price,
    bool? isActive,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Precio formateado sin decimales: "$50,000"
  String get priceFormatted =>
      '\$${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';

  /// Duración formateada: "30 min"
  String get durationFormatted => '$durationMinutes min';
}
