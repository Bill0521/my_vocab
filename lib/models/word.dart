class Word {
  final int? id;
  final String word;
  final String definition;
  final String? example;
  final int difficulty; // 0, 1, 2, 3 (0: new, 1: easy, 2: medium, 3: hard)
  final double easeFactor; // For spaced repetition (default 2.5)
  final int interval; // Days until next review
  final DateTime nextReviewDate;

  Word({
    this.id,
    required this.word,
    required this.definition,
    this.example,
    this.difficulty = 0,
    this.easeFactor = 2.5,
    this.interval = 0,
    required this.nextReviewDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'definition': definition,
      'example': example,
      'difficulty': difficulty,
      'easeFactor': easeFactor,
      'interval': interval,
      'nextReviewDate': nextReviewDate.toIso8601String(),
    };
  }

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      word: map['word'],
      definition: map['definition'],
      example: map['example'],
      difficulty: map['difficulty'],
      easeFactor: map['easeFactor'],
      interval: map['interval'],
      nextReviewDate: DateTime.parse(map['nextReviewDate']),
    );
  }

  Word copyWith({
    int? id,
    String? word,
    String? definition,
    String? example,
    int? difficulty,
    double? easeFactor,
    int? interval,
    DateTime? nextReviewDate,
  }) {
    return Word(
      id: id ?? this.id,
      word: word ?? this.word,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      difficulty: difficulty ?? this.difficulty,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
    );
  }
}
