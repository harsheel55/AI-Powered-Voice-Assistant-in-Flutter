import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';

class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void addMessage(String text, bool isUser) {
    _messages.add(ChatMessage(text: text, isUser: isUser));
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty) return;
    
    addMessage(text, true);
    _isLoading = true;
    notifyListeners();

    try {
      final response = await GeminiService.getResponse(text);
      addMessage(response, false);
    } catch (e) {
      addMessage('Sorry, I encountered an error. Please try again.', false);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
} 