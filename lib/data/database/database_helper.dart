import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../utils/platform_utils.dart';
import '../models/restaurant.dart';

class DatabaseHelper {
  static const _databaseName = 'restaurant_database.db';
  static const _databaseVersion = 1;
  static const _tableFavorites = 'favorites';

  static const columnId = 'id';
  static const columnName = 'name';
  static const columnDescription = 'description';
  static const columnPictureId = 'pictureId';
  static const columnCity = 'city';
  static const columnRating = 'rating';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableFavorites (
        $columnId TEXT PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnDescription TEXT NOT NULL,
        $columnPictureId TEXT NOT NULL,
        $columnCity TEXT NOT NULL,
        $columnRating REAL NOT NULL
      )
    ''');
  }

  Future<int> insertFavorite(Restaurant restaurant) async {
    if (PlatformUtils.isWeb) {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_tableFavorites);
      final list = stored != null
          ? json.decode(stored) as List<dynamic>
          : <dynamic>[];

      list.removeWhere((e) => e['id'] == restaurant.id);

      list.add({
        columnId: restaurant.id,
        columnName: restaurant.name,
        columnDescription: restaurant.description,
        columnPictureId: restaurant.pictureId,
        columnCity: restaurant.city,
        columnRating: restaurant.rating,
      });

      await prefs.setString(_tableFavorites, json.encode(list));
      return 1;
    }

    Database db = await instance.database;
    return await db.insert(_tableFavorites, {
      columnId: restaurant.id,
      columnName: restaurant.name,
      columnDescription: restaurant.description,
      columnPictureId: restaurant.pictureId,
      columnCity: restaurant.city,
      columnRating: restaurant.rating,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Restaurant>> getFavorites() async {
    if (PlatformUtils.isWeb) {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_tableFavorites);
      final List<dynamic> list = stored != null ? json.decode(stored) : [];

      return list.map<Restaurant>((maps) {
        return Restaurant(
          id: maps[columnId] ?? '',
          name: maps[columnName] ?? '',
          description: maps[columnDescription] ?? '',
          pictureId: maps[columnPictureId] ?? '',
          city: maps[columnCity] ?? '',
          rating: (maps[columnRating] ?? 0).toDouble(),
        );
      }).toList();
    }

    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(_tableFavorites);

    return List.generate(maps.length, (i) {
      return Restaurant(
        id: maps[i][columnId],
        name: maps[i][columnName],
        description: maps[i][columnDescription],
        pictureId: maps[i][columnPictureId],
        city: maps[i][columnCity],
        rating: maps[i][columnRating],
      );
    });
  }

  Future<bool> isFavorite(String id) async {
    if (PlatformUtils.isWeb) {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_tableFavorites);
      final List<dynamic> list = stored != null ? json.decode(stored) : [];
      return list.any((e) => e['id'] == id);
    }

    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableFavorites,
      where: '$columnId = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty;
  }

  Future<int> deleteFavorite(String id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_tableFavorites);
      final List<dynamic> list = stored != null ? json.decode(stored) : [];

      final before = list.length;
      list.removeWhere((e) => e['id'] == id);
      await prefs.setString(_tableFavorites, json.encode(list));
      return before - list.length;
    }

    Database db = await instance.database;
    return await db.delete(
      _tableFavorites,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearFavorites() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tableFavorites);
      return;
    }

    Database db = await instance.database;
    await db.delete(_tableFavorites);
  }
}
