class Restaurant {
  final String id;
  final String name;
  final String description;
  final String pictureId;
  final String city;
  final double rating;
  final bool isFavorite;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.pictureId,
    required this.city,
    required this.rating,
    this.isFavorite = false,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      pictureId: json['pictureId'] ?? '',
      city: json['city'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'pictureId': pictureId,
    'city': city,
    'rating': rating,
  };

  Restaurant copyWith({
    String? id,
    String? name,
    String? description,
    String? pictureId,
    String? city,
    double? rating,
    bool? isFavorite,
  }) {
    return Restaurant(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      pictureId: pictureId ?? this.pictureId,
      city: city ?? this.city,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  String get imageUrl =>
      'https://restaurant-api.dicoding.dev/images/small/$pictureId';
  String get largeImageUrl =>
      'https://restaurant-api.dicoding.dev/images/medium/$pictureId';
}
