import 'dart:io';
import 'package:fireflut_demo_app/common_dependencies.dart';
import 'package:fireflut_demo_app/models/chat_message.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  Widget _buildImage() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate maximum width as 60% of the available width
          final maxWidth = constraints.maxWidth * 0.6;
          // Set a fixed maximum height
          const maxHeight = 200.0;

          return ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: kIsWeb
                  ? (message.imageBytes != null
                      ? Image.memory(
                          message.imageBytes!,
                          fit: BoxFit.contain,
                        )
                      : const SizedBox.shrink())
                  : (message.imagePath != null
                      ? Image.file(
                          File(message.imagePath!),
                          fit: BoxFit.contain,
                        )
                      : const SizedBox.shrink()),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      alignment: message.isMe ? Alignment.topRight : Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: message.isMe
              ? MediaQuery.of(context).size.width * 0.8
              : MediaQuery.of(context).size.width,
          minWidth: 100.0,
        ),
        child: Column(
          crossAxisAlignment:
              message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: message.isMe
                  ? BoxDecoration(
                      color: $styles.colors.primary.withValues(alpha: 0.25),
                      border: GradientBoxBorder(
                        gradient: LinearGradient(
                            colors: [
                              $styles.colors.primary.withValues(alpha: 0.8),
                              $styles.colors.background,
                            ],
                            begin: Alignment
                                .topLeft, // Start point of the gradient
                            end: Alignment.bottomRight),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(4.0),
                        topLeft: Radius.circular(24.0),
                        bottomLeft: Radius.circular(24.0),
                        bottomRight: Radius.circular(24.0),
                      ),
                    )
                  : BoxDecoration(// AI message styles

                      ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imagePath != null || message.imageBytes != null)
                    _buildImage(),
                  if (message.message.isNotEmpty)
                    MarkdownBody(
                      data: message.message,
                      styleSheet:
                          MarkdownStyleSheet.fromTheme(Theme.of(context))
                              .copyWith(
                        p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: message.isMe
                                  ? Colors.white
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                            ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0),
              child: Text(
                message.time != null
                    ? DateFormat('jm').format(message.time!)
                    : '',
                style: TextStyle(
                  fontSize: 12.0,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            if (message.imageName != null)
              Padding(
                padding:
                    const EdgeInsets.only(top: 4.0, left: 16.0, right: 16.0),
                child: Text(
                  message.imageName!,
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Theme.of(context).hintColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
