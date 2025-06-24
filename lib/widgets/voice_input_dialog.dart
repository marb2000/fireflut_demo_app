import 'package:flutter/material.dart';
import '../services/voice_service.dart';
import '../view_models/voice_input_view_model.dart';

class VoiceInputDialog extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback onTranscriptionComplete;

  const VoiceInputDialog({
    super.key,
    required this.messageController,
    required this.onTranscriptionComplete,
  });

  @override
  Widget build(BuildContext context) {
    final voiceViewModel = VoiceInputViewModel(VoiceServiceImpl());

    // Initial permission check
    voiceViewModel.checkPermissions().then((hasPermission) {
      if (!hasPermission && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required')),
        );
        Navigator.of(context).pop();
      }
    });

    return AnimatedBuilder(
      animation: voiceViewModel,
      builder: (context, child) {
        final state = voiceViewModel.state;

        return AlertDialog(
          title: const Text('Tell us what you need in your own words.'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onLongPressStart: (_) => voiceViewModel.startRecording(),
                onLongPressEnd: (_) => voiceViewModel.stopRecording(),
                child: IconButton(
                  iconSize: 60,
                  icon: Icon(
                    Icons.mic,
                    color: state.isRecording
                        ? Colors.red
                        : const Color(0xFFFFB300),
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(height: 20),
              Text(state.isRecording
                  ? 'Recording... Speak now'
                  : 'Press and hold to record'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(state.isPlaying ? Icons.stop : Icons.play_arrow),
                    label: Text(state.isPlaying ? 'Stop' : 'Replay'),
                    onPressed: state.hasRecordedAudio
                        ? () => voiceViewModel.togglePlayback()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: state.isPlaying ? Colors.red : null,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Process'),
                    onPressed: state.hasRecordedAudio
                        ? () async {
                            final currentContext = context;
                            final transcription =
                                await voiceViewModel.processRecording();
                            if (transcription != null &&
                                currentContext.mounted) {
                              messageController.text = transcription;
                              Navigator.of(currentContext).pop();
                              onTranscriptionComplete();
                            }
                          }
                        : null,
                  ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                voiceViewModel.dispose();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
