import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'services/speech_service.dart';
import 'services/gemini_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SpeechService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AI Chat Assistant',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          appBarTheme: const AppBarTheme(
            elevation: 2,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            centerTitle: true,
          ),
        ),
        home: const ChatScreen(),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user');
  final _assistant = const types.User(id: 'assistant', firstName: 'AI Assistant');
  bool _isLoading = false;
  bool _isProcessing = false;
  final TextEditingController _textController = TextEditingController();
  String _lastProcessedText = '';
  DateTime _lastMessageTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    final speechService = context.read<SpeechService>();
    bool available = await speechService.initialize();
    if (!available && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
    }
  }

  bool _canSendMessage(String text) {
    final now = DateTime.now();
    if (text.isEmpty || _isProcessing || text == _lastProcessedText) {
      return false;
    }
    if (now.difference(_lastMessageTime).inMilliseconds < 1000) {
      return false;
    }
    return true;
  }

  void _addMessage(String text, bool isUser) {
    if (text.trim().isEmpty) return;
    
    final message = types.TextMessage(
      author: isUser ? _user : _assistant,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _messages.insert(0, message);
      _lastMessageTime = DateTime.now();
    });
  }

  Future<void> _handleSendPressed() async {
    final text = _textController.text.trim();
    if (!_canSendMessage(text)) return;

    _lastProcessedText = text;
    _textController.clear();
    _addMessage(text, true);

    setState(() {
      _isLoading = true;
      _isProcessing = true;
    });

    try {
      final response = await GeminiService.getResponse(text);
      if (!response.startsWith('Error:')) {
        _addMessage(response, false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response)),
        );
      }
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to get response. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
        _isProcessing = false;
        _lastProcessedText = '';
      });
    }
  }

  void _handleVoicePressed() async {
    final speechService = context.read<SpeechService>();
    
    if (speechService.isListening) {
      await speechService.stopListening();
    } else {
      await speechService.startListening(
        onComplete: (text) {
          if (_canSendMessage(text)) {
            setState(() {
              _textController.text = text;
            });
            _handleSendPressed();
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final speechService = context.watch<SpeechService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Chat Assistant',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => setState(() {
              _messages.clear();
              _lastProcessedText = '';
              _lastMessageTime = DateTime.now();
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Chat(
              messages: _messages,
              onSendPressed: (_) {},
              user: _user,
              showUserAvatars: true,
              theme: const DefaultChatTheme(),
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          Container(
            margin: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    enabled: !_isProcessing,
                    decoration: InputDecoration(
                      hintText: speechService.isListening
                          ? 'Listening...'
                          : 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) {
                      if (!_isProcessing) {
                        _handleSendPressed();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  onPressed: !_isProcessing ? _handleVoicePressed : null,
                  backgroundColor: speechService.isListening ? Colors.red : Colors.blue,
                  elevation: 0,
                  child: Icon(
                    speechService.isListening ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                FloatingActionButton.small(
                  onPressed: !_isProcessing ? _handleSendPressed : null,
                  backgroundColor: Colors.blue,
                  elevation: 0,
                  child: const Icon(Icons.send, color: Colors.white),
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
} 