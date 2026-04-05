import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

class ThemeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';
  SharedPreferences? _prefs;

  @override
  ThemeMode build() {
    _init();
    return ThemeMode.dark; // Default
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final index = _prefs?.getInt(_key);
    if (index != null) {
      state = ThemeMode.values[index];
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs?.setInt(_key, state.index);
  }
}
