import 'dart:typed_data';

class ChatMessage {
  final String message;
  final bool isMe;
  final DateTime? time;
  final String? imagePath;
  final Uint8List? imageBytes;
  final String? imageName;

  const ChatMessage({
    required this.message,
    required this.isMe,
    this.time,
    this.imagePath,
    this.imageBytes,
    this.imageName,
  });
}
