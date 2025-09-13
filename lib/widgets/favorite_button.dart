import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/restaurant.dart';
import '../providers/favorites_provider.dart';
import '../providers/restaurant_provider.dart';

class FavoriteButton extends StatelessWidget {
  final Restaurant restaurant;
  final double size;

  const FavoriteButton({super.key, required this.restaurant, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorite = favoritesProvider.isFavoriteSync(restaurant.id);

        return GestureDetector(
          onTap: () async {
            final restaurantProvider = context.read<RestaurantProvider>();
            final newFavoriteState = !isFavorite;

            bool success;
            if (isFavorite) {
              success = await favoritesProvider.removeFromFavorites(
                restaurant.id,
              );
            } else {
              success = await favoritesProvider.addToFavorites(restaurant);
            }

            if (!context.mounted) return;

            if (success) {
              restaurantProvider.toggleFavoriteStatus(
                restaurant.id,
                newFavoriteState,
              );
            }

            final message = favoritesProvider.message;
            if (message.isNotEmpty) {
              messenger.showSnackBar(SnackBar(content: Text(message)));
              favoritesProvider.clearMessage();
            }
          },
          child: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
            size: size,
          ),
        );
      },
    );
  }
}
