#!/bin/bash

echo "Setting up sample data for Laravel Classifieds Backend..."

# Run migrations
echo "Running migrations..."
php artisan migrate:fresh

# Run seeders
echo "Running seeders..."
php artisan db:seed

echo "Sample data setup complete!"
echo ""
echo "Sample users created:"
echo "- john@example.com (password: password123)"
echo "- sarah@example.com (password: password123)"
echo "- mike@example.com (password: password123)"
echo "- emily@example.com (password: password123)"
echo "- david@example.com (password: password123)"
echo ""
echo "Categories and products have been created with sample data."
echo "You can now test the application with realistic data!"
