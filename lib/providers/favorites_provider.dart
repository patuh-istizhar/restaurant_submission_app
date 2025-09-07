import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database/database_helper.dart';
import '../data/models/restaurant.dart';
import '../data/storage/favorites_storage.dart';
import '../data/storage/prefs_favorites_storage.dart';

class FavoritesProvider with ChangeNotifier {
  final FavoritesStorage storage;

  FavoritesProvider(this.storage) {
    loadFavorites();
  }

  var _favorites = <Restaurant>[];
  List<Restaurant> get favorites => _favorites;

  var _isLoading = false;
  bool get isLoading => _isLoading;

  var _message = '';
  String get message => _message;

  bool _hasError = false;
  bool get hasError => _hasError;

  static Future<FavoritesProvider> createDefault() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return FavoritesProvider(PrefsFavoritesStorage(prefs));
    }

    return FavoritesProvider(_DatabaseHelperAdapter(DatabaseHelper.instance));
  }

  static FavoritesProvider defaultSync() {
    return FavoritesProvider(_DatabaseHelperAdapter(DatabaseHelper.instance));
  }

  Future<void> loadFavorites() async {
    _isLoading = true;
    _hasError = false;
    _message = '';
    notifyListeners();

    try {
      _favorites = await storage.getFavorites();
      if (_favorites.isEmpty) {
        _message = 'Belum ada restoran favorit';
      }
    } catch (e) {
      _message = 'Gagal memuat data favorit: ${e.toString()}';
      _hasError = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToFavorites(Restaurant restaurant) async {
    try {
      await storage.insertFavorite(restaurant);
      _favorites.add(restaurant);
      _message = '${restaurant.name} ditambahkan ke favorit';
      _hasError = false;
      notifyListeners();
      return true;
    } catch (e) {
      _message = 'Gagal menambahkan ke favorit: ${e.toString()}';
      _hasError = true;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removeFromFavorites(String restaurantId) async {
    try {
      final deleted = await storage.deleteFavorite(restaurantId);
      if (!deleted) {
        _message = 'Gagal menghapus dari favorit: Tidak ditemukan';
        _hasError = true;
        notifyListeners();
        return false;
      }
      final restaurant = _favorites.firstWhere((r) => r.id == restaurantId);
      _favorites.removeWhere((r) => r.id == restaurantId);
      _message = '${restaurant.name} dihapus dari favorit';
      _hasError = false;
      notifyListeners();
      return true;
    } catch (e) {
      _message = 'Gagal menghapus dari favorit: ${e.toString()}';
      _hasError = true;
      notifyListeners();
      return false;
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      await storage.clearFavorites();
      _favorites.clear();
      _message = 'Semua favorit telah dihapus.';
      _hasError = false;
    } catch (e) {
      _message = 'Gagal menghapus semua favorit: ${e.toString()}';
      _hasError = true;
    }
    notifyListeners();
  }

  Future<bool> isFavorite(String restaurantId) async {
    try {
      return await storage.isFavorite(restaurantId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking favorite status: $e');
      return false;
    }
  }

  bool isFavoriteSync(String restaurantId) {
    return _favorites.any((restaurant) => restaurant.id == restaurantId);
  }

  void clearMessage() {
    _message = '';
    _hasError = false;
    notifyListeners();
  }
}

class _DatabaseHelperAdapter implements FavoritesStorage {
  final DatabaseHelper helper;

  _DatabaseHelperAdapter(this.helper);

  @override
  Future<void> clearFavorites() async => helper.clearFavorites();

  @override
  Future<bool> deleteFavorite(String id) async {
    final count = await helper.deleteFavorite(id);
    return count > 0;
  }

  @override
  Future<List<Restaurant>> getFavorites() async => helper.getFavorites();

  @override
  Future<void> insertFavorite(Restaurant restaurant) async =>
      helper.insertFavorite(restaurant);

  @override
  Future<bool> isFavorite(String id) async => helper.isFavorite(id);
}
