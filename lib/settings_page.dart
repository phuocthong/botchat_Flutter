import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemini_gpt/themeNotifier.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  // Đăng xuất
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout: $e')),
      );
    }
  }

  // Đổi mật khẩu
  Future<void> _changePassword(BuildContext context, String currentPassword, String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields!')),
      );
      return;
    }

    // Kiểm tra độ dài mật khẩu mới
    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters!')),
      );
      return;
    }

    try {
      // Cần xác thực mật khẩu hiện tại trước khi thay đổi mật khẩu
      await user?.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: user?.email ?? '',
          password: currentPassword,
        ),
      );

      // Cập nhật mật khẩu mới
      await user?.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully!')),
      );
      Navigator.pop(context); // Đóng form sau khi thay đổi mật khẩu thành công
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Xóa tài khoản
  Future<void> _deleteAccount(BuildContext context) async {
    try {
      await FirebaseAuth.instance.currentUser?.delete();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Thông tin tài khoản
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.account_circle, size: 50, color: Colors.blue),
                title: Text(user?.email ?? 'No email available',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                subtitle: const Text('Account Info'),
              ),
            ),
            const SizedBox(height: 16),

            // Chuyển đổi nền sáng/tối
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.dark_mode, color: Colors.blue),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: currentTheme == ThemeMode.dark,
                  onChanged: (_) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Đổi mật khẩu (Nút bấm để mở form)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.lock, color: Colors.blue),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                onTap: () {
                  _showChangePasswordDialog(context);
                },
              ),
            ),
            const SizedBox(height: 16),

            // Xóa tài khoản
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Account'),
                onTap: () => _deleteAccount(context),
              ),
            ),
            const SizedBox(height: 16),

            // Đăng xuất
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log Out'),
                onTap: () => _logout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Hộp thoại để nhập mật khẩu hiện tại và mật khẩu mới
  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController _currentPasswordController = TextEditingController();
    final TextEditingController _newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng hộp thoại
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final currentPassword = _currentPasswordController.text.trim();
                final newPassword = _newPasswordController.text.trim();
                _changePassword(context, currentPassword, newPassword);
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }
}
