import 'package:flutter/material.dart';
import '../data/models/restaurant.dart';
import '../data/services/api_service.dart';

sealed class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<Restaurant> restaurants;
  SearchSuccess(this.restaurants);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

class SearchEmpty extends SearchState {}

class SearchProvider with ChangeNotifier {
  final ApiService _apiService;

  SearchProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  SearchState _state = SearchInitial();
  SearchState get state => _state;

  String _query = '';
  String get query => _query;

  Future<void> searchRestaurants(String query) async {
    _query = query;

    if (query.isEmpty) {
      _state = SearchInitial();
      notifyListeners();
      return;
    }

    _state = SearchLoading();
    notifyListeners();

    try {
      final restaurants = await _apiService.searchRestaurants(query);
      if (restaurants.isEmpty) {
        _state = SearchEmpty();
      } else {
        _state = SearchSuccess(restaurants);
      }
    } catch (e) {
      _state = SearchError(e.toString());
    }
    notifyListeners();
  }

  void clear() {
    _query = '';
    _state = SearchInitial();
    notifyListeners();
  }
}
