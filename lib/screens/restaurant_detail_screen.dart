import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/restaurant.dart';
import '../data/models/restaurant_detail.dart';
import '../providers/restaurant_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_error_widget.dart';
import '../widgets/favorite_button.dart';
import '../widgets/review_section.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the restaurant detail when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RestaurantProvider>(
        context,
        listen: false,
      ).fetchRestaurantDetail(widget.restaurant.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RestaurantProvider>(
        builder: (context, provider, child) {
          final state = provider.detailState;

          return switch (state) {
            RestaurantDetailLoading() => _buildLoadingUI(
              context,
              widget.restaurant,
            ),
            RestaurantDetailSuccess(restaurant: final detailedRestaurant) =>
              _buildSuccessUI(context, detailedRestaurant),
            RestaurantDetailError(message: final message) => _buildErrorUI(
              context,
              message,
              provider,
              widget.restaurant,
            ),
            RestaurantDetailInitial() => _buildLoadingUI(
              context,
              widget.restaurant,
            ),
          };
        },
      ),
    );
  }

  Widget _buildLoadingUI(BuildContext context, Restaurant restaurant) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
        actions: [_buildFavoriteButton(context, restaurant)],
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildSuccessUI(
    BuildContext context,
    RestaurantDetail detailedRestaurant,
  ) {
    return CustomScrollView(
      slivers: [
        _RestaurantDetailAppBar(restaurant: detailedRestaurant),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RestaurantInfoSection(restaurant: detailedRestaurant),
                const SizedBox(height: 24.0),
                _CategoriesSection(categories: detailedRestaurant.categories),
                if (detailedRestaurant.categories.isNotEmpty)
                  const SizedBox(height: 24.0),
                _MenuSection(menus: detailedRestaurant.menus),
                if (detailedRestaurant.menus.foods.isNotEmpty ||
                    detailedRestaurant.menus.drinks.isNotEmpty)
                  const SizedBox(height: 24.0),
                ReviewSection(restaurant: detailedRestaurant),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorUI(
    BuildContext context,
    String message,
    RestaurantProvider provider,
    Restaurant restaurant,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurant.name),
        actions: [_buildFavoriteButton(context, restaurant)],
      ),
      body: CustomErrorWidget(
        message: message,
        onRetry: () => provider.retryDetail(restaurant.id),
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context, Restaurant restaurant) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: FavoriteButton(restaurant: restaurant, size: 28.0),
    );
  }
}

class _RestaurantDetailAppBar extends StatelessWidget {
  final RestaurantDetail restaurant;

  const _RestaurantDetailAppBar({required this.restaurant});

  Widget _buildFavoriteButton(
    BuildContext context,
    RestaurantDetail restaurant,
  ) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: FavoriteButton(restaurant: restaurant, size: 28.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      actions: [_buildFavoriteButton(context, restaurant)],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          restaurant.name,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            shadows: [
              Shadow(
                offset: const Offset(1, 1),
                blurRadius: 3,
                color: theme.colorScheme.onSurface.withAlpha(
                  (0.5 * 255).round(),
                ),
              ),
            ],
          ),
        ),
        background: Hero(
          tag: 'restaurant-${restaurant.id}',
          child: Image.network(
            restaurant.largeImageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress != null) {
                return Container(
                  color: theme.colorScheme.surface,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.image_not_supported,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 50.0,
                  ),
                );
              }
              return child;
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: theme.colorScheme.surface,
                alignment: Alignment.center,
                child: Icon(
                  Icons.image_not_supported,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 50.0,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RestaurantInfoSection extends StatelessWidget {
  final RestaurantDetail restaurant;

  const _RestaurantInfoSection({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on, color: colorScheme.error, size: 20.0),
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                '${restaurant.address}, ${restaurant.city}',
                style: textTheme.titleMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Icon(Icons.star, color: colorScheme.secondary, size: 20.0),
            const SizedBox(width: 8.0),
            Text(restaurant.rating.toString(), style: textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 16.0),
        Text(
          'Tentang Restoran',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: AppTheme.containerDecoration(colorScheme),
          child: Text(
            restaurant.description,
            style: textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}

class _CategoriesSection extends StatelessWidget {
  final List<Category> categories;

  const _CategoriesSection({required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: categories
              .map(
                (category) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    category.name,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _MenuItemListWidget extends StatelessWidget {
  final String title;
  final IconData sectionIcon;
  final Color iconColor;
  final Color itemBackgroundColor;
  final IconData itemIcon;
  final List<MenuItem> items;

  const _MenuItemListWidget({
    required this.title,
    required this.sectionIcon,
    required this.iconColor,
    required this.itemBackgroundColor,
    required this.itemIcon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(sectionIcon, color: iconColor, size: 20.0),
            const SizedBox(width: 8.0),
            Text(
              title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12.0),
        ...items.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: AppTheme.containerDecoration(colorScheme),
            child: Row(
              children: [
                Icon(itemIcon, size: 18.0, color: iconColor),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    item.name,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }
}

class _MenuSection extends StatelessWidget {
  final Menus menus;

  const _MenuSection({required this.menus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    bool hasFoods = menus.foods.isNotEmpty;
    bool hasDrinks = menus.drinks.isNotEmpty;

    if (!hasFoods && !hasDrinks) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24.0),
        _MenuItemListWidget(
          title: 'Makanan',
          sectionIcon: Icons.restaurant,
          iconColor: colorScheme.primary,
          itemBackgroundColor: colorScheme.primaryContainer,
          itemIcon: Icons.fastfood,
          items: menus.foods,
        ),
        _MenuItemListWidget(
          title: 'Minuman',
          sectionIcon: Icons.local_cafe,
          iconColor: colorScheme.secondary,
          itemBackgroundColor: colorScheme.secondaryContainer,
          itemIcon: Icons.local_drink,
          items: menus.drinks,
        ),
      ],
    );
  }
}
