import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static Future<String> getResponse(String message) async {
    if (_apiKey.isEmpty) {
      return 'Error: Gemini API key not configured. Please add your API key to the .env file.';
    }

    try {
      print('Sending request to Gemini API...'); // Debug print
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': message
                }
              ]
            }
          ]
        }),
      );

      print('Response status code: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content']['parts'][0]['text'];
          return content.trim();
        }
        return 'Error: Unexpected response format from API';
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['error']['message'] ?? 'Unknown error occurred';
        
        if (errorMessage.contains('quota')) {
          return 'Error: API quota exceeded. Please check your Google Cloud Console billing status.';
        }
        
        return 'Error: $errorMessage';
      }
    } catch (e) {
      print('Gemini API Error: $e'); // Debug print
      if (e.toString().contains('Failed host lookup')) {
        return 'Error: No internet connection. Please check your network and try again.';
      }
      return 'Error: An unexpected error occurred. Please try again.';
    }
  }
} 