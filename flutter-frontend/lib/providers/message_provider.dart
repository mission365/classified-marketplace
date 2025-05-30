import 'package:flutter/material.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class MessageProvider with ChangeNotifier {
  List<Conversation> _conversations = [];
  List<Message> _currentConversationMessages = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<Conversation> get conversations => _conversations;
  List<Message> get currentConversationMessages => _currentConversationMessages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> fetchConversations() async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.get('/messages');

      if (response['success']) {
        final List<dynamic> conversationList = response['data'];
        _conversations = conversationList.map((json) => Conversation.fromJson(json)).toList();
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  Future<void> fetchConversation(int userId) async {
    _setLoading(true);
    _setError(null);

    try {
      final response = await ApiService.get('/messages/conversation/$userId');

      if (response['success']) {
        final data = response['data'];
        final messageData = data['messages'];
        final List<dynamic> messageList = messageData['data'];
        _currentConversationMessages = messageList.map((json) => Message.fromJson(json)).toList();
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  Future<bool> sendMessage({
    required int receiverId,
    required String messageText,
    int? productId,
  }) async {
    try {
      final response = await ApiService.post('/messages', {
        'receiver_id': receiverId,
        'message_text': messageText,
        'product_id': productId,
      });

      if (response['success']) {
        final newMessage = Message.fromJson(response['data']);
        _currentConversationMessages.add(newMessage);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _setError(e.toString());
    }

    return false;
  }

  Future<void> markAsRead(int messageId) async {
    try {
      await ApiService.put('/messages/$messageId/read', {});
      
      // Update local message
      final index = _currentConversationMessages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        // Create a new message with updated read status
        final message = _currentConversationMessages[index];
        _currentConversationMessages[index] = Message(
          id: message.id,
          senderId: message.senderId,
          receiverId: message.receiverId,
          productId: message.productId,
          messageText: message.messageText,
          isRead: true,
          sender: message.sender,
          receiver: message.receiver,
          product: message.product,
          createdAt: message.createdAt,
          updatedAt: message.updatedAt,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await ApiService.get('/messages/unread-count');

      if (response['success']) {
        _unreadCount = response['data']['unread_count'];
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  void clearCurrentConversation() {
    _currentConversationMessages.clear();
    notifyListeners();
  }
}
