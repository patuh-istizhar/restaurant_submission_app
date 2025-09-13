import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/restaurant.dart';
import '../providers/favorites_provider.dart';
import '../providers/navigation_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_error_widget.dart';
import '../widgets/restaurant_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restoran Favorit'),
        automaticallyImplyLeading: false,
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, provider, child) =>
                _buildAppBarActions(context, provider),
          ),
        ],
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading &&
              provider.favorites.isEmpty &&
              !provider.hasError) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.hasError && provider.favorites.isEmpty) {
            return _buildErrorWidget(provider.message, provider);
          }
          if (provider.favorites.isEmpty) {
            return _buildEmptyFavoritesView(context);
          }
          return _buildFavoritesListView(context, provider.favorites, provider);
        },
      ),
    );
  }

  Widget _buildAppBarActions(BuildContext context, FavoritesProvider provider) {
    if (provider.favorites.isEmpty || provider.hasError) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'clear_all') {
          _showClearAllDialog(context, provider);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'clear_all',
          child: Row(
            children: [
              Icon(
                Icons.clear_all,
                size: 20.0,
                color: theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8.0),
              Text('Hapus Semua', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  void _showClearAllDialog(BuildContext context, FavoritesProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Semua Favorit?'),
          content: const Text(
            'Semua restoran akan dihapus dari daftar favorit. Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(dialogContext);
                await provider.clearAllFavorites();
                messenger.showSnackBar(
                  SnackBar(content: Text(provider.message)),
                );
              },
              child: const Text('Hapus Semua'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyFavoritesView(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer.withAlpha(
                  (0.3 * 255).round(),
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 64.0,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24.0),
            Text('Belum Ada Favorit', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12.0),
            Text(
              'Tambahkan restoran ke favorit untuk melihatnya di sini',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            FilledButton.icon(
              onPressed: () {
                Provider.of<NavigationProvider>(
                  context,
                  listen: false,
                ).changeNavigationIndex(0);
              },
              icon: const Icon(Icons.explore),
              label: const Text('Jelajahi Restoran'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesListView(
    BuildContext context,
    List<Restaurant> favorites,
    FavoritesProvider provider,
  ) {
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () => provider.loadFavorites(),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
            decoration: AppTheme.containerDecoration(theme.colorScheme),
            child: Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: theme.colorScheme.primary,
                  size: 20.0,
                ),
                const SizedBox(width: 12.0),
                Flexible(
                  child: Text(
                    '${favorites.length} restoran favorit',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return RestaurantCard(restaurant: favorites[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message, FavoritesProvider provider) {
    return CustomErrorWidget(
      message: message,
      onRetry: () => provider.loadFavorites(),
    );
  }
}
