import 'package:flutter/material.dart';
import 'package:my_vocab/models/word.dart';
import 'package:my_vocab/services/word_service.dart';

class WordProvider with ChangeNotifier {
  List<Word> _words = [];
  List<Word> _wordsDue = [];
  bool _isLoading = false;

  List<Word> get words => _words;
  List<Word> get wordsDue => _wordsDue;
  bool get isLoading => _isLoading;

  final WordService _service = WordService();

  Future<void> loadWords() async {
    _isLoading = true;
    notifyListeners();
    _words = await _service.getWords();
    _wordsDue = await _service.getWordsDueToday(); // simple filter
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWord(String word, String definition, String? example) async {
    final newWord = Word(
      word: word,
      definition: definition,
      example: example,
      nextReviewDate: DateTime.now(),
    );
    await _service.insertWord(newWord);
    await loadWords();
  }

  Future<void> reviewWord(Word word, int difficulty) async {
    // Basic Spaced Repetition Logic (SM-2 Simplified)
    // difficulty: 0 (Again), 1 (Hard), 2 (Good), 3 (Easy)
    
    DateTime nextDate;
    int interval;
    double easeFactor = word.easeFactor;

    if (difficulty == 0) {
      interval = 0; // Review again immediately or tomorrow
      nextDate = DateTime.now().add(const Duration(minutes: 10)); // review soon
    } else {
      if (word.interval == 0) {
        interval = 1;
      } else if (word.interval == 1) {
        interval = 6;
      } else {
        interval = (word.interval * easeFactor).round();
      }
      nextDate = DateTime.now().add(Duration(days: interval));
    }

    final updatedWord = word.copyWith(
      interval: interval,
      nextReviewDate: nextDate,
      easeFactor: easeFactor + (0.1 - (3 - difficulty) * (0.08 + (3 - difficulty) * 0.02)),
    );

    await _service.updateWord(updatedWord);
    await loadWords(); // refresh lists
  }

  Future<void> deleteWord(int id) async {
    await _service.deleteWord(id);
    await loadWords();
  }
}
