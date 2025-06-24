import 'dart:io';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import '../data_services/data_service_interface.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';
import 'package:fireflut_demo_app/models/user_account.dart';

class ChatViewModel extends ChangeNotifier {
  final UserDataService dataService;
  final GeminiService geminiService;

  final List<ChatMessage> _messages = [];
  bool _isWaitingForResponse = false;
  bool _isInitialized = false;
  bool _isDisposed = false;
  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;

  UserAccount? userAccount;

  ChatViewModel({required this.dataService, required this.geminiService});

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isWaitingForResponse => _isWaitingForResponse;
  bool get isInitialized => _isInitialized;
  File? get selectedImage => _selectedImage;
  Uint8List? get selectedImageBytes => _selectedImageBytes;
  String? get selectedImageName => _selectedImageName;
  bool get hasSelectedImage =>
      _selectedImage != null || _selectedImageBytes != null;

  Future<void> initialize() async {
    if (_isInitialized || _isDisposed) return;

    try {
      // Load user account first
      userAccount = await dataService.getUserAccount();
      await geminiService
          .initializeChat(); // Hide the initial message on initialization. Is there something else we can use to error check?
      // _messages.add(const ChatMessage(
      //   message: 'Welcome! How can I help you?',
      //   isMe: false,
      //   time: null,
      // ));
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing chat: $e');
      }
      rethrow;
    }
  }

  Future<void> sendMessage(String messageText) async {
    if (messageText.isEmpty && !hasSelectedImage || _isDisposed) return;
    if (!_isInitialized) {
      if (kDebugMode) {
        print('Warning: Attempting to send message before initialization');
      }
      await initialize();
    }

    _messages.add(
      ChatMessage(
        message: messageText,
        isMe: true,
        time: DateTime.now(),
        imagePath: _selectedImage?.path,
        imageBytes: _selectedImageBytes,
        imageName: _selectedImageName,
      ),
    );
    _isWaitingForResponse = true;
    notifyListeners();

    List<Part> parts = [TextPart(messageText)];

    if (hasSelectedImage) {
      Uint8List imageData;
      if (_selectedImage != null) {
        imageData = await _selectedImage!.readAsBytes();
      } else {
        imageData = _selectedImageBytes!;
      }
      parts.add(InlineDataPart('image/jpeg', imageData));

      // Clear selected image
      _selectedImage = null;
      _selectedImageBytes = null;
      _selectedImageName = null;
    }

    try {
      final response = await geminiService.sendMessageMultiPart(parts);
      _messages.add(
        ChatMessage(message: response, isMe: false, time: DateTime.now()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message to Gemini: $e');
      }
      _messages.add(
        const ChatMessage(
          message:
              'Sorry, I couldn\'t get a response. Please check your connection or try again later.',
          isMe: false,
          time: null,
        ),
      );
    } finally {
      if (!_isDisposed) {
        _isWaitingForResponse = false;
        notifyListeners();
      }
    }
  }

  Future<void> setSelectedImage({
    String? imagePath,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    if (_isDisposed) return;
    if (imagePath != null) {
      _selectedImage = File(imagePath);
      _selectedImageBytes = null;
    } else if (imageBytes != null) {
      _selectedImage = null;
      _selectedImageBytes = imageBytes;
    }
    _selectedImageName = imageName;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _selectedImage = null;
    _selectedImageBytes = null;
    super.dispose();
  }
}
