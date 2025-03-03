import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_transport/provider/smart_transport_provider.dart';
import 'package:smart_transport/model/user.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SmartTransportProvider>(context);
    final currentUser = provider.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('โปรไฟล์ผู้ใช้'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentUser != null) ...[
              Text('ผู้ใช้ปัจจุบัน: ${currentUser.username}', style: const TextStyle(fontSize: 20)),
              Text('อีเมล: ${currentUser.email}'),
              const SizedBox(height: 20),
            ],
            const Text('เลือกผู้ใช้:', style: TextStyle(fontSize: 18)),
            Consumer<SmartTransportProvider>(
              builder: (context, provider, child) {
                return DropdownButton<User>(
                  value: provider.currentUser,
                  items: provider.users.map((user) {
                    return DropdownMenuItem<User>(
                      value: user,
                      child: Text(user.username),
                    );
                  }).toList(),
                  onChanged: (user) {
                    if (user != null) {
                      provider.setCurrentUser(user);
                      provider.fetchTickets(); // รีเฟรชตั๋วตามผู้ใช้
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showAddUserDialog(context);
              },
              child: const Text('เพิ่มผู้ใช้ใหม่'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final provider = Provider.of<SmartTransportProvider>(context, listen: false);
    final usernameController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('เพิ่มผู้ใช้ใหม่'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้'),
                controller: usernameController,
                validator: (value) => value == null || value.isEmpty ? 'กรุณาป้อนชื่อผู้ใช้' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'อีเมล'),
                controller: emailController,
                validator: (value) => value == null || value.isEmpty ? 'กรุณาป้อนอีเมล' : null,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                if (usernameController.text.isNotEmpty && emailController.text.isNotEmpty) {
                  final newUser = User(
                    id: 0, // ID จะถูกกำหนดโดยฐานข้อมูล
                    username: usernameController.text,
                    email: emailController.text,
                  );
                  provider.addUser(newUser);
                  Navigator.pop(context);
                }
              },
              child: const Text('เพิ่ม'),
            ),
          ],
        );
      },
    );
  }
}