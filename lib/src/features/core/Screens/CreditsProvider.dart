import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreditsProvider extends ChangeNotifier {
  int _credits = 0;

  int get credits => _credits;

  CreditsProvider() {
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    final prefs = await SharedPreferences.getInstance();
    _credits = prefs.getInt('credits') ?? 0;
    notifyListeners();
  }

  Future<void> addCredits(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    _credits += amount;
    await prefs.setInt('credits', _credits);
    notifyListeners();
  }

  Future<void> deductCredits(int amount) async {
    if (_credits >= amount) {
      final prefs = await SharedPreferences.getInstance();
      _credits -= amount;
      await prefs.setInt('credits', _credits);
      notifyListeners();
    }
  }

  // Optionally a method to refresh credits from storage (e.g. on app start)
  Future<void> refreshCredits() async {
    final prefs = await SharedPreferences.getInstance();
    _credits = prefs.getInt('credits') ?? 0;
    notifyListeners();
  }
}
