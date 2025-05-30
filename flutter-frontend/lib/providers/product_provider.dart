import 'package:flutter/material.dart';
import 'dart:io';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/sample_data_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _featuredProducts = [];
  List<Product> _myProducts = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;
  bool _useSampleData = true; // Flag to use sample data when API fails

  List<Product> get products => _products;
  List<Product> get featuredProducts => _featuredProducts;
  List<Product> get myProducts => _myProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> fetchProducts({
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    double? latitude,
    double? longitude,
    double? radius,
    String? condition,
    String? sortBy,
    String? sortOrder,
    bool? featuredFirst,
    bool refresh = false,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMoreData = true;
      _products.clear();
    }

    if (!_hasMoreData || _isLoading) return;

    _setLoading(true);
    _setError(null);

    try {
      final queryParams = <String, String>{
        'page': _currentPage.toString(),
        'per_page': '15',
      };

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (categoryId != null) queryParams['category_id'] = categoryId.toString();
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (latitude != null) queryParams['latitude'] = latitude.toString();
      if (longitude != null) queryParams['longitude'] = longitude.toString();
      if (radius != null) queryParams['radius'] = radius.toString();
      if (condition != null) queryParams['condition'] = condition;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;
      if (featuredFirst != null) queryParams['featured_first'] = featuredFirst.toString();

      final uri = Uri.parse('${ApiService.baseUrl}/products').replace(queryParameters: queryParams);
      final response = await ApiService.get(uri.toString().replaceFirst('${ApiService.baseUrl}', ''), includeAuth: false);

      if (response['success']) {
        final data = response['data'];
        final List<dynamic> productList = data['data'];
        final newProducts = productList.map((json) => Product.fromJson(json)).toList();

        if (refresh) {
          _products = newProducts;
        } else {
          _products.addAll(newProducts);
        }

        _hasMoreData = data['next_page_url'] != null;
        _currentPage++;
      }
    } catch (e) {
      _setError(e.toString());
      
      // Fallback to sample data if API fails
      if (_useSampleData && _products.isEmpty) {
        _loadSampleProducts(
          search: search,
          categoryId: categoryId,
          minPrice: minPrice,
          maxPrice: maxPrice,
          condition: condition,
        );
      }
    }

    _setLoading(false);
  }

  void _loadSampleProducts({
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? condition,
  }) {
    var sampleProducts = SampleDataService.getSampleProducts();

    // Apply filters
    if (search != null && search.isNotEmpty) {
      sampleProducts = sampleProducts.where((product) =>
        product.title.toLowerCase().contains(search.toLowerCase()) ||
        product.description.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }

    if (categoryId != null) {
      sampleProducts = sampleProducts.where((product) => product.categoryId == categoryId).toList();
    }

    if (minPrice != null) {
      sampleProducts = sampleProducts.where((product) => product.price >= minPrice).toList();
    }

    if (maxPrice != null) {
      sampleProducts = sampleProducts.where((product) => product.price <= maxPrice).toList();
    }

    if (condition != null && condition != 'all') {
      sampleProducts = sampleProducts.where((product) => product.condition == condition).toList();
    }

    _products = sampleProducts;
    _hasMoreData = false;
  }

  Future<void> fetchFeaturedProducts() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.get('/products/featured', includeAuth: false);

      if (response['success']) {
        final List<dynamic> productList = response['data'];
        _featuredProducts = productList.map((json) => Product.fromJson(json)).toList();
      }
    } catch (e) {
      _setError(e.toString());
      
      // Fallback to sample data
      if (_useSampleData) {
        _featuredProducts = SampleDataService.getSampleProducts()
            .where((product) => product.isFeatured)
            .toList();
      }
    }

    _setLoading(false);
  }

  Future<void> fetchMyProducts() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.get('/my-products');

      if (response['success']) {
        final data = response['data'];
        final List<dynamic> productList = data['data'];
        _myProducts = productList.map((json) => Product.fromJson(json)).toList();
      }
    } catch (e) {
      _setError(e.toString());
      // For my products, we don't use sample data since it requires authentication
    }

    _setLoading(false);
  }

  Future<Product?> getProduct(int id) async {
    try {
      final response = await ApiService.get('/products/$id', includeAuth: false);

      if (response['success']) {
        return Product.fromJson(response['data']);
      }
    } catch (e) {
      _setError(e.toString());
      
      // Fallback to sample data
      if (_useSampleData) {
        final sampleProducts = SampleDataService.getSampleProducts();
        try {
          return sampleProducts.firstWhere((product) => product.id == id);
        } catch (e) {
          return null;
        }
      }
    }

    return null;
  }

  Future<bool> createProduct({
    required int categoryId,
    required String title,
    required String description,
    required double price,
    required String condition,
    required String location,
    double? latitude,
    double? longitude,
    List<File>? images,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final fields = <String, String>{
        'category_id': categoryId.toString(),
        'title': title,
        'description': description,
        'price': price.toString(),
        'condition': condition,
        'location': location,
      };

      if (latitude != null) fields['latitude'] = latitude.toString();
      if (longitude != null) fields['longitude'] = longitude.toString();

      final response = await ApiService.postMultipart(
        '/products',
        fields,
        images,
        'images[]',
      );

      if (response['success']) {
        final newProduct = Product.fromJson(response['data']);
        _myProducts.insert(0, newProduct);
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  Future<bool> updateProduct({
    required int productId,
    int? categoryId,
    String? title,
    String? description,
    double? price,
    String? condition,
    String? location,
    double? latitude,
    double? longitude,
    String? status,
    List<File>? images,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final fields = <String, String>{};

      if (categoryId != null) fields['category_id'] = categoryId.toString();
      if (title != null) fields['title'] = title;
      if (description != null) fields['description'] = description;
      if (price != null) fields['price'] = price.toString();
      if (condition != null) fields['condition'] = condition;
      if (location != null) fields['location'] = location;
      if (latitude != null) fields['latitude'] = latitude.toString();
      if (longitude != null) fields['longitude'] = longitude.toString();
      if (status != null) fields['status'] = status;

      Map<String, dynamic> response;

      if (images != null && images.isNotEmpty) {
        response = await ApiService.postMultipart(
          '/products/$productId',
          fields,
          images,
          'images[]',
        );
      } else {
        final data = <String, dynamic>{};
        fields.forEach((key, value) {
          if (key == 'category_id') {
            data[key] = int.parse(value);
          } else if (key == 'price' || key == 'latitude' || key == 'longitude') {
            data[key] = double.parse(value);
          } else {
            data[key] = value;
          }
        });

        response = await ApiService.put('/products/$productId', data);
      }

      if (response['success']) {
        final updatedProduct = Product.fromJson(response['data']);
        final index = _myProducts.indexWhere((p) => p.id == productId);
        if (index != -1) {
          _myProducts[index] = updatedProduct;
        }
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  Future<bool> deleteProduct(int productId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.delete('/products/$productId');

      if (response['success']) {
        _myProducts.removeWhere((p) => p.id == productId);
        _products.removeWhere((p) => p.id == productId);
        _setLoading(false);
        return true;
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  void clearProducts() {
    _products.clear();
    _currentPage = 1;
    _hasMoreData = true;
    notifyListeners();
  }
}
