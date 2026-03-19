import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_vocab/providers/word_provider.dart';
import 'package:my_vocab/models/word.dart';
import 'package:flutter_tts/flutter_tts.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  bool _showBack = false;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: Consumer<WordProvider>(
        builder: (context, provider, child) {
          if (provider.wordsDue.isEmpty) {
            return const Center(child: Text('All done for today!'));
          }

          // Always show the first word in the queue
          final word = provider.wordsDue.first;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.all(32),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _showBack = !_showBack;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  word.word,
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up),
                                  onPressed: () => _speak(word.word),
                                ),
                              ],
                            ),
                            if (_showBack) ...[
                              const Divider(),
                              Text(
                                word.definition,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              if (word.example != null)
                                Text(
                                  word.example!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_showBack)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _handleReview(context, word, 0),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Again'),
                      ),
                      ElevatedButton(
                        onPressed: () => _handleReview(context, word, 1),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        child: const Text('Hard'),
                      ),
                      ElevatedButton(
                        onPressed: () => _handleReview(context, word, 3),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        child: const Text('Easy'),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _handleReview(BuildContext context, Word word, int difficulty) {
    Provider.of<WordProvider>(context, listen: false).reviewWord(word, difficulty);
    setState(() {
      _showBack = false;
    });
  }
}
