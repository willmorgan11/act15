import 'package:html_unescape/html_unescape.dart';

class Question {
  final String questionText;
  final List<String> options;       // answer list
  final int correctAnswer;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });

  // Factory constructor transforms a JSON map into a Question object
  factory Question.fromJson(Map<String, dynamic> json) {
    // decodes HTML encoded characters
    final unescape = HtmlUnescape();
    // creates options list starting with incorrect answers
    List<String> allOptions = List<String>.from(json['incorrect_answers']);
    // adds the correct answer
    allOptions.add(json['correct_answer']);
    // shuffles the answers
    allOptions.shuffle();

    final int correctIndex = allOptions.indexOf(json['correct_answer']);
    // return question object
    return Question(
      questionText: unescape.convert(json['question']),
      options: allOptions.map((o) => unescape.convert(o)).toList(),
      correctAnswer: correctIndex,
    );
  }
}