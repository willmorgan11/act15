import 'package:flutter/material.dart';
import 'api_service.dart';
import 'question.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  // the 4 essential state variables from the blueprint
  List<Question> _questions = [];         // the fetched data list
  int _currentQuestionIndex = 0;          // tracks progression
  int _score = 0;                         // tally of correct answers
  bool _answered = false;                 // controls whether answer button can be clicked

  // additional state for loading/error handling
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedAnswer;               // highlights the chosen button

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  // calls the API service and stores results in state
  Future<void> _loadQuestions() async {
    try {
      final questions = await ApiService.fetchQuestions();
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    }
    catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // called when a user taps an answer button
  void _handleAnswer(String selected) {
    if (_answered) return; // guard: ignore taps after first answer

    final question = _questions[_currentQuestionIndex];
    final correct = question.options[question.correctAnswer];

    setState(() {
      _answered = true;
      _selectedAnswer = selected;
      if (selected == correct) {
        _score++;
      }
    });
  }

  // advances to the next question, or ends the quiz
  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _answered = false;
        _selectedAnswer = null;
      });
    }
    else {
      _showResultsDialog();
    }
  }

  // shows the final score in a dialog
  void _showResultsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Quiz Complete! 🎉'),
        content: Text(
          'You scored $_score out of ${_questions.length}.',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // reset the quiz from the beginning
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _answered = false;
                _selectedAnswer = null;
                _isLoading = true;
              });
              _loadQuestions();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  // determines the color of each answer button after answering
  Color _buttonColor(String option) {
    if (!_answered) return Colors.indigo;

    final question = _questions[_currentQuestionIndex];
    final correct = question.options[question.correctAnswer];

    if (option == correct) return Colors.green;
    if (option == _selectedAnswer) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    // loading state
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Fetching questions...'),
            ],
          ),
        ),
      );
    }

    // error State
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Could not load questions.\n$_errorMessage',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _errorMessage = null;
                    });
                    _loadQuestions();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // quiz state
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Trivia Quiz'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Score: $_score',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // progress indicator
            Text(
              'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.indigo.shade100,
              color: Colors.indigo,
            ),
            const SizedBox(height: 32),
            // question card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  question.questionText,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // answer buttons
            ...question.options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _buttonColor(option),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    disabledBackgroundColor: _buttonColor(option),
                    disabledForegroundColor: Colors.white,
                  ),
                  // disable all buttons once answered
                  onPressed: _answered ? () {} : () => _handleAnswer(option),
                  child: Text(option, style: const TextStyle(fontSize: 16)),
                ),
              );
            }),

            const Spacer(),

            // next button, only appears after answering
            if (_answered)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _nextQuestion,
                child: Text(
                  _currentQuestionIndex < _questions.length - 1
                      ? 'Next Question →'
                      : 'See Results 🎉',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}