import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import 'favorites_screen.dart';
import 'restaurant_list_screen.dart';
import 'search_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  final List<Widget> _screens = const [
    RestaurantListScreen(),
    SearchScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  List<NavigationDestination> _buildNavigationDestinations() {
    return const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Beranda',
      ),
      NavigationDestination(
        icon: Icon(Icons.search_outlined),
        selectedIcon: Icon(Icons.search),
        label: 'Cari',
      ),
      NavigationDestination(
        icon: Icon(Icons.favorite_outline),
        selectedIcon: Icon(Icons.favorite),
        label: 'Favorit',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Pengaturan',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navigation, child) {
        return Scaffold(
          body: IndexedStack(
            index: navigation.currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigation.currentIndex,
            onDestinationSelected: (index) {
              navigation.changeNavigationIndex(index);
            },
            destinations: _buildNavigationDestinations(),
          ),
        );
      },
    );
  }
}
