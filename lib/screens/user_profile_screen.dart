import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('โปรไฟล์ผู้ใช้'),
      ),
      body: const Center(
        child: Text(
          'หน้าโปรไฟล์ผู้ใช้ (ยังไม่พร้อมใช้งาน)',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}