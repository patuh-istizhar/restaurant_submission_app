import 'restaurant.dart';

class RestaurantDetail extends Restaurant {
  final String address;
  final List<Category> categories;
  final Menus menus;
  final List<CustomerReview> customerReviews;

  RestaurantDetail({
    required super.id,
    required super.name,
    required super.description,
    required super.pictureId,
    required super.city,
    required super.rating,
    required this.address,
    required this.categories,
    required this.menus,
    required this.customerReviews,
  });

  factory RestaurantDetail.fromJson(Map<String, dynamic> json) {
    return RestaurantDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      pictureId: json['pictureId'] ?? '',
      city: json['city'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      address: json['address'] ?? '',
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((e) => Category.fromJson(e))
              .toList() ??
          [],
      menus: Menus.fromJson(json['menus'] ?? {}),
      customerReviews:
          (json['customerReviews'] as List<dynamic>?)
              ?.map((e) => CustomerReview.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Category {
  final String name;

  Category({required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(name: json['name'] ?? '');
  }
}

class Menus {
  final List<MenuItem> foods;
  final List<MenuItem> drinks;

  Menus({required this.foods, required this.drinks});

  factory Menus.fromJson(Map<String, dynamic> json) {
    return Menus(
      foods:
          (json['foods'] as List<dynamic>?)
              ?.map((e) => MenuItem.fromJson(e))
              .toList() ??
          [],
      drinks:
          (json['drinks'] as List<dynamic>?)
              ?.map((e) => MenuItem.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MenuItem {
  final String name;

  MenuItem({required this.name});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(name: json['name'] ?? '');
  }
}

class CustomerReview {
  final String name;
  final String review;
  final String date;

  CustomerReview({
    required this.name,
    required this.review,
    required this.date,
  });

  factory CustomerReview.fromJson(Map<String, dynamic> json) {
    return CustomerReview(
      name: json['name'] ?? '',
      review: json['review'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
