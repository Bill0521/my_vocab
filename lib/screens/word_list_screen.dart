import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_vocab/providers/word_provider.dart';
import 'package:my_vocab/models/word.dart';

class WordListScreen extends StatelessWidget {
  const WordListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vocabulary List')),
      body: Consumer<WordProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: provider.words.length,
            itemBuilder: (context, index) {
              final word = provider.words[index];
              return ListTile(
                title: Text(word.word),
                subtitle: Text(word.definition),
                onTap: () {
                  TTSService().speak(word.word);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    provider.deleteWord(word.id!);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddWordDialog(context),
      ),
    );
  }

  void _showAddWordDialog(BuildContext context) {
    final wordController = TextEditingController();
    final defController = TextEditingController();
    final exController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Word'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: wordController, decoration: const InputDecoration(labelText: 'Word')),
            TextField(controller: defController, decoration: const InputDecoration(labelText: 'Definition')),
            TextField(controller: exController, decoration: const InputDecoration(labelText: 'Example (Optional)')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (wordController.text.isNotEmpty && defController.text.isNotEmpty) {
                Provider.of<WordProvider>(context, listen: false).addWord(
                  wordController.text,
                  defController.text,
                  exController.text.isEmpty ? null : exController.text,
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
