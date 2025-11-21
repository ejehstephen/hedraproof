import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hedera_proof/models/user.dart';
import 'package:hedera_proof/providers/api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final ApiProvider _apiProvider = ApiProvider();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    clearError();
    try {
      if (kDebugMode) {
        _user = User(
          id: 'debug-id',
          name: (email.isNotEmpty ? email.split('@').first : 'Test User'),
          email: email.isNotEmpty ? email : 'test@example.com',
          walletAddress: '0xDEBUGWALLET',
          token: 'debug-token',
        );
        await _saveUserToPrefs();
        _setLoading(false);
        return;
      }
      final responseData = await _apiProvider.login(email, password);
      _user = User.fromJson(responseData);
      await _saveUserToPrefs();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
    }
  }

  Future<void> register(
      String name, String email, String password, String walletAddress) async {
    _setLoading(true);
    clearError();
    try {
      if (kDebugMode) {
        _user = User(
          id: 'debug-id',
          name: name.isNotEmpty ? name : 'Test User',
          email: email.isNotEmpty ? email : 'test@example.com',
          walletAddress: walletAddress.isNotEmpty ? walletAddress : '0xDEBUGWALLET',
          token: 'debug-token',
        );
        await _saveUserToPrefs();
        _setLoading(false);
        return;
      }
      final responseData =
          await _apiProvider.register(name, email, password, walletAddress);
      _user = User.fromJson(responseData);
      await _saveUserToPrefs();
      _setLoading(false);
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final extractedUserData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;

    _user = User.fromJson(extractedUserData);
    notifyListeners();
    return true;
  }

  Future<void> _saveUserToPrefs() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final userData = json.encode(_user!.toJson());
    await prefs.setString('userData', userData);
  }
}
