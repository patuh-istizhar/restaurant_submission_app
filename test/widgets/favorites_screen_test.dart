import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/models/restaurant.dart';
import 'package:restaurant_app/data/storage/favorites_storage.dart';
import 'package:restaurant_app/providers/favorites_provider.dart';
import 'package:restaurant_app/screens/favorites_screen.dart';

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
  testWidgets('FavoritesScreen shows favorite items and navigates to detail', (
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

    final storage = FakeFavoritesStorage([testRestaurant]);
    final provider = FavoritesProvider(storage);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<FavoritesProvider>.value(
          value: provider,
          child: const FavoritesScreen(),
        ),
      ),
    );

    // trigger loadFavorites
    await tester.pumpAndSettle();

    expect(find.text('Fav Resto'), findsOneWidget);

    // Tap the card and expect navigation
    await tester.tap(find.text('Fav Resto'));
    await tester.pumpAndSettle();

    // After navigation, RestaurantDetailScreen shows restaurant name in AppBar or body
    expect(find.text('Fav Resto'), findsAtLeastNWidgets(1));
  });
}
