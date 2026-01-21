import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'services/user_service.dart';
import 'services/mining_service.dart';
import 'services/task_service.dart';
import 'services/leaderboard_service.dart';
import 'services/ad_service.dart';
import 'services/google_auth_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Mobile Ads
  await MobileAds.instance.initialize();
  
  runApp(const VoidiumMinerApp());
}

class VoidiumMinerApp extends StatelessWidget {
  const VoidiumMinerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserService()),
        ChangeNotifierProvider(create: (_) => AdService()),
        ChangeNotifierProvider(create: (_) => GoogleAuthService()),
        ChangeNotifierProxyProvider<UserService, MiningService>(
          create: (context) => MiningService(context.read<UserService>()),
          update: (context, userService, previous) =>
              previous ?? MiningService(userService),
        ),
        ChangeNotifierProxyProvider<UserService, TaskService>(
          create: (context) => TaskService(context.read<UserService>()),
          update: (context, userService, previous) =>
              previous ?? TaskService(userService),
        ),
        ChangeNotifierProxyProvider<UserService, LeaderboardService>(
          create: (context) => LeaderboardService(context.read<UserService>()),
          update: (context, userService, previous) =>
              previous ?? LeaderboardService(userService),
        ),
      ],
      child: MaterialApp(
        title: 'Voidium Miner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          
          // Primary colors matching Style 1
          primaryColor: const Color(0xFF8B5CF6), // Neon purple
          scaffoldBackgroundColor: const Color(0xFF0A0E27), // Dark navy
          
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF8B5CF6), // Neon purple
            secondary: Color(0xFF06B6D4), // Cyan
            surface: Color(0xFF1A1F3A), // Slightly lighter navy
            error: Color(0xFFEF4444),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.white,
            onError: Colors.white,
          ),
          
          // AppBar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0A0E27),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          // Card theme for glassmorphism effect
          cardTheme: CardThemeData(
            color: const Color(0xFF1A1F3A).withValues(alpha: 0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          
          // Elevated button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Text theme
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            displayMedium: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          
          // Input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1A1F3A).withValues(alpha: 0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF8B5CF6),
                width: 2,
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
