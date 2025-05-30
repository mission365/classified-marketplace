import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../services/sample_data_service.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  bool _useSampleData = true; // Flag to use sample data when API fails

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.get('/categories', includeAuth: false);

      if (response['success']) {
        final List<dynamic> categoryList = response['data'];
        _categories = categoryList.map((json) => Category.fromJson(json)).toList();
      }
    } catch (e) {
      _setError(e.toString());
      
      // Fallback to sample data if API fails
      if (_useSampleData) {
        _categories = SampleDataService.getSampleCategories();
      }
    }

    _setLoading(false);
  }

  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  String getCategoryName(int id) {
    final category = getCategoryById(id);
    return category?.name ?? 'Unknown Category';
  }
}
