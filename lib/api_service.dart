import 'dart:convert';
import 'package:http/http.dart' as http;
import 'question.dart';

class ApiService {
  // API url, set to 10 questions, general knowledge, easy, multiple choice
  static const String _url =
      'https://opentdb.com/api.php?amount=10&category=9&difficulty=easy&type=multiple';

  // fetches 10 trivia questions from Open Trivia DB
  // returns a list of Question objects, or throws an exception on failure
  static Future<List<Question>> fetchQuestions() async {
    try {
      // send the get request and wait for a response
      final response = await http.get(Uri.parse(_url));
      // check the HTTP status code — 200 means OK
      if (response.statusCode == 200) {
        // decode the JSON string into a Dart Map
        final Map<String, dynamic> data = jsonDecode(response.body);
        // navigate to the results list and map each item to a Question
        final List<dynamic> results = data['results'];
        return results.map((item) => Question.fromJson(item)).toList();
      }
      else {
        throw Exception('Server error: ${response.statusCode}');
      }
    }
    catch (e) {
      // catches both network errors and parsing errors
      throw Exception('Failed to load questions: $e');
    }
  }
}