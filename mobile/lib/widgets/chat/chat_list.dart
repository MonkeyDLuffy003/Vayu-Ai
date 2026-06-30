import 'package:flutter/material.dart';
import '../../models/chat_message.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key, required this.messages});
  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[messages.length - 1 - index];
        final isUser = msg.role == 'user';
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF1E3A5F) : const Color(0xFF1A1F2B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(msg.content,
                    style: const TextStyle(color: Colors.white, fontSize: 15)),
                if (msg.translatedContent != null) ...[
                  const SizedBox(height: 6),
                  const Divider(height: 1, color: Color(0xFF2A3140)),
                  const SizedBox(height: 6),
                  Text(
                    msg.translatedContent!,
                    style: const TextStyle(
                        color: Color(0xFF8FB7E0),
                        fontSize: 14,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
