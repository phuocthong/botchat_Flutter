import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConversationDetailPage extends StatefulWidget {
  final String conversationId;

  const ConversationDetailPage({
    Key? key,
    required this.conversationId,
  }) : super(key: key);

  @override
  _ConversationDetailPageState createState() => _ConversationDetailPageState();
}

class _ConversationDetailPageState extends State<ConversationDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Hàm gửi tin nhắn đến OpenAI GPT
  Future<String> getGeminiResponse(String userMessage) async {
    final url = Uri.parse('YOUR_GEMINI_API_URL'); // Thay thế với URL của Gemini API
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': userMessage}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['response'];
    } else {
      throw Exception('Failed to get response from Gemini');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết cuộc trò chuyện'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('conversations')
                  .doc(widget.conversationId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Không có tin nhắn nào.'));
                }

                final messages = snapshot.data!.docs;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isUserMessage = message['userId'] == FirebaseAuth.instance.currentUser?.uid;

                    return Align(
                      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: isUserMessage ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          message['text'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tin nhắn...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () async {
                    final messageText = _messageController.text.trim();
                    if (messageText.isNotEmpty) {
                      // Gửi tin nhắn của người dùng vào Firestore
                      await FirebaseFirestore.instance
                          .collection('conversations')
                          .doc(widget.conversationId)
                          .collection('messages')
                          .add({
                        'text': messageText,
                        'timestamp': FieldValue.serverTimestamp(),
                        'userId': FirebaseAuth.instance.currentUser?.uid,
                      });

                      // Gửi tin nhắn tới Gemini và nhận phản hồi
                      final aiResponse = await getGeminiResponse(messageText);

                      // Gửi phản hồi từ AI vào Firestore
                      await FirebaseFirestore.instance
                          .collection('conversations')
                          .doc(widget.conversationId)
                          .collection('messages')
                          .add({
                        'text': aiResponse,
                        'timestamp': FieldValue.serverTimestamp(),
                        'userId': 'AI', // Đánh dấu là tin nhắn từ AI
                      });

                      // Xóa nội dung trong TextField sau khi gửi tin nhắn
                      _messageController.clear();

                      // Cuộn xuống cuối cùng để hiển thị tin nhắn mới
                      _scrollToBottom();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}