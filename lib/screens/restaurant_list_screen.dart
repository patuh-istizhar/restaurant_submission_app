import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/restaurant.dart';
import '../providers/favorites_provider.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/custom_error_widget.dart';
import '../widgets/restaurant_card.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncFavorites();
    });
  }

  void _syncFavorites() {
    final restaurantProvider = context.read<RestaurantProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();

    if (restaurantProvider.state is RestaurantSuccess) {
      final favoriteIds = favoritesProvider.favorites.map((r) => r.id).toSet();
      restaurantProvider.setFavorites(favoriteIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        automaticallyImplyLeading: false,
      ),
      body: Consumer2<RestaurantProvider, FavoritesProvider>(
        builder: (context, restaurantProvider, favoritesProvider, child) {
          final state = restaurantProvider.state;

          return switch (state) {
            RestaurantLoading() => _buildLoadingIndicator(),
            RestaurantSuccess(restaurants: final restaurants) =>
              _buildRestaurantList(context, restaurants, restaurantProvider),
            RestaurantError(message: final message) => _buildErrorWidget(
              message,
              restaurantProvider,
            ),
            RestaurantInitial() =>
              _buildLoadingIndicator(), // Should not be reached, but for exhaustiveness
          };
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu_outlined,
              size: 80.0,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16.0),
            Text('No Restaurants Found', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8.0),
            Text(
              'There are currently no restaurants to display. Try pulling down to refresh.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantList(
    BuildContext context,
    List<Restaurant> restaurants,
    RestaurantProvider provider,
  ) {
    if (restaurants.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => provider.fetchRestaurants(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: _buildEmptyState(context),
              ),
            );
          },
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => provider.fetchRestaurants(),
      child: ListView.builder(
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          return RestaurantCard(restaurant: restaurants[index]);
        },
      ),
    );
  }

  Widget _buildErrorWidget(String message, RestaurantProvider provider) {
    return CustomErrorWidget(message: message, onRetry: () => provider.retry());
  }
}
