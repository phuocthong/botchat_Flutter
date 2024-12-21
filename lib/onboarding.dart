import 'package:flutter/material.dart';

class Onboarding extends StatelessWidget {
  final VoidCallback onDone; // Callback khi hoàn thành

  const Onboarding({Key? key, required this.onDone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Phần giới thiệu
                const Column(
                  children: [
                    Text(
                      'Your AI Assista  nt',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Using this software, you can ask questions and receive articles using an artificial intelligence assistant.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Hình ảnh
                Image.asset(
                  'assets/onboarding.png',
                  width: MediaQuery.of(context).size.width * 0.6, // Tỉ lệ 60% chiều rộng màn hình
                  height: MediaQuery.of(context).size.height * 0.4, // Tỉ lệ 40% chiều cao màn hình
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),

                // Nút hoàn tất
                ElevatedButton(
                  onPressed: onDone,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 32,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Continue'),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
