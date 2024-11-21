import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gemini_gpt/message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:gemini_gpt/settings_page.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<Message> _messages = [];
  bool _isLoading = false;

  callGeminiModel() async {
    try {
      if (_controller.text.isNotEmpty) {
        _messages.add(Message(text: _controller.text, isUser: true));
        setState(() {
          _isLoading = true;
        });
      }

      final model = GenerativeModel(model: 'gemini-pro', apiKey: dotenv.env['GOOGLE_API_KEY']!);
      final prompt = _controller.text.trim();
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);

      setState(() {
        _messages.add(Message(text: response.text!, isUser: false));
        _isLoading = false;
      });

      _controller.clear();
    } catch (e) {
      print("Error : $e");
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
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings'); // Điều hướng tới trang Settings
            },
            tooltip: 'Settings',
          ),
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
