import '../models/restaurant.dart';

abstract class FavoritesStorage {
  Future<List<Restaurant>> getFavorites();

  Future<void> insertFavorite(Restaurant restaurant);

  Future<bool> deleteFavorite(String id);

  Future<bool> isFavorite(String id);

  Future<void> clearFavorites();
}
