import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UserState extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  Future<void> login(Map<String, dynamic> loginData) async {
    _user = loginData['user'] as UserModel;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', _user!.id);
    notifyListeners();
  }

  Future<void> loadUser () async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId != null) {
      try {
        _user = await ApiService.getProfile(userId);
        notifyListeners();
      } catch (e) {
        // Token invalid, clear
        await logout();
      }
    }
  }

  Future<void> logout() async {
    _user = null;
    await ApiService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    notifyListeners();
  }
}