import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreditsProvider extends ChangeNotifier {
  int _credits = 0;
  bool _hasSubscribed = false;

  int get credits => _credits;
  bool get hasSubscribed => _hasSubscribed;

  CreditsProvider() {
    _loadCredits();
  }

  Future<void> _loadCredits() async {
    final prefs = await SharedPreferences.getInstance();
    _credits = prefs.getInt('credits') ?? 0;
    _hasSubscribed = prefs.getBool('hasSubscribed') ?? false;
    notifyListeners();
  }

  Future<void> addCreditsForSubscription(String productId) async {
    final prefs = await SharedPreferences.getInstance();

    if (productId == 'weekly_plan_id') {
      _credits = 500;
    } else if (productId == 'yearly_plan_id') {
      _credits = 5000;
    }

    _hasSubscribed = true;
    await prefs.setInt('credits', _credits);
    await prefs.setBool('hasSubscribed', true);
    notifyListeners();
  }

  Future<void> resetCredits() async {
    final prefs = await SharedPreferences.getInstance();
    _credits = 0;
    _hasSubscribed = false;
    await prefs.setInt('credits', _credits);
    await prefs.setBool('hasSubscribed', false);
    notifyListeners();
  }

  Future<void> restoreCredits() async {
    final prefs = await SharedPreferences.getInstance();
    _credits = prefs.getInt('credits') ?? 0;
    _hasSubscribed = prefs.getBool('hasSubscribed') ?? false;
    notifyListeners();
  }

  Future<void> addCredits(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    _credits += amount;
    await prefs.setInt('credits', _credits);
    notifyListeners();
  }

  Future<void> deductCredits(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    _credits = (_credits - amount).clamp(0, _credits); // avoid negative credits
    await prefs.setInt('credits', _credits);
    notifyListeners();
  }
}
