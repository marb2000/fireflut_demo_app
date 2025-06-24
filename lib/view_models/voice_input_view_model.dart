// lib/view_models/voice_input_view_model.dart

import 'package:flutter/foundation.dart';
import '../services/voice_service.dart';

class VoiceInputState {
  final bool isRecording;
  final bool isPlaying;
  final bool hasRecordedAudio;
  final String? recordedAudioPath;
  final String? error;

  VoiceInputState({
    this.isRecording = false,
    this.isPlaying = false,
    this.hasRecordedAudio = false,
    this.recordedAudioPath,
    this.error,
  });

  VoiceInputState copyWith({
    bool? isRecording,
    bool? isPlaying,
    bool? hasRecordedAudio,
    String? recordedAudioPath,
    String? error,
  }) {
    return VoiceInputState(
      isRecording: isRecording ?? this.isRecording,
      isPlaying: isPlaying ?? this.isPlaying,
      hasRecordedAudio: hasRecordedAudio ?? this.hasRecordedAudio,
      recordedAudioPath: recordedAudioPath ?? this.recordedAudioPath,
      error: error,
    );
  }
}

class VoiceInputViewModel extends ChangeNotifier {
  final VoiceService _voiceService;
  VoiceInputState _state = VoiceInputState();

  VoiceInputViewModel(this._voiceService);

  VoiceInputState get state => _state;

  Future<bool> checkPermissions() async {
    try {
      return await _voiceService.hasPermission();
    } catch (e) {
      _updateState(error: 'Error checking permissions: $e');
      return false;
    }
  }

  Future<void> startRecording() async {
    try {
      if (await _voiceService.hasPermission()) {
        _updateState(
          isRecording: true,
          hasRecordedAudio: false,
          isPlaying: false,
          error: null,
        );

        final path = await _voiceService.startRecording();
        if (path != null) {
          _updateState(recordedAudioPath: path);
        } else {
          _updateState(
            isRecording: false,
            error: 'Failed to start recording',
          );
        }
      } else {
        _updateState(error: 'Microphone permission is required');
      }
    } catch (e) {
      _updateState(
        isRecording: false,
        error: 'Error recording: $e',
      );
    }
  }

  Future<void> stopRecording() async {
    try {
      _updateState(isRecording: false);

      final path = await _voiceService.stopRecording();
      if (path != null) {
        _updateState(
          hasRecordedAudio: true,
          recordedAudioPath: path,
        );
      }
    } catch (e) {
      _updateState(error: 'Error stopping recording: $e');
    }
  }

  Future<void> togglePlayback() async {
    try {
      if (_state.recordedAudioPath == null) return;

      if (_state.isPlaying) {
        await _voiceService.stopPlayback();
        _updateState(isPlaying: false);
      } else {
        await _voiceService.playAudio(_state.recordedAudioPath!);
        _updateState(isPlaying: true);
      }
    } catch (e) {
      _updateState(
        isPlaying: false,
        error: 'Error playing audio: $e',
      );
    }
  }

  Future<String?> processRecording() async {
    try {
      if (_state.recordedAudioPath == null) return null;

      if (_state.isPlaying) {
        await _voiceService.stopPlayback();
        _updateState(isPlaying: false);
      }

      return await _voiceService.processVoiceInput(_state.recordedAudioPath!);
    } catch (e) {
      _updateState(error: 'Error processing recording: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _voiceService.stopPlayback();
    _voiceService.dispose();
    super.dispose();
  }

  void _updateState({
    bool? isRecording,
    bool? isPlaying,
    bool? hasRecordedAudio,
    String? recordedAudioPath,
    String? error,
  }) {
    _state = _state.copyWith(
      isRecording: isRecording,
      isPlaying: isPlaying,
      hasRecordedAudio: hasRecordedAudio,
      recordedAudioPath: recordedAudioPath,
      error: error,
    );
    notifyListeners();
  }
}
