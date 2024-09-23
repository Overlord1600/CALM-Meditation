import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class TextGeneration {
  TextGeneration._privateConstructor();
  static final TextGeneration _instance = TextGeneration._privateConstructor();
  static late GenerativeModel _model;
  factory TextGeneration() {
    String? apiKey = dotenv.env["API_KEY"];
    if (apiKey == null) {
      throw Exception("API key not found");
    }
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    return _instance;
  }

  Future<String> sendPrompt({required String prompt}) async {
    try {
      final aiResponse = await _model.generateContent([Content.text(prompt)]);
      return aiResponse.text.toString();
    } on GenerativeAIException catch (error) {
      return 'Error: ${error.message}';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }
}
