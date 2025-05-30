import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    required String role,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.post('/register', {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'phone': phone,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'role': role,
      }, includeAuth: false);

      if (response['success']) {
        final userData = response['data'];
        _user = User.fromJson(userData['user']);
        await ApiService.setToken(userData['access_token']);
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.post('/login', {
        'email': email,
        'password': password,
      }, includeAuth: false);

      if (response['success']) {
        final userData = response['data'];
        _user = User.fromJson(userData['user']);
        await ApiService.setToken(userData['access_token']);
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  Future<void> logout() async {
    try {
      await ApiService.post('/logout', {});
    } catch (e) {
      // Continue with logout even if API call fails
    }

    await ApiService.removeToken();
    _user = null;
    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    final token = await ApiService.getToken();
    if (token == null) return false;

    try {
      final response = await ApiService.get('/user');
      if (response['success']) {
        _user = User.fromJson(response['data']);
        notifyListeners();
        return true;
      }
    } catch (e) {
      await ApiService.removeToken();
    }

    return false;
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;

      final response = await ApiService.put('/user/profile', data);

      if (response['success']) {
        _user = User.fromJson(response['data']);
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }
}
