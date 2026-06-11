import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

// Global notifier for theme switching
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'CUES',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          home: const SplashScreen(),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1A365D),
        onPrimary: Colors.white,
        secondary: Color(0xFF4A5568),
        onSecondary: Colors.white,
        tertiary: Color(0xFFFF8A00),
        onTertiary: Color(0xFF1A202C),
        surface: Colors.white,
        onSurface: Color(0xFF1A365D),
        error: Color(0xFFE53E3E),
      ),
      scaffoldBackgroundColor: const Color(0xFFF7FAFC),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A365D),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Color(0xFFFF8A00),
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      cardTheme: const CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFF8A00),
        foregroundColor: Color(0xFF1A202C),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF90CDF4),
        onPrimary: Color(0xFF1A202C),
        secondary: Color(0xFFA0AEC0),
        onSecondary: Color(0xFF1A202C),
        tertiary: Color(0xFFFF8A00),
        onTertiary: Color(0xFF1A202C),
        surface: Color(0xFF2D3748),
        onSurface: Color(0xFFEDF2F7),
        error: Color(0xFFFC8181),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A202C),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A202C),
        foregroundColor: Color(0xFFEDF2F7),
        centerTitle: true,
        elevation: 0,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Color(0xFF90CDF4),
        unselectedLabelColor: Colors.white60,
        indicatorColor: Color(0xFFFF8A00),
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF2D3748),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFF8A00),
        foregroundColor: Color(0xFF1A202C),
      ),
    );
  }
}
