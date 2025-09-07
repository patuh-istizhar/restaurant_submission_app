import 'package:sqflite/sqflite.dart';

import '../models/restaurant.dart';
import 'favorites_storage.dart';

class SqfliteFavoritesStorage implements FavoritesStorage {
  final Database db;

  SqfliteFavoritesStorage(this.db);

  @override
  Future<void> clearFavorites() async {
    await db.delete('favorites');
  }

  @override
  Future<bool> deleteFavorite(String id) async {
    final count = await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  @override
  Future<List<Restaurant>> getFavorites() async {
    final rows = await db.query('favorites');
    return rows.map((r) => Restaurant.fromJson(r)).toList();
  }

  @override
  Future<void> insertFavorite(Restaurant restaurant) async {
    await db.insert(
      'favorites',
      restaurant.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<bool> isFavorite(String id) async {
    final rows = await db.query(
      'favorites',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
