import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/user.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../products/my_products_screen.dart';
import '../profile/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated) {
        context.read<ProductProvider>().fetchMyProducts();
      }
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isAuthenticated) {
                return PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit Profile'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                    ),
                    PopupMenuItem(
                      child: const ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      onTap: _logout,
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isAuthenticated) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, size: 80, color: Colors.blue),
                    const SizedBox(height: 24),
                    Text(
                      'Join Our Community',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create an account to manage your listings, save favorites, and connect with other users.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text('Create Account'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text('Sign In'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Benefits of Creating an Account:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem(Icons.sell, 'Sell your products'),
                    _buildBenefitItem(Icons.message, 'Message other users'),
                    _buildBenefitItem(Icons.favorite, 'Save favorite items'),
                    _buildBenefitItem(Icons.history, 'Track your activity'),
                    _buildBenefitItem(Icons.security, 'Secure transactions'),
                  ],
                ),
              ),
            );
          }

          final user = authProvider.user!;
          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(user),
                
                // Profile Stats
                _buildProfileStats(),
                
                // Menu Items
                _buildMenuItems(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: user.avatarUrl.isNotEmpty
                ? NetworkImage(user.avatarUrl)
                : null,
            child: user.avatarUrl.isEmpty
                ? Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 32),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          if (user.phone != null) ...[
            const SizedBox(height: 4),
            Text(
              user.phone!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: user.isSeller ? Colors.green[100] : Colors.blue[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              user.isSeller ? 'Seller' : 'Buyer',
              style: TextStyle(
                color: user.isSeller ? Colors.green[800] : Colors.blue[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats() {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final myProductsCount = productProvider.myProducts.length;
        final activeProductsCount = productProvider.myProducts
            .where((product) => product.isActive)
            .length;
        final soldProductsCount = productProvider.myProducts
            .where((product) => product.isSold)
            .length;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total Products', myProductsCount.toString()),
              _buildStatItem('Active', activeProductsCount.toString()),
              _buildStatItem('Sold', soldProductsCount.toString()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItems() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.inventory,
            title: 'My Products',
            subtitle: 'Manage your listings',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MyProductsScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.favorite_outline,
            title: 'Favorites',
            subtitle: 'Your saved products',
            onTap: () {
              // TODO: Implement favorites
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favorites feature coming soon!')),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.history,
            title: 'Purchase History',
            subtitle: 'Your buying history',
            onTap: () {
              // TODO: Implement purchase history
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Purchase history feature coming soon!')),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            subtitle: 'App preferences',
            onTap: () {
              // TODO: Implement settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings feature coming soon!')),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help and contact us',
            onTap: () {
              // TODO: Implement help & support
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support feature coming soon!')),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
