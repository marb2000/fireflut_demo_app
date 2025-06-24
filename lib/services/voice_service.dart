import 'dart:io';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';

abstract class VoiceService {
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Future<String?> startRecording();
  Future<String?> stopRecording();
  Future<String?> processVoiceInput(String audioPath);
  Future<void> playAudio(String audioPath);
  Future<void> stopPlayback();
  void dispose();
}

class VoiceServiceImpl implements VoiceService {
  final AudioRecorder _recorder;
  final AudioPlayer _player;
  String? _currentRecordingPath;
  final bool isWeb = kIsWeb;

  VoiceServiceImpl() : _recorder = AudioRecorder(), _player = AudioPlayer() {
    if (kIsWeb) {
      _recorder.hasPermission().then((hasPermission) {
        if (kDebugMode) {
          print('Web platform detected. Microphone permission: $hasPermission');
        }
      });
    }
  }

  @override
  Future<bool> hasPermission() async {
    return await _recorder.hasPermission();
  }

  @override
  Future<bool> requestPermission() async {
    var status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  @override
  Future<String?> startRecording() async {
    try {
      if (await hasPermission()) {
        if (kIsWeb) {
          _currentRecordingPath =
              'web_recording_${DateTime.now().millisecondsSinceEpoch}.wav';
        } else {
          final dir = await getTemporaryDirectory();
          _currentRecordingPath =
              '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.wav';
        }

        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.wav),
          path: _currentRecordingPath!,
        );

        return _currentRecordingPath;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error starting recording: $e');
      }
      rethrow;
    }
  }

  @override
  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      return path;
    } catch (e) {
      if (kDebugMode) {
        print('Error stopping recording: $e');
      }
      return null;
    }
  }

  @override
  Future<void> playAudio(String audioPath) async {
    try {
      if (kIsWeb) {
        await _player.play(UrlSource(audioPath));
      } else {
        await _player.play(DeviceFileSource(audioPath));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing audio: $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> stopPlayback() async {
    await _player.stop();
  }

  @override
  void dispose() {
    _player.dispose();
    _recorder.dispose();
  }

  @override
  Future<String?> processVoiceInput(String audioPath) async {
    try {
      final File audioFile = File(audioPath);
      var audioBytes = await audioFile.readAsBytes();

      final model = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-2.5-flash',
      );

      final response = await model.generateContent([
        Content.multi([
          TextPart("Transcribe this audio to text: "),
          InlineDataPart('audio/wav', audioBytes),
        ]),
      ]);

      // Trim off mysterious 'p', 'P', and ' ' characters that occasionally show up at the end of the response text.
      // Maybe they are silence?
      final text = response.text?.replaceAll(RegExp(r'(\s[pP\s]+)$'), '');

      return text;
    } catch (e) {
      if (kDebugMode) {
        print('Error processing voice input: $e');
      }
      return null;
    }
  }
}
