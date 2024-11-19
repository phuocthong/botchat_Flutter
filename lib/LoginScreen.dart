import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';  // Import google_sign_in package
import 'package:gemini_gpt/RegisterScreen.dart';
import 'package:gemini_gpt/ForgetPasswordScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // Khởi tạo GoogleSignIn
  final GoogleSignIn googleSignIn = GoogleSignIn();

  void loginUser(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email và mật khẩu không được để trống.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập thành công!')),
      );

      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy tài khoản với email này.')),
        );
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mật khẩu không chính xác.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void loginWithFacebook(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });

      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken;
        if (accessToken != null) {
          final String? token = accessToken.token;

          // Cập nhật lại để sử dụng token đúng cách
          final OAuthCredential facebookAuthCredential =
              FacebookAuthProvider.credential(token!);

          await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đăng nhập Facebook thành công!')),
          );
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không nhận được access token từ Facebook')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng nhập Facebook thất bại.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  void loginWithGoogle(BuildContext context) async {
  try {
    setState(() {
      isLoading = true;
    });

    // Bước 1: Ngắt kết nối tài khoản cũ (nếu có)
    await googleSignIn.signOut();

    // Bước 2: Đăng nhập với Google và cho phép chọn tài khoản
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng nhập Google thất bại.')),
      );
      return;
    }

    // Bước 3: Lấy access token từ Google
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential googleAuthCredential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Bước 4: Đăng nhập vào Firebase
    await FirebaseAuth.instance.signInWithCredential(googleAuthCredential);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng nhập Google thành công!')),
    );
    Navigator.pushReplacementNamed(context, '/home');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lỗi: ${e.toString()}')),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đăng Nhập"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome Back!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: "Mật khẩu",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => loginUser(context),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("Đăng nhập"),
                    ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => loginWithFacebook(context),
                icon: const Icon(Icons.facebook),
                label: const Text("Đăng nhập bằng Facebook"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () => loginWithGoogle(context),
                icon: const Icon(Icons.login),
                label: const Text("Đăng nhập bằng Google"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 227, 107, 98),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForgetPasswordScreen()),
                  );
                },
                child: const Text("Quên mật khẩu?"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text("Chưa có tài khoản? Đăng ký ngay"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension on AccessToken {
  String? get token => null;
}
