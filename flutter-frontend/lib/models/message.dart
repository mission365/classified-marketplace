import 'user.dart';
import 'product.dart';

class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final int? productId;
  final String messageText;
  final bool isRead;
  final User? sender;
  final User? receiver;
  final Product? product;
  final DateTime createdAt;
  final DateTime updatedAt;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.productId,
    required this.messageText,
    required this.isRead,
    this.sender,
    this.receiver,
    this.product,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      productId: json['product_id'],
      messageText: json['message_text'],
      isRead: json['is_read'] ?? false,
      sender: json['sender'] != null ? User.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? User.fromJson(json['receiver']) : null,
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'product_id': productId,
      'message_text': messageText,
      'is_read': isRead,
      'sender': sender?.toJson(),
      'receiver': receiver?.toJson(),
      'product': product?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Conversation {
  final User contact;
  final Message? latestMessage;
  final int unreadCount;
  final DateTime lastMessageTime;

  Conversation({
    required this.contact,
    this.latestMessage,
    required this.unreadCount,
    required this.lastMessageTime,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      contact: User.fromJson(json['contact']),
      latestMessage: json['latest_message'] != null 
          ? Message.fromJson(json['latest_message']) 
          : null,
      unreadCount: json['unread_count'] ?? 0,
      lastMessageTime: DateTime.parse(json['last_message_time']),
    );
  }
}
