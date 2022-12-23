import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

class AppTheme{
  static bool isDarkModeEnable = false;

  static Future<void> getDarkTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isDarkModeEnable = sharedPreferences.getBool('isDark')?? false;
  }
}