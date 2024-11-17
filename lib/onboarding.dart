import 'package:flutter/material.dart';
import 'package:gemini_gpt/myHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gemini_gpt/loginScreen.dart'; // Đường dẫn tới LoginScreen

class Onboarding extends StatelessWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Column(
              children: [
                Text(
                  'Your AI Assistant',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
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
            Image.asset('assets/onboarding.png'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                  final User? user = FirebaseAuth.instance.currentUser;

if (user == null) {
  Navigator.pushAndRemoveUntil(
    context,    
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (route) => false,
  );  
} else {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const MyHomePage()),
    (route) => false,
  );
}

              },
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
    );
  }
}
