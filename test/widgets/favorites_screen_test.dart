import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/models/restaurant.dart';
import 'package:restaurant_app/data/storage/favorites_storage.dart';
import 'package:restaurant_app/providers/favorites_provider.dart';
import 'package:restaurant_app/screens/favorites_screen.dart';

// A mock implementation of FavoritesStorage that allows setting initial favorites
class FakeFavoritesStorage implements FavoritesStorage {
  final List<Restaurant> _favorites;

  FakeFavoritesStorage(this._favorites);

  @override
  Future<void> clearFavorites() async {}

  @override
  Future<bool> deleteFavorite(String id) async {
    final before = _favorites.length;
    _favorites.removeWhere((r) => r.id == id);
    return before != _favorites.length;
  }

  @override
  Future<List<Restaurant>> getFavorites() async => _favorites;

  @override
  Future<void> insertFavorite(Restaurant restaurant) async {
    _favorites.add(restaurant);
  }

  @override
  Future<bool> isFavorite(String id) async => _favorites.any((r) => r.id == id);
}

void main() {
  testWidgets('FavoritesScreen shows a message when there are no favorites', (
    WidgetTester tester,
  ) async {
    // Use the fake storage with an empty list
    final storage = FakeFavoritesStorage([]);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FavoritesProvider(storage),
        child: const MaterialApp(home: FavoritesScreen()),
      ),
    );

    // Let the Future in `loadFavorites` complete
    await tester.pumpAndSettle();

    // Expect to find the placeholder message
    expect(find.text('Belum Ada Favorit'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
  });

  testWidgets('FavoritesScreen shows a list of favorite restaurants', (
    WidgetTester tester,
  ) async {
    final testRestaurant = Restaurant(
      id: 'test1',
      name: 'Fav Resto',
      description: 'Desc',
      pictureId: 'p1',
      city: 'Kota',
      rating: 4.0,
    );

    // Use the fake storage with one favorite item
    final storage = FakeFavoritesStorage([testRestaurant]);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => FavoritesProvider(storage),
        child: const MaterialApp(home: FavoritesScreen()),
      ),
    );

    // Let the Future in `loadFavorites` complete
    await tester.pumpAndSettle();

    // Expect to find the restaurant card
    expect(find.text('Fav Resto'), findsOneWidget);
    expect(find.text('Belum Ada Favorit'), findsNothing);
  });
}
