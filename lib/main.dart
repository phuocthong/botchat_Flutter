import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_gpt/myHomePage.dart';
import 'package:gemini_gpt/themeNotifier.dart';
import 'package:gemini_gpt/themes.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase
import 'package:gemini_gpt/LoginScreen.dart';

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
        '/login': (context) => const LoginScreen(), // Khai báo route /login
        '/home': (context) => const MyHomePage(), // Khai báo route /home
      },
      // Dùng StreamBuilder để theo dõi trạng thái đăng nhập
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Hiển thị màn hình chờ nếu Firebase đang xử lý
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasData) {
            // Nếu người dùng đã đăng nhập, chuyển đến MyHomePage
            return const MyHomePage(); // Sử dụng widget MyHomePage đã có
          } else {
            // Nếu chưa đăng nhập, chuyển đến LoginScreen
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
