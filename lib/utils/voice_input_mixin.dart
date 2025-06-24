import 'package:flutter/services.dart';
import 'package:fireflut_demo_app/data_services/data_service_interface.dart';
import 'package:fireflut_demo_app/services/gemini_service.dart';
import 'package:fireflut_demo_app/common_dependencies.dart';
import '../services/voice_service.dart';
import '../view_models/voice_input_view_model.dart';

class RippleAnimation extends StatelessWidget {
  const RippleAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    const int numCircles = 5;

    return Center(
      child: SizedBox(
        width: 300,
        height: 300,
        child: Stack(
          children: List.generate(numCircles, (index) {
            // Delay for each circle to create the staggered effect
            final delay = (index * 100).ms;

            return Center(
              child: Container(
                width: 100.0 + (index * 50.0),
                // Increasing size for each circle
                height: 100.0 + (index * 50.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: GradientBoxBorder(
                    gradient: LinearGradient(
                      colors: [
                        $styles.colors.primary
                            .withValues(alpha: 0.5 - (index * 0.1)),
                        // Use withOpacity
                        $styles.colors.background,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    width: 1,
                  ),
                ),
              )
                  .animate(
                      delay: delay,
                      onPlay: (controller) => controller.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1), // Initial size of the circle
                    end: const Offset(3.0, 3.0), // Final size of the circle
                    duration: 800.ms, // Duration of the scaling animation
                    curve: Curves.easeOut, // Easing curve
                  ),
            );
          }),
        ),
      ),
    );
  }
}

mixin VoiceInputMixin<T extends StatefulWidget> on State<T> {
  late final VoiceInputViewModel _voiceViewModel;

  GeminiService get geminiService;

  UserDataService get dataService;

  void onVoiceInputResponse(String response);

  @override
  void initState() {
    super.initState();
    _voiceViewModel = VoiceInputViewModel(VoiceServiceImpl());
    _voiceViewModel.addListener(_handleVoiceStateChanges);
  }

  @override
  void dispose() {
    _voiceViewModel.removeListener(_handleVoiceStateChanges);
    super.dispose();
  }

  void _handleVoiceStateChanges() {
    final state = _voiceViewModel.state;
    if (state.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.error!)),
      );
    }
  }

  void showVoiceInputDialog(BuildContext context,
      TextEditingController messageController, Function() onSendMessage) {
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

    showModalBottomSheet(
      context: context,
      backgroundColor: $styles.colors.background,
      clipBehavior: Clip.none,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        TextTheme textTheme = Theme.of(context).textTheme;
        return AnimatedBuilder(
          animation: voiceViewModel,
          builder: (context, child) {
            final state = voiceViewModel.state;

            return GestureDetector(
              onLongPressStart: (_) {
                HapticFeedback.lightImpact(); // Add haptic feedback
                voiceViewModel.startRecording();
              },
              onLongPressEnd: (_) async {
                await voiceViewModel.stopRecording();
                final currentContext = context;
                final transcription = await voiceViewModel.processRecording();
                if (transcription != null && currentContext.mounted) {
                  messageController.text = transcription;
                  Navigator.of(currentContext).pop();
                  onSendMessage();
                }
              },
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 200.0,
                  minWidth: double.infinity,
                ),
                decoration: BoxDecoration(
                  color: $styles.colors.background,
                  boxShadow: [
                    BoxShadow(
                      color: $styles.colors.secondary,
                      // Shadow color with opacity
                      blurRadius: 40,
                      // Blur radius of the shadow
                      spreadRadius: 0,
                      // Spread radius of the shadow
                      offset:
                          const Offset(0, 0), // Offset of the shadow (upwards)
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24.0),
                    topLeft: Radius.circular(24.0),
                    bottomLeft: Radius.circular(0.0),
                    bottomRight: Radius.circular(0.0),
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        $styles.colors.primary.withValues(alpha: 0.5),
                        $styles.colors.background,
                      ],
                    ),
                    border: GradientBoxBorder(
                      gradient: LinearGradient(
                          colors: [
                            $styles.colors.secondary.withValues(alpha: 0.8),
                            $styles.colors.background,
                          ],
                          begin: Alignment
                              .topCenter, // Start point of the gradient
                          end: Alignment.bottomCenter),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(24.0),
                      topLeft: Radius.circular(24.0),
                      bottomLeft: Radius.circular(0.0),
                      bottomRight: Radius.circular(0.0),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            child: SizedBox(
                              height: 200,
                              child: state.isRecording // Condition is now here
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(24.0),
                                      child: Align(
                                        child: const RippleAnimation()
                                            .animate()
                                            .fadeIn(delay: 200.ms),
                                      ),
                                    )
                                  : const SizedBox(
                                      width: double.infinity,
                                      height: double.infinity),
                            ),
                          ),
                          AnimatedContainer(
                            duration: 300.ms,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: state.isRecording
                                    ? [
                                        $styles.colors.accent1,
                                        $styles.colors.secondary,
                                      ]
                                    : [
                                        $styles.colors.border,
                                        $styles.colors.border,
                                      ],
                              ),
                              borderRadius:
                                  BorderRadius.circular(48.0), // Example radius
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: state.hasRecordedAudio
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors
                                              .white), // Customize color if needed
                                    )
                                  : IconButton(
                                      icon: Icon(Icons.mic,
                                          size: 56,
                                          color: $styles.colors.textPrimary),
                                      onPressed: null,
                                    ),
                            ),
                          )
                              .animate()
                              .scale(
                                  begin: const Offset(0.8, 0.8),
                                  duration: 800.ms,
                                  curve: Curves.elasticOut,
                                  delay: 300.ms)
                              .fadeIn(
                                  duration: 300.ms,
                                  curve: Curves.elasticOut,
                                  delay: 300.ms),
                          Positioned(
                            top: 20,
                            // Adjust the distance from the bottom as needed

                            child: state.isRecording
                                ? Text(
                                    'Listening…',
                                    style: textTheme.bodyLarge,
                                  ).animate().fadeIn(delay: 200.ms)
                                : (state.hasRecordedAudio // Add the else if condition
                                    ? Text(
                                        'Processing...',
                                        style: textTheme.bodyLarge,
                                      ).animate().fadeIn(delay: 400.ms)
                                    : Text(
                                        'Press and hold to talk',
                                        style: textTheme.bodyLarge?.copyWith(
                                            color: $styles.colors.secondary),
                                      ).animate().fadeIn(delay: 200.ms)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
