import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/restaurant.dart';
import '../providers/search_provider.dart';
import '../widgets/custom_error_widget.dart';
import '../widgets/restaurant_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildInitialView(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 80.0,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16.0),
          Text('Cari restoran favoritmu!', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildSearchResults(List<Restaurant> restaurants) {
    return ListView.builder(
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        return RestaurantCard(restaurant: restaurants[index]);
      },
    );
  }

  Widget _buildErrorView(
    String message,
    SearchProvider provider,
    String currentQuery,
  ) {
    return CustomErrorWidget(
      message: message,
      onRetry: () => provider.searchRestaurants(currentQuery),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80.0,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16.0),
          Text('Restoran tidak ditemukan', style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Cari berdasarkan nama atau menu...',
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            border: theme.inputDecorationTheme.border,
            enabledBorder: theme.inputDecorationTheme.enabledBorder,
            focusedBorder: theme.inputDecorationTheme.focusedBorder,
            suffixIcon: searchProvider.query.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: theme.colorScheme.onSurface),
                    onPressed: () {
                      _searchController.clear();
                      context.read<SearchProvider>().clear();
                    },
                  )
                : null,
          ),
          style: theme.textTheme.bodyLarge,
          onChanged: (query) {
            context.read<SearchProvider>().searchRestaurants(query);
          },
          onSubmitted: (query) {
            context.read<SearchProvider>().searchRestaurants(query);
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: Builder(
        builder: (context) {
          final state = searchProvider.state;
          final currentQuery = searchProvider.query;

          return switch (state) {
            SearchInitial() => _buildInitialView(context),
            SearchLoading() => _buildLoadingIndicator(),
            SearchSuccess(restaurants: final restaurants) =>
              _buildSearchResults(restaurants),
            SearchError(message: final message) => _buildErrorView(
              message,
              searchProvider,
              currentQuery,
            ),
            SearchEmpty() => _buildEmptyView(context),
          };
        },
      ),
    );
  }
}
