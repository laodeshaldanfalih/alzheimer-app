import 'package:flutter/material.dart';

class MedicineReminderPage extends StatelessWidget {
  const MedicineReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pengingat Obat',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SafeArea(
        child: Center(child: Text('Medicine Reminder Page')),
      ),
    );
  }
}
