import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_gpt/chat_history_page.dart';
import 'package:gemini_gpt/myHomePage.dart';
import 'package:gemini_gpt/themeNotifier.dart';
import 'package:gemini_gpt/themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gemini_gpt/LoginScreen.dart';
import 'package:gemini_gpt/onboarding.dart'; // Onboarding
import 'package:shared_preferences/shared_preferences.dart'; // Lưu trạng thái Onboarding
import 'package:flutter/foundation.dart'; // Kiểm tra môi trường Web
import 'package:gemini_gpt/settings_page.dart'; // Đảm bảo đúng đường dẫn

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase khởi tạo
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBHu_DTyVYqRZt62nVWmUXO97eJhK9Zs4M",
        authDomain: "potter-gemini.firebaseapp.com",
        projectId: "potter-gemini",
        storageBucket: "potter-gemini.firebasestorage.app",
        messagingSenderId: "459897220631",
        appId: "1:459897220631:web:2c682ec4db8ccdb3c0b652",
        measurementId: "G-EGJNP85Q6L",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  // Load .env
  await dotenv.load(fileName: ".env");

  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  Future<bool> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFirstTime') ?? true;
  }

  Future<void> _markFirstTimeDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Potter GPT',
      theme: lightMode,
      darkTheme: darkMode,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      routes: {
  '/login': (context) => const LoginScreen(),
  '/home': (context) => MyHomePage(),
  '/settings': (context) => const SettingsPage(),
  '/chatHistory': (context) => const ChatHistoryPage(), // Thêm route cho lịch sử trò chuyện
},


      home: FutureBuilder<bool>(
        future: _checkFirstTime(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == true) {
            return Onboarding(onDone: () async {
              await _markFirstTimeDone();
              _navigateBasedOnAuth(context);
            });
          } else {
            return _handleAuthState();
          }
        },
      ),
    );
  }

  Widget _handleAuthState() {
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
          return MyHomePage();
        } else {
          return const LoginScreen();
        }
      },
    );
  }

  void _navigateBasedOnAuth(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }
}
