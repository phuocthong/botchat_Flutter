import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_gpt/myHomePage.dart';
import 'package:gemini_gpt/themeNotifier.dart';
import 'package:gemini_gpt/themes.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase
import 'package:gemini_gpt/LoginScreen.dart';
import 'package:gemini_gpt/onboarding.dart'; // Import màn hình Onboarding
import 'package:shared_preferences/shared_preferences.dart'; // Để lưu trạng thái Onboarding

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Khởi tạo Flutter Binding
  await Firebase.initializeApp(); // Khởi tạo Firebase
  await dotenv.load(fileName: ".env"); // Load tệp môi trường

  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  Future<bool> _isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTime') ?? true;
  }

  void _setFirstTimeFalse() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MyHomePage(),
      },
      home: FutureBuilder<bool>(
        future: _isFirstTime(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            _setFirstTimeFalse(); // Cập nhật trạng thái không phải lần đầu
            return const Onboarding(); // Hiển thị màn hình Onboarding
          } else {
            return StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasData) {
                  return const MyHomePage();
                } else {
                  return const LoginScreen();
                }
              },
            );
          }
        },
      ),
    );
  }
}
