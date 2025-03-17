import 'package:diabetes_test/providers/connectivity_provider.dart';
import 'package:diabetes_test/providers/health_tips_provider.dart';
import 'package:diabetes_test/providers/streak_provider.dart';
import 'package:diabetes_test/providers/test_results_provider.dart';
import 'package:diabetes_test/providers/theme_provider.dart';
import 'package:diabetes_test/providers/user_auth_provider.dart';
import 'package:diabetes_test/routes/app_routes.dart';
import 'package:diabetes_test/services/database_service.dart';
import 'package:diabetes_test/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        ChangeNotifierProvider(create: (_) => UserAuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => StreakProvider()),
        
        // HealthTipsProvider
        ChangeNotifierProxyProvider<UserAuthProvider, HealthTipsProvider>(
          create: (_) => HealthTipsProvider(),
          update: (_, authProvider, previous) =>
              previous!..updateAuth(authProvider),
        ),

        // TestResultsProvider
        ChangeNotifierProxyProvider2<UserAuthProvider, DatabaseService, TestResultsProvider>(
          create: (_) => TestResultsProvider(),
          update: (_, authProvider, dbService, previous) =>
              previous!..initialize(authProvider, dbService),
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
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  // Replace TextScaler with textScaleFactor for compatibility
                  textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.4),
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