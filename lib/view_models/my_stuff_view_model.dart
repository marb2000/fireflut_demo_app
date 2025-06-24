import 'package:flutter/material.dart';
import '../data_services/data_service_interface.dart';
import '../services/gemini_service.dart';

class MyStuffViewModel {
  final UserDataService dataService;
  final GeminiService geminiService;

  MyStuffViewModel({required this.dataService, required this.geminiService});

  void navigateToChat(BuildContext context, Widget chatScreen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => chatScreen),
    );
  }
}
