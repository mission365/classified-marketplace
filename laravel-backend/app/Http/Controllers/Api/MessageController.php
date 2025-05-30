<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Message;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class MessageController extends Controller
{
    public function index(Request $request)
    {
        $userId = $request->user()->id;

        // Get conversations with latest message
        $conversations = DB::table('messages')
            ->select([
                DB::raw('CASE 
                    WHEN sender_id = ' . $userId . ' THEN receiver_id 
                    ELSE sender_id 
                END as contact_id'),
                DB::raw('MAX(created_at) as last_message_time'),
                DB::raw('COUNT(CASE WHEN receiver_id = ' . $userId . ' AND is_read = 0 THEN 1 END) as unread_count')
            ])
            ->where('sender_id', $userId)
            ->orWhere('receiver_id', $userId)
            ->groupBy('contact_id')
            ->orderBy('last_message_time', 'desc')
            ->get();

        // Get contact details and latest messages
        $conversationsWithDetails = [];
        foreach ($conversations as $conversation) {
            $contact = User::find($conversation->contact_id);
            $latestMessage = Message::where(function ($query) use ($userId, $conversation) {
                $query->where('sender_id', $userId)->where('receiver_id', $conversation->contact_id);
            })->orWhere(function ($query) use ($userId, $conversation) {
                $query->where('sender_id', $conversation->contact_id)->where('receiver_id', $userId);
            })->latest()->first();

            $conversationsWithDetails[] = [
                'contact' => $contact,
                'latest_message' => $latestMessage,
                'unread_count' => $conversation->unread_count,
                'last_message_time' => $conversation->last_message_time,
            ];
        }

        return response()->json([
            'success' => true,
            'data' => $conversationsWithDetails
        ]);
    }

    public function conversation(Request $request, User $user)
    {
        $currentUserId = $request->user()->id;
        $otherUserId = $user->id;

        $messages = Message::conversation($currentUserId, $otherUserId)
            ->with(['sender', 'receiver', 'product'])
            ->orderBy('created_at', 'asc')
            ->paginate($request->get('per_page', 50));

        // Mark messages as read
        Message::where('sender_id', $otherUserId)
            ->where('receiver_id', $currentUserId)
            ->where('is_read', false)
            ->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'data' => [
                'contact' => $user,
                'messages' => $messages
            ]
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'receiver_id' => 'required|exists:users,id|different:sender_id',
            'product_id' => 'nullable|exists:products,id',
            'message_text' => 'required|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation errors',
                'errors' => $validator->errors()
            ], 422);
        }

        // Prevent users from messaging themselves
        if ($request->receiver_id == $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot send message to yourself'
            ], 422);
        }

        $message = Message::create([
            'sender_id' => $request->user()->id,
            'receiver_id' => $request->receiver_id,
            'product_id' => $request->product_id,
            'message_text' => $request->message_text,
        ]);

        $message->load(['sender', 'receiver', 'product']);

        return response()->json([
            'success' => true,
            'message' => 'Message sent successfully',
            'data' => $message
        ], 201);
    }

    public function markAsRead(Request $request, Message $message)
    {
        // Only receiver can mark message as read
        if ($message->receiver_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $message->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Message marked as read'
        ]);
    }

    public function unreadCount(Request $request)
    {
        $count = Message::where('receiver_id', $request->user()->id)
            ->where('is_read', false)
            ->count();

        return response()->json([
            'success' => true,
            'data' => ['unread_count' => $count]
        ]);
    }
}
