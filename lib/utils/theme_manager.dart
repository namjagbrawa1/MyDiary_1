import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static const String _themeKey = 'app_theme';
  static const String _userNameKey = 'user_name';
  static const String _profilePictureKey = 'profile_picture';

  // Theme types
  static const int themeTaki = 0;
  static const int themeMitsuha = 1;

  // Theme colors
  static const Map<int, Color> themeColors = {
    themeTaki: Color(0xFF2196F3), // Blue
    themeMitsuha: Color(0xFFE91E63), // Pink
  };

  // Theme names
  static const Map<int, String> themeNames = {
    themeTaki: 'Taki',
    themeMitsuha: 'Mitsuha',
  };

  // Default user names
  static const Map<int, String> defaultUserNames = {
    themeTaki: 'Taki',
    themeMitsuha: 'Mitsuha',
  };

  static Future<int> getCurrentTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_themeKey) ?? themeTaki;
  }

  static Future<void> setTheme(int theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme);
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = await getCurrentTheme();
    return prefs.getString(_userNameKey) ?? defaultUserNames[theme]!;
  }

  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  static Future<String?> getProfilePicture() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profilePictureKey);
  }

  static Future<void> setProfilePicture(String? path) async {
    final prefs = await SharedPreferences.getInstance();
    if (path != null) {
      await prefs.setString(_profilePictureKey, path);
    } else {
      await prefs.remove(_profilePictureKey);
    }
  }

  static Color getThemeColor(int theme) {
    return themeColors[theme] ?? themeColors[themeTaki]!;
  }

  static String getThemeName(int theme) {
    return themeNames[theme] ?? themeNames[themeTaki]!;
  }

  static String getDefaultUserName(int theme) {
    return defaultUserNames[theme] ?? defaultUserNames[themeTaki]!;
  }

  static ThemeData getThemeData(int theme) {
    final primaryColor = getThemeColor(theme);
    
    return ThemeData(
      primarySwatch: _createMaterialColor(primaryColor),
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: primaryColor),
        ),
        labelStyle: TextStyle(color: primaryColor),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        }),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return null;
        }),
      ),
    );
  }

  static MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  // Weather icons
  static IconData getWeatherIcon(int weather) {
    switch (weather) {
      case 0: // Sunny
        return Icons.wb_sunny;
      case 1: // Cloudy
        return Icons.cloud;
      case 2: // Rainy
        return Icons.grain;
      case 3: // Snowy
        return Icons.ac_unit;
      case 4: // Foggy
        return Icons.foggy;
      case 5: // Windy
        return Icons.air;
      default:
        return Icons.wb_sunny;
    }
  }

  // Mood icons
  static IconData getMoodIcon(int mood) {
    switch (mood) {
      case 0: // Happy
        return Icons.sentiment_very_satisfied;
      case 1: // Neutral
        return Icons.sentiment_neutral;
      case 2: // Sad
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }

  // Topic type icons
  static IconData getTopicIcon(int type) {
    switch (type) {
      case 0: // Diary
        return Icons.book;
      case 1: // Memo
        return Icons.note;
      case 2: // Contacts
        return Icons.people;
      default:
        return Icons.folder;
    }
  }

  // Background gradients for themes
  static LinearGradient getThemeGradient(int theme) {
    switch (theme) {
      case themeTaki:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2196F3),
            Color(0xFF21CBF3),
          ],
        );
      case themeMitsuha:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE91E63),
            Color(0xFFFF6B9D),
          ],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2196F3),
            Color(0xFF21CBF3),
          ],
        );
    }
  }
}