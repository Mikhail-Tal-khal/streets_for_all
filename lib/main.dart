

import 'package:diabetes_test/firebase_options.dart';
import 'package:diabetes_test/providers/connectivity_provider.dart';
import 'package:diabetes_test/providers/health_tips_provider.dart';
import 'package:diabetes_test/providers/streak_provider.dart';
import 'package:diabetes_test/providers/theme_provider.dart';
import 'package:diabetes_test/providers/user_auth_provider.dart';
import 'package:diabetes_test/routes/app_routes.dart' show AppRoutes;
import 'package:diabetes_test/services/database_service.dart';
import 'package:diabetes_test/test_results_provider.dart';
import 'package:diabetes_test/themes/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services - Create them once and make them available throughout the app
        Provider<DatabaseService>(create: (_) => DatabaseService()),

        // Feature-specific providers - These depend on services
        ChangeNotifierProvider(create: (_) => UserAuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => StreakProvider()),

        // Providers that depend on auth state - We use ProxyProvider to rebuild them when auth changes
        ChangeNotifierProxyProvider<UserAuthProvider, HealthTipsProvider>(
          create: (_) => HealthTipsProvider(),
          update:
              (_, authProvider, previous) =>
                  previous!..updateAuthState(authProvider.isAuthenticated),
        ),
        ChangeNotifierProxyProvider2<
          UserAuthProvider,
          DatabaseService,
          TestResultsProvider
        >(
          create: (_) => TestResultsProvider(),
          update:
              (_, authProvider, dbService, previous) =>
                  previous!..update(authProvider.userId, dbService),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SugarPlus',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            builder: (context, child) {
              // Apply font scaling cap for accessibility while maintaining usability
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    // ignore: deprecated_member_use
                    MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.4),
                  ),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}