import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:fireflut_demo_app/common_dependencies.dart';
import 'package:fireflut_demo_app/data_services/data_service_interface.dart';
import 'package:fireflut_demo_app/services/gemini_service.dart';
import 'package:fireflut_demo_app/view_models/chat_view_model.dart';
import 'package:fireflut_demo_app/views/chat_bubble.dart';
import 'package:flutter/foundation.dart';
import '../utils/voice_input_mixin.dart';
import '../widgets/skeleton_loader.dart';

class ChatScreen extends StatefulWidget {
  final UserDataService dataService;
  final GeminiService geminiService;
  final String? initialUserMessage;
  final bool openVoiceDialogOnInit;

  const ChatScreen({
    super.key,
    required this.dataService,
    required this.geminiService,
    this.initialUserMessage,
    this.openVoiceDialogOnInit = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with VoiceInputMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatViewModel _viewModel;

  bool _showChatInputArea = false;

  @override
  GeminiService get geminiService => widget.geminiService;

  @override
  UserDataService get dataService => widget.dataService;

  @override
  void onVoiceInputResponse(String response) {
    _messageController.text = response;
    _sendMessage();
  }

  @override
  void initState() {
    super.initState();
    _viewModel = ChatViewModel(
      dataService: widget.dataService,
      geminiService: widget.geminiService,
    );
    _viewModel.addListener(_handleViewModelUpdate);
    _initializeChat();

    if (widget.openVoiceDialogOnInit) {
      // Use Future.delayed to ensure the widget is fully built
      Future.delayed(Duration.zero, () {
        if (mounted) {
          showVoiceInputDialog(context, _messageController, _sendMessage);
        }
      });
    }
  }

  Future<void> _initializeChat() async {
    await _viewModel.initialize();

    if (widget.initialUserMessage != null) {
      await _viewModel.sendMessage(widget.initialUserMessage!);
    }
  }

  void _handleViewModelUpdate() {
    setState(() {});
    if (_viewModel.isWaitingForResponse) {
      // Only scroll while in loading state to stay at the top of the incoming response
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _viewModel.removeListener(_handleViewModelUpdate);
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _scrollToBottom() async {
    if (_scrollController.hasClients) {
      await Future.delayed(const Duration(milliseconds: 300));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null) {
        if (kIsWeb) {
          await _viewModel.setSelectedImage(
            imageBytes: result.files.first.bytes!,
            imageName: result.files.first.name,
          );
        } else {
          await _viewModel.setSelectedImage(
            imagePath: result.files.first.path!,
            imageName: result.files.first.name,
          );
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error picking image: $error');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error picking image. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty && !_viewModel.hasSelectedImage) {
      return;
    }

    _messageController.clear();
    await _viewModel.sendMessage(messageText);
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Gemini'),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            if (_viewModel.messages.isEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: EdgeInsets.all($styles.insets.md),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Hello ',
                              style: textTheme.headlineLarge,
                            ),
                            Text(
                              _viewModel.userAccount?.firstName ?? '',
                              style: textTheme.headlineLarge
                                  ?.copyWith(fontWeight: FontWeight.w600, color: $styles.colors.secondary),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'How Can I Help?',
                              style: textTheme.headlineLarge,
                            ),
                          ],
                        ),
                        SizedBox(height: $styles.insets.lg),
                        _buildPresetButtons()
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms).shimmer(duration: 1.seconds, delay: 500.ms),

            if (_viewModel.messages.isNotEmpty)
            Expanded(
            child: GestureDetector(
                onTap: () {
                  if (_showChatInputArea) {
                    // Add onTap callback
                    setState(() {
                      _showChatInputArea = !_showChatInputArea;
                    });
                  }
                },
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _viewModel.messages.length +
                      (_viewModel.isWaitingForResponse ? 1 : 0),
                  // Add 1 if loading
                  padding: EdgeInsets.all($styles.insets.sm),
                  itemBuilder: (context, index) {
                    if (index == _viewModel.messages.length &&
                        _viewModel.isWaitingForResponse) {
                      return Padding(
                        padding: EdgeInsets.all($styles.insets.sm),
                        child: const SkeletonLoader(),
                      );
                    } else {
                      // Show chat bubble
                      return ChatBubble(message: _viewModel.messages[index]);
                    }
                  },
                )
            ),
            ),


            if (_viewModel.selectedImage != null ||
                _viewModel.selectedImageBytes != null)
              Padding(
                padding: EdgeInsets.all($styles.insets.sm),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: _buildSelectedImage(),
                ),
              ),
            Visibility(
              visible: _showChatInputArea,
              child: _buildChatInputArea(),
            ),
            Visibility(
              visible: !_showChatInputArea,
              child: _buildChatInputLauncher(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImage() {
    if (_viewModel.selectedImage != null) {
      return Image.file(_viewModel.selectedImage!);
    } else if (_viewModel.selectedImageBytes != null) {
      return Image.memory(
        _viewModel.selectedImageBytes!,
        fit: BoxFit.contain,
      );
    }
    return const SizedBox.shrink();
  }

  final List<String> _presetPrompts = [
    "What's included in my plan?",
    "What is my current balance?",
    "How much data do I have left?",
    "Do you offer device upgrades?",
    "How can I reduce my data usage?",
  ];

  Widget _buildPresetButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: $styles.insets.sm,
      children: _presetPrompts.asMap().entries.map((entry) {
        // Use asMap().entries
        final index = entry.key; // Get the index
        final prompt = entry.value; // Get the prompt
        return InkWell(
          onTap: () {
            _messageController.text = prompt;
            _sendMessage();
          },
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: $styles.insets.sm, vertical: $styles.insets.xs),
            // Add padding
            decoration: BoxDecoration(
              color: $styles.colors.primary.withValues(alpha: 0.25),
              border: GradientBoxBorder(
                gradient: LinearGradient(
                  colors: [
                    $styles.colors.primary.withValues(alpha: 0.8),
                    // Use withOpacity
                    $styles.colors.background,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),

            child: Text(
              // Text widget for the prompt
              prompt,
              style: TextStyle(
                // Style the text
                color: $styles.colors.textPrimary,
              ),
            ),
          )
              .animate(delay: (index * 300).ms) // Use index for delay
              .slide(
                begin: const Offset(0, 1),
                duration: 500.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(duration: 300.ms, curve: Curves.easeOut),
        );
      }).toList(),
    );
  }

  Widget _buildChatInputLauncher() {
    return GestureDetector(
      // Wrap with GestureDetector
      onTap: () {
        setState(() {
          _showChatInputArea = !_showChatInputArea; // Toggle visibility on tap
        });
      },
      child: Container(
        constraints: const BoxConstraints(
            // minHeight: 200.0,
            ),
        margin: const EdgeInsets.only(
          top: .0, // Top margin
          bottom: 32.0, // Bottom margin
          left: 8.0, // Left margin
          right: 8.0, // Right margin
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              $styles.colors.primary.withValues(alpha: 0.25),
              // Replace with your desired colors
              $styles.colors.background,
            ],
          ),
          border: GradientBoxBorder(
            gradient: LinearGradient(
                colors: [
                  $styles.colors.primary.withValues(alpha: 0.8),
                  $styles.colors.background,
                ],
                begin: Alignment.topCenter, // Start point of the gradient
                end: Alignment.bottomCenter),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(48.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: $styles.insets.sm),
                    child: SizedBox(
                      child: Text(
                        'Ask $appNameShort',
                        style: TextStyle(
                          color: $styles
                              .colors.textPrimary, // Or your desired hint color
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        $styles.colors.accent1,
                        // Replace with your desired colors
                        $styles.colors.secondary,
                      ],
                    ),
                    border: GradientBoxBorder(
                      gradient: LinearGradient(
                          colors: [
                            $styles.colors.primary.withValues(alpha: 0.8),
                            $styles.colors.background,
                          ],
                          begin: Alignment.topLeft,
                          // Start point of the gradient
                          end: Alignment.bottomRight),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(48.0), // Example radius
                  ),
                  padding: const EdgeInsets.all(8.0),
                  // Example padding (optional)
                  child: Row(
                    // Wrap the IconButtons in a Row
                    children: [
                      IconButton(
                        icon: Icon(Icons.image,
                            color: $styles.colors.textPrimary),
                        onPressed: _pickImageFromGallery,
                      ),
                      IconButton(
                        icon:
                            Icon(Icons.mic, color: $styles.colors.textPrimary),
                        onPressed: () => showVoiceInputDialog(
                            context, _messageController, _sendMessage),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .scale(
                        begin: const Offset(0.8, 0.8),
                        duration: 800.ms,
                        curve: Curves.elasticOut,
                        delay: 300.ms)
                    .fadeIn(
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                        delay: 300.ms),
              ],
            ), // Empty row (takes up minimal space)
          ],
        ),
      )
          .animate()
          .scale(
            begin: const Offset(0.8, 0.8), // Start slightly smaller
            duration: 200.ms, // Duration of the scaling animation
            curve: Curves.easeOut, // Optional easing curve
          )
          .fadeIn(
            duration: 150.ms, // Duration of the fade-in animation
            curve: Curves.easeIn, // Optional easing curve
          ),
    );
  }

  Widget _buildChatInputArea() {
    return Container(
            constraints: const BoxConstraints(
              minHeight: 200.0,
            ),
            padding: const EdgeInsets.only(
              top: 16.0,
              bottom: 32.0, // Bottom padding is now 32
              left: 16.0,
              right: 16.0,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  $styles.colors.primary.withValues(alpha: 0.5),
                  // Replace with your desired colors
                  $styles.colors.background,
                ],
              ),
              border: GradientBoxBorder(
                gradient: LinearGradient(
                    colors: [
                      $styles.colors.primary.withValues(alpha: 0.8),
                      $styles.colors.background,
                    ],
                    begin: Alignment.topCenter, // Start point of the gradient
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Ask $appNameShort',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.all(0),
                        ),
                        autofocus: true,
                        keyboardType: TextInputType.text,
                        // Key change: Multiline input
                        maxLines: null,
                        minLines: 3,
                        onSubmitted: (_) {
                          // Modify onSubmitted
                          _sendMessage();
                          setState(() {
                            _showChatInputArea = !_showChatInputArea;
                          });
                        },
                      ),
                    ),
                  ],
                ), // Empty row (takes up minimal space)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon:
                          Icon(Icons.image, color: $styles.colors.textPrimary),
                      onPressed: _pickImageFromGallery,
                    )
                        .animate()
                        .scale(
                            begin: const Offset(0.8, 0.8),
                            duration: 800.ms,
                            curve: Curves.elasticOut,
                            delay: 500.ms)
                        .fadeIn(
                            duration: 300.ms,
                            curve: Curves.elasticOut,
                            delay: 500.ms),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [
                                $styles.colors.accent1,
                                // Replace with your desired colors
                                $styles.colors.secondary,
                              ],
                            ),
                            border: GradientBoxBorder(
                              gradient: LinearGradient(
                                  colors: [
                                    $styles.colors.primary
                                        .withValues(alpha: 0.8),
                                    $styles.colors.background,
                                  ],
                                  begin: Alignment.topLeft,
                                  // Start point of the gradient
                                  end: Alignment.bottomRight),
                              width: 1,
                            ),
                            borderRadius:
                                BorderRadius.circular(48.0), // Example radius
                          ),
                          child: IconButton(
                            icon: Icon(Icons.mic,
                                color: $styles.colors.textPrimary),
                            onPressed: () => showVoiceInputDialog(
                                context, _messageController, _sendMessage),
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
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: $styles.colors.textPrimary),
                      onPressed: () {
                        // Use an anonymous function
                        _sendMessage();
                        setState(() {
                          _showChatInputArea =
                              !_showChatInputArea; // Toggle visibility
                        });
                      },
                    )
                        .animate()
                        .scale(
                            begin: const Offset(0.8, 0.8),
                            duration: 800.ms,
                            curve: Curves.elasticOut,
                            delay: 500.ms)
                        .fadeIn(
                            duration: 300.ms,
                            curve: Curves.elasticOut,
                            delay: 500.ms),
                  ],
                ),
              ],
            ))
        .animate()
        .slide(
          begin: const Offset(0, 1),
          duration: 200.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(
          duration: 200.ms,
          curve: Curves.easeOut,
        );
  }
}
