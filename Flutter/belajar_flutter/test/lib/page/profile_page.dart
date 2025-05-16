import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test/provider/counter_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/images/soro doro.jpg"),
            ),
            const SizedBox(height: 10),
            const Text("Nama: Afanda Mirza", style: TextStyle(fontSize: 18)),
            const Text("Email: john@example.com", style: TextStyle(fontSize: 18)),
            const Text("Alamat: Surabaya", style: TextStyle(fontSize: 18)),

            
            Consumer<CounterProvider>(
              builder: (context, counter, child) {
                return Text("Value: ${counter.count}", style: const TextStyle(fontSize: 18));
              },
            ),
          ],
        ),
      ),
    );
  }
}
