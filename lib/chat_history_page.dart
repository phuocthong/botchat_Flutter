import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_detail_page.dart';

class ChatHistoryPage extends StatelessWidget {
  const ChatHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lịch sử trò chuyện'),
        ),
        body: const Center(
          child: Text('Vui lòng đăng nhập để xem lịch sử trò chuyện.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử trò chuyện'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('conversations')
            .where('userId', isEqualTo: userId)
            .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint("Error fetching conversations: ${snapshot.error}");
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            debugPrint("No conversations found for userId: $userId");
            return const Center(child: Text('Không có cuộc trò chuyện nào.'));
          }

          final conversations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final conversationId = conversation.id;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('conversations')
                    .doc(conversationId)
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .limit(1)
                    .snapshots(),
                builder: (context, messageSnapshot) {
                  if (messageSnapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox.shrink(); // Đợi dữ liệu tin nhắn
                  }

                  if (messageSnapshot.hasError) {
                    debugPrint("Error fetching messages: ${messageSnapshot.error}");
                    return Container();
                  }

                  if (!messageSnapshot.hasData || messageSnapshot.data!.docs.isEmpty) {
                    debugPrint("No messages found for conversationId: $conversationId");
                    return Container(); // Không hiển thị nếu không có tin nhắn
                  }

                  final latestMessage = messageSnapshot.data!.docs.first;
                  final conversationTitle = latestMessage['text'] ?? 'Không có tin nhắn';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(conversationTitle[0].toUpperCase()),
                      ),
                      title: Text(
                        conversationTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Cuộc trò chuyện gần đây'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () {
                              _editConversation(context, conversationId, conversationTitle);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _deleteConversation(context, conversationId);
                            },
                          ),
                          const Icon(Icons.arrow_forward_ios),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConversationDetailPage(
                              conversationId: conversationId,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _editConversation(BuildContext context, String conversationId, String currentTitle) {
    final TextEditingController _titleController = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chỉnh sửa cuộc trò chuyện'),
          content: TextField(
            controller: _titleController,
            decoration: const InputDecoration(hintText: 'Nhập tên mới'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                final newTitle = _titleController.text.trim();
                if (newTitle.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('conversations')
                      .doc(conversationId)
                      .update({'title': newTitle});
                  debugPrint("Conversation $conversationId updated with title: $newTitle");
                }
                Navigator.of(context).pop();
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _deleteConversation(BuildContext context, String conversationId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa cuộc trò chuyện'),
          content: const Text('Bạn có chắc chắn muốn xóa cuộc trò chuyện này không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('conversations')
                    .doc(conversationId)
                    .delete();
                debugPrint("Conversation $conversationId deleted");
                Navigator.of(context).pop();
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }
}
