import 'package:flutter/material.dart';

import '../data/models/restaurant.dart';
import '../screens/restaurant_detail_screen.dart';
import '../utils/app_theme.dart';
import 'favorite_button.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final CardThemeData cardTheme = Theme.of(context).cardTheme;

    return Card(
      shape: cardTheme.shape,
      elevation: cardTheme.elevation,
      child: InkWell(
        borderRadius: cardTheme.shape is RoundedRectangleBorder
            ? (cardTheme.shape as RoundedRectangleBorder).borderRadius
                  as BorderRadius?
            : BorderRadius.circular(12.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RestaurantDetailScreen(restaurant: restaurant),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'restaurant-${restaurant.id}',
                flightShuttleBuilder:
                    (
                      flightContext,
                      animation,
                      flightDirection,
                      fromHeroContext,
                      toHeroContext,
                    ) {
                      final Hero toHero = toHeroContext.widget as Hero;
                      return toHero.child;
                    },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: SizedBox(
                    width: 100,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Opacity(
                          opacity: 0.0,
                          child: Icon(Icons.image_not_supported),
                        ),
                        Image.network(
                          restaurant.imageUrl,
                          width: 100,
                          height: 80,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress != null) {
                              return Container(
                                width: 100,
                                height: 80,
                                decoration: AppTheme.containerDecoration(
                                  colorScheme,
                                ),
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 40.0,
                                ),
                              );
                            }
                            return child;
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 80,
                              decoration: AppTheme.containerDecoration(
                                colorScheme,
                              ),
                              child: Icon(
                                Icons.image_not_supported,
                                color: colorScheme.onSurfaceVariant,
                                size: 40.0,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            restaurant.name,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        FavoriteButton(restaurant: restaurant, size: 24.0),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16.0,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: 4.0),
                        Expanded(
                          child: Text(
                            restaurant.city,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16.0,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 4.0),
                        Expanded(
                          child: Text(
                            restaurant.rating.toString(),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      restaurant.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
