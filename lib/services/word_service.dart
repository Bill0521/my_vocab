import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:my_vocab/models/word.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

class WordService {
  static final WordService _instance = WordService._internal();
  factory WordService() => _instance;
  WordService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'my_vocab.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE words(id INTEGER PRIMARY KEY AUTOINCREMENT, word TEXT, definition TEXT, example TEXT, difficulty INTEGER, easeFactor REAL, interval INTEGER, nextReviewDate TEXT)',
        );
        await _loadInitialData(db);
      },
    );
  }

  Future<void> _loadInitialData(Database db) async {
     try {
       final csvString = await rootBundle.loadString('assets/cet6.csv');
       final List<List<dynamic>> fields = const CsvToListConverter().convert(csvString);
       
       if (fields.isNotEmpty) {
           final batch = db.batch();
           for (var row in fields) {
            if (row.length >= 2) { 
              final word = Word(
                word: row[0].toString(),
                definition: row[1].toString(),
                example: row.length > 2 ? row[2].toString() : null,
                nextReviewDate: DateTime.now(), 
              );
              batch.insert('words', word.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
            }
          }
          await batch.commit(noResult: true);
       }
     } catch (e) {
       print("Error loading initial data: $e");
     }
  }

  Future<void> insertWord(Word word) async {
    final db = await database;
    await db.insert(
      'words',
      word.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Word>> getWords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('words');
    return List.generate(maps.length, (i) {
      return Word.fromMap(maps[i]);
    });
  }

  Future<List<Word>> getWordsDueToday() async {
    final db = await database;
    final today = DateTime.now();
    final todayStr = today.toIso8601String().substring(0, 10); // Simple date check
    
    // Get all words and filter in Dart for simpler logic, or implement date comparison in SQL
    // For simplicity, let's fetch all and filter where date <= now
    final List<Map<String, dynamic>> maps = await db.query('words');
    
    return maps.map((map) => Word.fromMap(map)).where((word) {
      // If interval is 0 (new word) or due date is today or before
      return word.nextReviewDate.isBefore(today) || word.nextReviewDate.isAtSameMomentAs(today);
    }).toList();
  }
  
  Future<void> updateWord(Word word) async {
    final db = await database;
    await db.update(
      'words',
      word.toMap(),
      where: 'id = ?',
      whereArgs: [word.id],
    );
  }

  Future<void> deleteWord(int id) async {
    final db = await database;
    await db.delete(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> importCSV(File file) async {
    final input = file.openRead();
    final fields = await input.transform(utf8.decoder).transform(new CsvToListConverter()).toList();

    await _insertRows(fields);
  }

  Future<void> importAssetCSV() async {
     try {
       final csvString = await rootBundle.loadString('assets/cet6.csv');
       final List<List<dynamic>> fields = const CsvToListConverter().convert(csvString);
       
       if (fields.isNotEmpty) {
           await _insertRows(fields);
       }
     } catch (e) {
       print("Error importing asset: $e");
       // rethrow; // causing safe mode issues if UI doesn't catch
     }
  }

  Future<void> _insertRows(List<List<dynamic>> rows) async {
     // Use database getter directly, don't await database again if it's already a future
     // Actually, just calling database getter is fine.
     final db = await database;
     final batch = db.batch(); // Use batch for faster insertion

     for (var row in rows) {
      if (row.length >= 2) { 
        final word = Word(
          word: row[0].toString(),
          definition: row[1].toString(),
          example: row.length > 2 ? row[2].toString() : null,
          nextReviewDate: DateTime.now(), 
        );
        // Important: conflictAlgorithm is named argument
        batch.insert('words', word.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
    await batch.commit(noResult: true);
  }
  
  Future<String> exportCSV() async {
    final words = await getWords();
    List<List<dynamic>> rows = [];
    rows.add(["Word", "Definition", "Example", "Next Review"]);
    for (var w in words) {
      rows.add([w.word, w.definition, w.example, w.nextReviewDate.toIso8601String()]);
    }
    return const ListToCsvConverter().convert(rows);
  }
}
