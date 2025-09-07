import 'package:flutter/material.dart';

import '../data/models/restaurant.dart';
import '../data/models/restaurant_detail.dart';
import '../data/services/api_service.dart';

sealed class RestaurantState {}

class RestaurantInitial extends RestaurantState {}

class RestaurantLoading extends RestaurantState {}

class RestaurantSuccess extends RestaurantState {
  final List<Restaurant> restaurants;
  RestaurantSuccess(this.restaurants);
}

class RestaurantError extends RestaurantState {
  final String message;
  RestaurantError(this.message);
}

sealed class RestaurantDetailState {}

class RestaurantDetailInitial extends RestaurantDetailState {}

class RestaurantDetailLoading extends RestaurantDetailState {}

class RestaurantDetailSuccess extends RestaurantDetailState {
  final RestaurantDetail restaurant;
  RestaurantDetailSuccess(this.restaurant);
}

class RestaurantDetailError extends RestaurantDetailState {
  final String message;
  RestaurantDetailError(this.message);
}

class RestaurantProvider with ChangeNotifier {
  final ApiService _apiService;

  RestaurantProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService() {
    fetchRestaurants();
  }

  RestaurantState _state = RestaurantInitial();
  RestaurantState get state => _state;

  RestaurantDetailState _detailState = RestaurantDetailInitial();
  RestaurantDetailState get detailState => _detailState;

  Future<void> fetchRestaurants() async {
    _state = RestaurantLoading();
    notifyListeners();

    try {
      final restaurants = await _apiService.getRestaurants();
      _state = RestaurantSuccess(restaurants);
    } catch (e) {
      _state = RestaurantError(e.toString());
    }
    notifyListeners();
  }

  Future<void> fetchRestaurantDetail(String id) async {
    _detailState = RestaurantDetailLoading();
    notifyListeners();

    try {
      final restaurant = await _apiService.getRestaurantDetail(id);
      _detailState = RestaurantDetailSuccess(restaurant);
    } catch (e) {
      _detailState = RestaurantDetailError(e.toString());
    }
    notifyListeners();
  }

  void setFavorites(Set<String> favoriteIds) {
    if (_state is RestaurantSuccess) {
      final currentState = _state as RestaurantSuccess;
      final updatedRestaurants = currentState.restaurants.map((restaurant) {
        return restaurant.copyWith(
          isFavorite: favoriteIds.contains(restaurant.id),
        );
      }).toList();
      _state = RestaurantSuccess(updatedRestaurants);
      notifyListeners();
    }
  }

  void toggleFavoriteStatus(String restaurantId, bool isFavorite) {
    if (_state is RestaurantSuccess) {
      final currentState = _state as RestaurantSuccess;
      final updatedRestaurants = currentState.restaurants.map((restaurant) {
        if (restaurant.id == restaurantId) {
          return restaurant.copyWith(isFavorite: isFavorite);
        }
        return restaurant;
      }).toList();
      _state = RestaurantSuccess(updatedRestaurants);
      notifyListeners();
    }
  }

  void retry() {
    fetchRestaurants();
  }

  void retryDetail(String id) {
    fetchRestaurantDetail(id);
  }

  Future<bool> addReview(
    String restaurantId,
    String name,
    String review,
  ) async {
    try {
      final success = await _apiService.addReview(restaurantId, name, review);
      if (success) {
        await fetchRestaurantDetail(restaurantId);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
