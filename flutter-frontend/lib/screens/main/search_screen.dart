import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../products/product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  Category? _selectedCategory;
  String _selectedCondition = 'all';
  String _sortBy = 'created_at';
  String _sortOrder = 'desc';
  double _minPrice = 0;
  double _maxPrice = 10000;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadMoreProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    final productProvider = context.read<ProductProvider>();
    
    await productProvider.fetchProducts(
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      categoryId: _selectedCategory?.id,
      minPrice: _minPrice > 0 ? _minPrice : null,
      maxPrice: _maxPrice < 10000 ? _maxPrice : null,
      condition: _selectedCondition == 'all' ? null : _selectedCondition,
      sortBy: _sortBy,
      sortOrder: _sortOrder,
      refresh: refresh,
    );
  }

  Future<void> _loadMoreProducts() async {
    final productProvider = context.read<ProductProvider>();
    if (!productProvider.isLoading && productProvider.hasMoreData) {
      await productProvider.fetchProducts(
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        categoryId: _selectedCategory?.id,
        minPrice: _minPrice > 0 ? _minPrice : null,
        maxPrice: _maxPrice < 10000 ? _maxPrice : null,
        condition: _selectedCondition == 'all' ? null : _selectedCondition,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        refresh: false,
      );
    }
  }

  void _onSearch() {
    _loadProducts(refresh: true);
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedCondition = 'all';
      _sortBy = 'created_at';
      _sortOrder = 'desc';
      _minPrice = 0;
      _maxPrice = 10000;
    });
    _loadProducts(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Products'),
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),

          // Filters
          if (_showFilters) _buildFiltersSection(),

          // Products List
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading && productProvider.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (productProvider.products.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => _loadProducts(refresh: true),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: productProvider.products.length + (productProvider.hasMoreData ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == productProvider.products.length) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final product = productProvider.products[index];
                      return _buildProductCard(product);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Filter
          Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Category'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<Category?>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    hint: const Text('All Categories'),
                    items: [
                      const DropdownMenuItem<Category?>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...categoryProvider.categories.map((category) {
                        return DropdownMenuItem<Category?>(
                          value: category,
                          child: Text(category.name),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                      _loadProducts(refresh: true);
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // Condition Filter
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Condition'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Conditions')),
                  DropdownMenuItem(value: 'new', child: Text('New')),
                  DropdownMenuItem(value: 'used', child: Text('Used')),
                  DropdownMenuItem(value: 'refurbished', child: Text('Refurbished')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value!;
                  });
                  _loadProducts(refresh: true);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price Range
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Price Range: \$${_minPrice.toInt()} - \$${_maxPrice.toInt()}'),
              RangeSlider(
                values: RangeValues(_minPrice, _maxPrice),
                min: 0,
                max: 10000,
                divisions: 100,
                onChanged: (values) {
                  setState(() {
                    _minPrice = values.start;
                    _maxPrice = values.end;
                  });
                },
                onChangeEnd: (values) {
                  _loadProducts(refresh: true);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sort Options
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sort By'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _sortBy,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'created_at', child: Text('Date')),
                        DropdownMenuItem(value: 'price', child: Text('Price')),
                        DropdownMenuItem(value: 'views', child: Text('Popularity')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                        });
                        _loadProducts(refresh: true);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _sortOrder,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'desc', child: Text('Descending')),
                        DropdownMenuItem(value: 'asc', child: Text('Ascending')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortOrder = value!;
                        });
                        _loadProducts(refresh: true);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: product.mainImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.mainImageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 30),
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.formattedPrice,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.conditionDisplay,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            product.location,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
