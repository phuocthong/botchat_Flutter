import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void registerUser(BuildContext context) async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    isLoading = true;
  });

  try {
    // Đăng ký người dùng
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    // Đăng xuất người dùng ngay sau khi đăng ký thành công
    await FirebaseAuth.instance.signOut();

    // Thông báo đăng ký thành công
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng ký thành công! Vui lòng đăng nhập.')),
    );

    // Chuyển về màn hình đăng nhập
    Navigator.pop(context); // Quay lại màn hình trước (LoginScreen)
  } catch (e) {
    // Xử lý lỗi đăng ký
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
      appBar: AppBar(title: const Text("Đăng Ký")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email.';
                  }
                  if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(value)) {
                    return 'Email không hợp lệ.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: "Mật khẩu",
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu.';
                  }
                  if (value.length < 6) {
                    return 'Mật khẩu phải có ít nhất 6 ký tự.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () => registerUser(context),
                      child: const Text("Đăng ký"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
