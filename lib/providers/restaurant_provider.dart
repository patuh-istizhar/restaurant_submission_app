import 'dart:math';

import 'package:flutter/material.dart';

import '../data/models/restaurant.dart';
import '../data/models/restaurant_detail.dart';
import '../data/services/api_service.dart';

abstract class RestaurantState {}

class RestaurantInitial extends RestaurantState {}

class RestaurantLoading extends RestaurantState {}

class RestaurantSuccess extends RestaurantState {
  final List<Restaurant> restaurants;
  RestaurantSuccess({required this.restaurants});
}

class RestaurantError extends RestaurantState {
  final String message;
  RestaurantError({required this.message});
}

abstract class RestaurantDetailState {}

class RestaurantDetailInitial extends RestaurantDetailState {}

class RestaurantDetailLoading extends RestaurantDetailState {}

class RestaurantDetailSuccess extends RestaurantDetailState {
  final RestaurantDetail restaurant;
  RestaurantDetailSuccess({required this.restaurant});
}

class RestaurantDetailError extends RestaurantDetailState {
  final String message;
  RestaurantDetailError({required this.message});
}

class RestaurantProvider with ChangeNotifier {
  final ApiService apiService;

  RestaurantState _state = RestaurantInitial();
  RestaurantState get state => _state;

  RestaurantDetailState _detailState = RestaurantDetailInitial();
  RestaurantDetailState get detailState => _detailState;

  RestaurantProvider({required this.apiService});

  Future<void> fetchRestaurants() async {
    _state = RestaurantLoading();
    notifyListeners();
    try {
      final restaurants = await apiService.getRestaurants();
      _state = RestaurantSuccess(restaurants: restaurants);
    } catch (e) {
      _state = RestaurantError(message: e.toString());
    }
    notifyListeners();
  }

  Future<void> fetchRestaurantDetail(String id) async {
    _detailState = RestaurantDetailLoading();
    notifyListeners();
    try {
      final restaurant = await apiService.getRestaurantDetail(id);
      _detailState = RestaurantDetailSuccess(restaurant: restaurant);
    } catch (e) {
      _detailState = RestaurantDetailError(message: e.toString());
    }
    notifyListeners();
  }

  void setFavorites(Set<String> favoriteIds) {
    if (_state is RestaurantSuccess) {
      final currentRestaurants = (_state as RestaurantSuccess).restaurants;
      final updatedRestaurants = currentRestaurants.map((restaurant) {
        return restaurant.copyWith(
          isFavorite: favoriteIds.contains(restaurant.id),
        );
      }).toList();
      _state = RestaurantSuccess(restaurants: updatedRestaurants);
      notifyListeners();
    }
  }

  void toggleFavoriteStatus(String id, bool isFavorite) {
    if (_state is RestaurantSuccess) {
      final currentRestaurants = (_state as RestaurantSuccess).restaurants;
      final updatedRestaurants = currentRestaurants.map((restaurant) {
        if (restaurant.id == id) {
          return restaurant.copyWith(isFavorite: isFavorite);
        }
        return restaurant;
      }).toList();
      _state = RestaurantSuccess(restaurants: updatedRestaurants);
      notifyListeners();
    }
  }

  Future<void> retry() => fetchRestaurants();
  Future<void> retryDetail(String id) => fetchRestaurantDetail(id);

  Restaurant? get randomRestaurant {
    if (_state is RestaurantSuccess) {
      final restaurants = (_state as RestaurantSuccess).restaurants;
      if (restaurants.isNotEmpty) {
        final random = Random();
        final index = random.nextInt(restaurants.length);
        return restaurants[index];
      }
    }
    return null;
  }
}
