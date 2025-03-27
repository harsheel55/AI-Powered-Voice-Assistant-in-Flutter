# AI Voice Assistant

A Flutter application that combines voice commands with OpenAI's GPT model to create an intelligent voice assistant. Users can interact with the assistant through both voice commands and text input.

## Features

- Voice command support using Alan AI
- Text-to-speech capabilities
- Integration with OpenAI's GPT-3.5 Turbo model
- Real-time chat interface
- Support for both voice and text input
- Message history with clear chat functionality
- Loading states and error handling
- Cross-platform support (iOS and Android)

## Setup

1. Clone the repository
2. Install dependencies:
```bash
flutter pub get
```

3. Set up API Keys:

### Alan AI Setup
1. Create an account at [Alan AI](https://alan.app/)
2. Create a new project
3. Replace `YOUR_ALAN_SDK_KEY` in `lib/services/alan_service.dart` with your Alan SDK key

### OpenAI Setup
1. Create an account at [OpenAI](https://openai.com)
2. Generate an API key
3. Replace `YOUR_OPENAI_API_KEY` in `lib/services/openai_service.dart` with your OpenAI API key

## Running the App

```bash
flutter run
```

## Usage

### Text Input
1. Type your message in the text field at the bottom
2. Press the send button or hit enter
3. Wait for the AI's response

### Voice Input
1. Tap the microphone icon in the app bar
2. Speak your command or question
3. The assistant will process your speech and respond both visually and audibly

### Additional Features
- Clear chat history using the delete button in the app bar
- View loading states while the AI processes your request
- Scroll through message history

## Permissions

### Android
The following permissions are required:
- `RECORD_AUDIO`: For voice command functionality
- `INTERNET`: For API communication
- `ACCESS_NETWORK_STATE`: For network connectivity

### iOS
The following permissions are required:
- `NSMicrophoneUsageDescription`: For voice command functionality
- `NSSpeechRecognitionUsageDescription`: For speech recognition

## Dependencies

- `alan_voice: ^4.9.0`: For voice command processing
- `provider: ^6.0.5`: For state management
- `http: ^1.1.0`: For API communication
- `shared_preferences: ^2.2.2`: For local storage

## Error Handling

The app includes error handling for:
- Network connectivity issues
- API failures
- Voice recognition errors
- Invalid responses

## Contributing

Feel free to submit issues and enhancement requests! 