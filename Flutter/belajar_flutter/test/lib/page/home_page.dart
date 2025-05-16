import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test/provider/counter_provider.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<CounterProvider>(
              builder: (context, counter, child) {
                return Text("Value: ${counter.count}",
                    style: const TextStyle(fontSize: 18));
              },
            ),
            const SizedBox(
              height: 50,
            ),
            OutlinedButton(
              onPressed: () {
                context.read<CounterProvider>().increment();
              },
              child: const Text("+"),
            ),
            OutlinedButton(
              onPressed: () {
                context.read<CounterProvider>().decrement();
              },
              child: const Text("-"),
            ),

            OutlinedButton(
              onPressed: () {
                context.read<CounterProvider>().reset();
              },
              child: const Text("Reset"),
            ),

            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
              child: const Text("Klik Aku"),
            ),

            
          ],
        ),
      ),
    );
  }
}
