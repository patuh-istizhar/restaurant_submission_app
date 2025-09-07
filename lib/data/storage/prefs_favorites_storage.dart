import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/restaurant.dart';
import 'favorites_storage.dart';

class PrefsFavoritesStorage implements FavoritesStorage {
  static const _kKey = 'favorites_v1';

  final SharedPreferences prefs;

  PrefsFavoritesStorage(this.prefs);

  @override
  Future<void> clearFavorites() async => prefs.remove(_kKey);

  List<Restaurant> _readList() {
    final raw = prefs.getString(_kKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = json.decode(raw) as List<dynamic>;
      return decoded
          .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
          .cast<Restaurant>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeList(List<Restaurant> items) async {
    final encoded = json.encode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_kKey, encoded);
  }

  @override
  Future<List<Restaurant>> getFavorites() async => _readList();

  @override
  Future<void> insertFavorite(Restaurant restaurant) async {
    final list = _readList();
    if (list.any((e) => e.id == restaurant.id)) return;
    list.add(restaurant);
    await _writeList(list);
  }

  @override
  Future<bool> deleteFavorite(String id) async {
    final list = _readList();
    final before = list.length;
    list.removeWhere((e) => e.id == id);
    if (list.length == before) return false;
    await _writeList(list);
    return true;
  }

  @override
  Future<bool> isFavorite(String id) async {
    final list = _readList();
    return list.any((e) => e.id == id);
  }
}
