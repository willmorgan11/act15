class Question {
  final String questionText;
  final List<String> options;       // answer list
  final String correctAnswer;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });

  // Factory constructor transforms a JSON map into a Question object
  factory Question.fromJson(Map<String, dynamic> json) {
    // creates options list starting with incorrect answers
    List<String> allOptions = List<String>.from(json['incorrect_answers']);
    // adds the correct answer
    allOptions.add(json['correct_answer']);
    // shuffles the answers
    allOptions.shuffle();

    // return question object
    return Question(
      questionText: json['question'],
      options: allOptions,
      correctAnswer: json['correct_answer'],
    );
  }
}