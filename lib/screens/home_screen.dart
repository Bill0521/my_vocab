import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_vocab/providers/word_provider.dart';
import 'package:my_vocab/screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyVocab'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome Back!'),
            const SizedBox(height: 20),
            Consumer<WordProvider>(
              builder: (context, provider, child) {
                int dueCount = provider.wordsDue.length;
                return Text('Today\'s Review: $dueCount words');
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/study');
              },
              child: const Text('Start Review'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/words');
        },
        child: const Icon(Icons.list),
      ),
    );
  }
}
