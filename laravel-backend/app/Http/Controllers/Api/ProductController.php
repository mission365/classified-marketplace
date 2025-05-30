<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::with(['user', 'category'])->active();

        // Search
        if ($request->has('search') && $request->search) {
            $query->search($request->search);
        }

        // Category filter
        if ($request->has('category_id') && $request->category_id) {
            $query->inCategory($request->category_id);
        }

        // Price range filter
        if ($request->has('min_price') && $request->has('max_price')) {
            $query->priceRange($request->min_price, $request->max_price);
        }

        // Location filter
        if ($request->has('latitude') && $request->has('longitude')) {
            $radius = $request->get('radius', 50);
            $query->nearLocation($request->latitude, $request->longitude, $radius);
        }

        // Condition filter
        if ($request->has('condition') && $request->condition) {
            $query->where('condition', $request->condition);
        }

        // Sorting
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');
        
        if ($sortBy === 'price') {
            $query->orderBy('price', $sortOrder);
        } elseif ($sortBy === 'views') {
            $query->orderBy('views', $sortOrder);
        } else {
            $query->orderBy('created_at', $sortOrder);
        }

        // Featured products first
        if ($request->get('featured_first', false)) {
            $query->orderBy('is_featured', 'desc');
        }

        $products = $query->paginate($request->get('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $products
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'category_id' => 'required|exists:categories,id',
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'price' => 'required|numeric|min:0',
            'condition' => 'required|in:new,used,refurbished',
            'location' => 'required|string|max:255',
            'latitude' => 'nullable|numeric|between:-90,90',
            'longitude' => 'nullable|numeric|between:-180,180',
            'images' => 'nullable|array|max:5',
            'images.*' => 'image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        $imagePaths = [];
        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $image) {
                $imagePaths[] = $image->store('products', 'public');
            }
        }

        $product = Product::create([
            'user_id' => $request->user()->id,
            'category_id' => $request->category_id,
            'title' => $request->title,
            'description' => $request->description,
            'price' => $request->price,
            'condition' => $request->condition,
            'location' => $request->location,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'images' => $imagePaths,
        ]);

        $product->load(['user', 'category']);

        return response()->json([
            'success' => true,
            'message' => 'Product created successfully',
            'data' => $product
        ], 201);
    }

    public function show(Product $product)
    {
        // Increment views
        $product->increment('views');

        $product->load(['user', 'category']);

        return response()->json([
            'success' => true,
            'data' => $product
        ]);
    }

    public function update(Request $request, Product $product)
    {
        // Check if user owns the product
        if ($product->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'category_id' => 'sometimes|exists:categories,id',
            'title' => 'sometimes|string|max:255',
            'description' => 'sometimes|string',
            'price' => 'sometimes|numeric|min:0',
            'condition' => 'sometimes|in:new,used,refurbished',
            'location' => 'sometimes|string|max:255',
            'latitude' => 'sometimes|nullable|numeric|between:-90,90',
            'longitude' => 'sometimes|nullable|numeric|between:-180,180',
            'status' => 'sometimes|in:active,sold,inactive',
            'images' => 'sometimes|array|max:5',
            'images.*' => 'image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        $updateData = $request->only([
            'category_id', 'title', 'description', 'price', 'condition',
            'location', 'latitude', 'longitude', 'status'
        ]);

        if ($request->hasFile('images')) {
            // Delete old images
            if ($product->images) {
                foreach ($product->images as $image) {
                    Storage::disk('public')->delete($image);
                }
            }

            $imagePaths = [];
            foreach ($request->file('images') as $image) {
                $imagePaths[] = $image->store('products', 'public');
            }
            $updateData['images'] = $imagePaths;
        }

        $product->update($updateData);
        $product->load(['user', 'category']);

        return response()->json([
            'success' => true,
            'message' => 'Product updated successfully',
            'data' => $product
        ]);
    }

    public function destroy(Request $request, Product $product)
    {
        // Check if user owns the product
        if ($product->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        // Delete images
        if ($product->images) {
            foreach ($product->images as $image) {
                Storage::disk('public')->delete($image);
            }
        }

        $product->delete();

        return response()->json([
            'success' => true,
            'message' => 'Product deleted successfully'
        ]);
    }

    public function myProducts(Request $request)
    {
        $products = Product::where('user_id', $request->user()->id)
            ->with(['category'])
            ->orderBy('created_at', 'desc')
            ->paginate($request->get('per_page', 15));

        return response()->json([
            'success' => true,
            'data' => $products
        ]);
    }

    public function featured()
    {
        $products = Product::with(['user', 'category'])
            ->active()
            ->featured()
            ->orderBy('created_at', 'desc')
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $products
        ]);
    }
}
