<?php

namespace Database\Seeders;

use App\Models\Product;
use App\Models\User;
use App\Models\Category;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run()
    {
        $users = User::all();
        $categories = Category::all();

        $products = [
            // Electronics
            [
                'title' => 'iPhone 14 Pro Max - Excellent Condition',
                'description' => 'Barely used iPhone 14 Pro Max in excellent condition. Comes with original box, charger, and screen protector already applied. No scratches or dents. Battery health at 98%. Perfect for anyone looking for a premium smartphone experience.',
                'price' => 899.99,
                'condition' => 'used',
                'location' => 'New York, NY',
                'latitude' => 40.7128,
                'longitude' => -74.0060,
                'category' => 'Electronics',
                'is_featured' => true,
                'views' => 245,
                'images' => [
                    'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=500&h=500&fit=crop',
                ],
            ],
            [
                'title' => 'MacBook Air M2 2022 - Like New',
                'description' => 'MacBook Air with M2 chip, 8GB RAM, 256GB SSD. Used for only 3 months. Perfect for students and professionals. Includes original charger and box. No scratches, works perfectly.',
                'price' => 1099.00,
                'condition' => 'used',
                'location' => 'Los Angeles, CA',
                'latitude' => 34.0522,
                'longitude' => -118.2437,
                'category' => 'Electronics',
                'is_featured' => true,
                'views' => 189,
                'images' => [
                    'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500&h=500&fit=crop',
                ],
            ],
            [
                'title' => 'Samsung 65" 4K Smart TV',
                'description' => 'Brand new Samsung 65-inch 4K UHD Smart TV. Still in original packaging. Perfect for home entertainment setup. Latest model with all smart features.',
                'price' => 649.99,
                'condition' => 'new',
                'location' => 'Chicago, IL',
                'latitude' => 41.8781,
                'longitude' => -87.6298,
                'category' => 'Electronics',
                'views' => 156,
                'images' => [
                    'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=500&h=500&fit=crop',
                ],
            ],
            [
                'title' => 'Gaming PC - High Performance',
                'description' => 'Custom built gaming PC with RTX 3080, Intel i7-12700K, 32GB RAM, 1TB NVMe SSD. Perfect for gaming and content creation. Runs all modern games at max settings.',
                'price' => 1899.99,
                'condition' => 'used',
                'location' => 'Houston, TX',
                'latitude' => 29.7604,
                'longitude' => -95.3698,
                'category' => 'Electronics',
                'views' => 298,
                'images' => [
                    'https://images.unsplash.com/photo-1587202372634-32705e3bf49c?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1593640408182-31c70c8268f5?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1612198188060-c7c2a3b66eae?w=500&h=500&fit=crop',
                ],
            ],

            // Vehicles
            [
                'title' => '2020 Honda Civic - Low Mileage',
                'description' => '2020 Honda Civic with only 25,000 miles. Excellent fuel economy, reliable transportation. Clean title, no accidents. Regular maintenance records available. Perfect first car or commuter vehicle.',
                'price' => 18500.00,
                'condition' => 'used',
                'location' => 'Phoenix, AZ',
                'latitude' => 33.4484,
                'longitude' => -112.0740,
                'category' => 'Vehicles',
                'is_featured' => true,
                'views' => 412,
                'images' => [
                    'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1494905998402-395d579af36f?w=500&h=500&fit=crop',
                ],
            ],
            [
                'title' => 'Mountain Bike - Trek X-Caliber 8',
                'description' => 'Trek X-Caliber 8 mountain bike in great condition. Perfect for trail riding and commuting. Recently serviced with new tires and brake pads.',
                'price' => 899.00,
                'condition' => 'used',
                'location' => 'New York, NY',
                'latitude' => 40.7128,
                'longitude' => -74.0060,
                'category' => 'Vehicles',
                'views' => 87,
                'images' => [
                    'https://images.unsplash.com/photo-1544191696-15693072e0b5?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=500&h=500&fit=crop',
                ],
            ],

            // Home & Garden
            [
                'title' => 'Sectional Sofa - Modern Design',
                'description' => 'Beautiful modern sectional sofa in gray fabric. Very comfortable and in excellent condition. Perfect for living room. Seats 6 people comfortably. Pet-free and smoke-free home.',
                'price' => 799.99,
                'condition' => 'used',
                'location' => 'Los Angeles, CA',
                'latitude' => 34.0522,
                'longitude' => -118.2437,
                'category' => 'Home & Garden',
                'views' => 134,
                'images' => [
                    'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=500&h=500&fit=crop',
                ],
            ],
            [
                'title' => 'Dining Table Set - 6 Chairs',
                'description' => 'Solid wood dining table with 6 matching chairs. Perfect for family dinners and entertaining guests. Excellent condition, no scratches or damage.',
                'price' => 599.00,
                'condition' => 'used',
                'location' => 'Chicago, IL',
                'latitude' => 41.8781,
                'longitude' => -87.6298,
                'category' => 'Home & Garden',
                'views' => 98,
                'images' => [
                    'https://images.unsplash.com/photo-1449247709967-d4461a6a6103?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?w=500&h=500&fit=crop',
                ],
            ],

            // Fashion
            [
                'title' => 'Designer Handbag - Louis Vuitton',
                'description' => 'Authentic Louis Vuitton handbag in excellent condition. Comes with authenticity certificate and dust bag. Purchased from official LV store. Perfect for special occasions or everyday luxury.',
                'price' => 1299.99,
                'condition' => 'used',
                'location' => 'Houston, TX',
                'latitude' => 29.7604,
                'longitude' => -95.3698,
                'category' => 'Fashion',
                'is_featured' => true,
                'views' => 267,
                'images' => [
                    'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1594633312681-425c7b97ccd1?w=500&h=500&fit=crop',
                ],
            ],
            [
                'title' => 'Nike Air Jordan 1 - Size 10',
                'description' => 'Classic Nike Air Jordan 1 sneakers in size 10. Gently used, great condition. Perfect for sneaker collectors or everyday wear. Authentic with original box.',
                'price' => 189.99,
                'condition' => 'used',
                'location' => 'Phoenix, AZ',
                'latitude' => 33.4484,
                'longitude' => -112.0740,
                'category' => 'Fashion',
                'views' => 156,
                'images' => [
                    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?w=500&h=500&fit=crop',
                ],
            ],

            // Sports & Recreation
            [
                'title' => 'Golf Club Set - Complete Beginner Set',
                'description' => 'Complete golf club set perfect for beginners. Includes driver, irons, putter, and golf bag. Great condition. Perfect for someone just starting to learn golf.',
                'price' => 299.99,
                'condition' => 'used',
                'location' => 'New York, NY',
                'latitude' => 40.7128,
                'longitude' => -74.0060,
                'category' => 'Sports & Recreation',
                'views' => 76,
                'images' => [
                    'https://images.unsplash.com/photo-1535131749006-b7f58c99034b?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500&h=500&fit=crop',
                ],
            ],
            [
                'title' => 'Treadmill - NordicTrack Commercial',
                'description' => 'Professional grade NordicTrack treadmill. Excellent for home workouts. Barely used, like new condition. Includes all original accessories and manual.',
                'price' => 1199.00,
                'condition' => 'used',
                'location' => 'Los Angeles, CA',
                'latitude' => 34.0522,
                'longitude' => -118.2437,
                'category' => 'Sports & Recreation',
                'views' => 143,
                'images' => [
                    'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=500&h=500&fit=crop',
                ],
            ],

            // Books & Media
            [
                'title' => 'Textbook Collection - Computer Science',
                'description' => 'Collection of computer science textbooks including algorithms, data structures, and programming languages. Perfect for students or professionals.',
                'price' => 149.99,
                'condition' => 'used',
                'location' => 'Chicago, IL',
                'latitude' => 41.8781,
                'longitude' => -87.6298,
                'category' => 'Books & Media',
                'views' => 45,
                'images' => [
                    'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=500&fit=crop',
                ],
            ],

            // Pets & Animals
            [
                'title' => 'Dog Crate - Large Size',
                'description' => 'Large dog crate suitable for big breeds. Excellent condition, easy to assemble and transport. Perfect for training or travel.',
                'price' => 89.99,
                'condition' => 'used',
                'location' => 'Houston, TX',
                'latitude' => 29.7604,
                'longitude' => -95.3698,
                'category' => 'Pets & Animals',
                'views' => 67,
                'images' => [
                    'https://images.unsplash.com/photo-1601758228041-f3b2795255f1?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?w=500&h=500&fit=crop',
                ],
            ],

            // Services
            [
                'title' => 'Web Development Services',
                'description' => 'Professional web development services. Specializing in modern websites and e-commerce solutions. Contact for custom quotes.',
                'price' => 99.99,
                'condition' => 'new',
                'location' => 'Phoenix, AZ',
                'latitude' => 33.4484,
                'longitude' => -112.0740,
                'category' => 'Services',
                'views' => 234,
                'images' => [
                    'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=500&h=500&fit=crop',
                    'https://images.unsplash.com/photo-1553877522-43269d4ea984?w=500&h=500&fit=crop',
                ],
            ],
        ];

        foreach ($products as $productData) {
            $category = $categories->where('name', $productData['category'])->first();
            $user = $users->random();

            if ($category) {
                Product::create([
                    'user_id' => $user->id,
                    'category_id' => $category->id,
                    'title' => $productData['title'],
                    'description' => $productData['description'],
                    'price' => $productData['price'],
                    'condition' => $productData['condition'],
                    'location' => $productData['location'],
                    'latitude' => $productData['latitude'],
                    'longitude' => $productData['longitude'],
                    'images' => $productData['images'], // Store URLs directly
                    'status' => 'active',
                    'views' => $productData['views'],
                    'is_featured' => $productData['is_featured'] ?? false,
                ]);
            }
        }
    }
}
