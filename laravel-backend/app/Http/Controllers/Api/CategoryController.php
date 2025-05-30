<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index()
    {
        $categories = Category::active()
            ->withCount('products')
            ->orderBy('name')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $categories
        ]);
    }

    public function show(Category $category)
    {
        $category->load(['products' => function ($query) {
            $query->active()->with(['user', 'category'])->latest();
        }]);

        return response()->json([
            'success' => true,
            'data' => $category
        ]);
    }
}
