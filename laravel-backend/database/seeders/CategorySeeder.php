<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run()
    {
        $categories = [
            [
                'name' => 'Electronics',
                'description' => 'Phones, laptops, tablets, and electronic devices',
                'icon' => 'smartphone',
            ],
            [
                'name' => 'Vehicles',
                'description' => 'Cars, motorcycles, bicycles, and automotive parts',
                'icon' => 'car',
            ],
            [
                'name' => 'Home & Garden',
                'description' => 'Furniture, appliances, and garden equipment',
                'icon' => 'home',
            ],
            [
                'name' => 'Fashion',
                'description' => 'Clothing, shoes, accessories, and jewelry',
                'icon' => 'shirt',
            ],
            [
                'name' => 'Sports & Recreation',
                'description' => 'Sports equipment, outdoor gear, and fitness items',
                'icon' => 'dumbbell',
            ],
            [
                'name' => 'Books & Media',
                'description' => 'Books, movies, music, and educational materials',
                'icon' => 'book',
            ],
            [
                'name' => 'Pets & Animals',
                'description' => 'Pet supplies, animals, and pet services',
                'icon' => 'heart',
            ],
            [
                'name' => 'Services',
                'description' => 'Professional services, tutoring, and consulting',
                'icon' => 'briefcase',
            ],
        ];

        foreach ($categories as $category) {
            Category::create($category);
        }
    }
}
