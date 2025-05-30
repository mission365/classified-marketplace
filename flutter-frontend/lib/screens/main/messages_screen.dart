import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/message_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/message.dart';
import '../messages/chat_screen.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadConversations();
    });
  }

  Future<void> _loadConversations() async {
    final messageProvider = context.read<MessageProvider>();
    await messageProvider.fetchConversations();
  }

  Future<void> _onRefresh() async {
    await _loadConversations();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.message, size: 80, color: Colors.blue),
                const SizedBox(height: 24),
                Text(
                  'Connect with Buyers & Sellers',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Sign in to start conversations with other users and negotiate deals.',
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
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text('Sign In'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Create Account'),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    // Navigate back to home to continue browsing
                    Navigator.of(context).pop();
                  },
                  child: const Text('Continue Browsing'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Rest of the existing authenticated user UI remains the same
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          Consumer<MessageProvider>(
            builder: (context, messageProvider, child) {
              if (messageProvider.unreadCount > 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${messageProvider.unreadCount} unread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<MessageProvider>(
        builder: (context, messageProvider, child) {
          if (messageProvider.isLoading && messageProvider.conversations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (messageProvider.conversations.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No conversations yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start chatting with sellers and buyers',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              itemCount: messageProvider.conversations.length,
              itemBuilder: (context, index) {
                final conversation = messageProvider.conversations[index];
                return _buildConversationTile(conversation);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    final contact = conversation.contact;
    final latestMessage = conversation.latestMessage;
    final unreadCount = conversation.unreadCount;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: contact.avatarUrl.isNotEmpty
            ? NetworkImage(contact.avatarUrl)
            : null,
        child: contact.avatarUrl.isEmpty
            ? Text(contact.name.substring(0, 1).toUpperCase())
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              contact.name,
              style: TextStyle(
                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (latestMessage != null) ...[
            Text(
              latestMessage.messageText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatMessageTime(conversation.lastMessageTime),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(contact: contact),
          ),
        ).then((_) {
          // Refresh conversations when returning from chat
          _loadConversations();
        });
      },
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return DateFormat('EEEE').format(dateTime);
      } else {
        return DateFormat('MMM d').format(dateTime);
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
