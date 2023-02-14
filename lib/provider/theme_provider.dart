import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/Colors.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      return themeMode == Brightness.dark;
    } else {
      return themeMode == ThemeMode.dark;
    }
  }

  ThemeProvider(bool darkThemeOn) {
    themeMode = darkThemeOn ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme(bool isOn) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (isOn) {
      themeMode = ThemeMode.dark;
      pref.setBool('isDarkTheme', true);
    } else {
      themeMode = ThemeMode.light;
      pref.setBool('isDarkTheme', false);
    }

    notifyListeners();
  }

  ThemeMode getTheme() => themeMode;
}

class AppThemes {
  static final darkTheme = ThemeData(
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(),
      fontFamily: 'SegUI',
      primaryColor: Colors.black,
      textTheme: const TextTheme(
        subtitle1: TextStyle(
            color: whiteColor, fontWeight: FontWeight.bold, fontSize: 18),
        subtitle2: TextStyle(
          color: whiteColor,
          fontSize: 16,
        ),
      ),
      iconTheme: const IconThemeData(color: whiteColor),
      cardColor: primaryColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        titleTextStyle: TextStyle(
            color: whiteColor, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
          linearTrackColor:  Colors.black,
          color:  Colors.black,
          refreshBackgroundColor: Colors.black),
      bottomAppBarColor:  Colors.black,
      highlightColor: primaryColor.withOpacity(0.2),
      indicatorColor:  Colors.black,
      shadowColor: Colors.transparent);
}
