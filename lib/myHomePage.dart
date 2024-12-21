import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini_gpt/chat_history_page.dart';
import 'package:gemini_gpt/message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}
String? _conversationId;

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;

  callGeminiModel() async {
  try {
    if (_controller.text.isNotEmpty) {
      final userMessage = _controller.text.trim();

      // Lưu tin nhắn của người dùng
      setState(() {
        _messages.add(Message(text: userMessage, isUser: true));
      });
      await saveMessageToFirestore(userMessage, true);

      setState(() {
        _isLoading = true;
      });

      final model = GenerativeModel(model: 'gemini-pro', apiKey: dotenv.env['GOOGLE_API_KEY']!);
      final response = await model.generateContent([Content.text(userMessage)]);

      // Lưu phản hồi của AI
      final aiResponse = response.text ?? 'No response';
      setState(() {
        _messages.add(Message(text: aiResponse, isUser: false));
      });
      await saveMessageToFirestore(aiResponse, false);

      setState(() {
        _isLoading = false;
      });

      _controller.clear();
    }
  } catch (e) {
    print("Error in callGeminiModel: $e");
  }
}


Future<void> createNewConversation(String initialMessage) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    print("Error: User is not logged in.");
    return;
  }

  final conversationRef = FirebaseFirestore.instance.collection('conversations').doc();

  // Lưu cuộc trò chuyện mới
  await conversationRef.set({
    'title': initialMessage, // Đặt tiêu đề bằng tin nhắn đầu tiên
    'createdAt': FieldValue.serverTimestamp(), // Thời gian tạo
    'updatedAt': FieldValue.serverTimestamp(), // Thời gian cập nhật
    'userId': userId, // ID người dùng
  });

  // Gán ID của cuộc trò chuyện vừa tạo
  _conversationId = conversationRef.id;
  print("New conversation created with ID: $_conversationId");
}
Future<void> loadMessages() async {
  if (_conversationId == null) return;

  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('conversations')
        .doc(_conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      _messages.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        _messages.add(Message(
          text: data['text'] ?? '',
          isUser: data['isUser'] ?? false,
        ));
      }
    });

    print("Messages loaded successfully");
  } catch (e) {
    print("Error loading messages: $e");
  }
}

Future<void> saveMessageToFirestore(String message, bool isUser) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    print("Error: User is not logged in.");
    return;
  }

  if (_conversationId == null) {
    // Nếu chưa có cuộc trò chuyện, tạo mới
    await createNewConversation(message);
  }

  final messageData = {
    'text': message,
    'isUser': isUser,
    'timestamp': FieldValue.serverTimestamp(), // Thời gian chuẩn của Firestore
    'userId': userId, // ID người gửi
  };

  try {
    // Lưu tin nhắn vào bộ sưu tập con `messages`
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(_conversationId)
        .collection('messages')
        .add(messageData);

    // Cập nhật thời gian `updatedAt` cho cuộc trò chuyện
    await FirebaseFirestore.instance
        .collection('conversations')
        .doc(_conversationId)
        .update({'updatedAt': FieldValue.serverTimestamp()});

    print("Message saved successfully: $messageData");
  } catch (e) {
    print("Error saving message: $e");
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
  centerTitle: false,
  backgroundColor: Theme.of(context).colorScheme.surface,
  elevation: 1,
  title: Row(
    children: [
      Image.asset('assets/gpt-robot.png', height: 30),
      const SizedBox(width: 10),
      Text('Potter - GPT', style: Theme.of(context).textTheme.titleLarge),
    ],
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.history),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatHistoryPage()),
        );
      },
      tooltip: 'Chat History',
    ),
    IconButton(
      icon: const Icon(Icons.settings),
      onPressed: () {
        Navigator.pushNamed(context, '/settings'); // Điều hướng tới trang Settings
      },
      tooltip: 'Settings',
    ),


    IconButton(
  icon: const Icon(Icons.add),
  onPressed: () async {
    // Truyền tham số tên cuộc trò chuyện mới (ví dụ: tin nhắn đầu tiên)
    await createNewConversation(_controller.text); // Truyền tin nhắn đầu tiên làm tên cuộc trò chuyện
    setState(() {
      _messages.clear();
    });
  },
  tooltip: 'New Chat',
)

  ],
),  

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Align(
                    alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        message.text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: message.isUser ? Colors.white : Colors.black,
                            ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 15, 13, 13),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: Theme.of(context).textTheme.bodyMedium,
                      decoration: InputDecoration(
                        hintText: 'Write your message...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      // Gọi hàm callGeminiModel khi nhấn Enter
                      onSubmitted: (_) => callGeminiModel(),
                    ),
                  ),
                  _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(),
                          ),
                        ) 
                      : IconButton(
                          icon: Image.asset('assets/send.png', height: 24),
                          onPressed: callGeminiModel,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
