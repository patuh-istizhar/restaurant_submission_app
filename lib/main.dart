import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/services/api_service.dart';
import 'providers/favorites_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/restaurant_provider.dart';
import 'providers/review_provider.dart';
import 'providers/search_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'utils/app_theme.dart';
import 'utils/notification_helper.dart';
import 'utils/platform_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!PlatformUtils.isWeb) await NotificationHelper.initialize();

  final apiService = ApiService();

  runApp(MyApp(apiService: apiService));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;

  const MyApp({super.key, required this.apiService});

  static final _lightTheme = AppTheme.themeFromScheme(
    AppTheme.defaultLightScheme(),
  );
  static final _darkTheme = AppTheme.themeFromScheme(
    AppTheme.defaultDarkScheme(),
  );

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(
          create: (_) => RestaurantProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => ReviewProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(create: (_) => FavoritesProvider.defaultSync()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Restaurant App',
            debugShowCheckedModeBanner: false,
            theme: _lightTheme,
            darkTheme: _darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
