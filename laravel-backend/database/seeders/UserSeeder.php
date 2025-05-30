<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run()
    {
        $users = [
            [
                'name' => 'John Smith',
                'email' => 'john@example.com',
                'password' => Hash::make('password123'),
                'phone' => '+1234567890',
                'address' => '123 Main St, New York, NY',
                'latitude' => 40.7128,
                'longitude' => -74.0060,
                'role' => 'seller',
                'is_active' => true,
            ],
            [
                'name' => 'Sarah Johnson',
                'email' => 'sarah@example.com',
                'password' => Hash::make('password123'),
                'phone' => '+1234567891',
                'address' => '456 Oak Ave, Los Angeles, CA',
                'latitude' => 34.0522,
                'longitude' => -118.2437,
                'role' => 'seller',
                'is_active' => true,
            ],
            [
                'name' => 'Mike Wilson',
                'email' => 'mike@example.com',
                'password' => Hash::make('password123'),
                'phone' => '+1234567892',
                'address' => '789 Pine St, Chicago, IL',
                'latitude' => 41.8781,
                'longitude' => -87.6298,
                'role' => 'seller',
                'is_active' => true,
            ],
            [
                'name' => 'Emily Davis',
                'email' => 'emily@example.com',
                'password' => Hash::make('password123'),
                'phone' => '+1234567893',
                'address' => '321 Elm St, Houston, TX',
                'latitude' => 29.7604,
                'longitude' => -95.3698,
                'role' => 'seller',
                'is_active' => true,
            ],
            [
                'name' => 'David Brown',
                'email' => 'david@example.com',
                'password' => Hash::make('password123'),
                'phone' => '+1234567894',
                'address' => '654 Maple Dr, Phoenix, AZ',
                'latitude' => 33.4484,
                'longitude' => -112.0740,
                'role' => 'seller',
                'is_active' => true,
            ],
        ];

        foreach ($users as $userData) {
            User::create($userData);
        }
    }
}
