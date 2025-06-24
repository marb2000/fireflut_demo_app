import 'package:fireflut_demo_app/data_services/mock_data_service.dart';
import 'package:fireflut_demo_app/firebase_options.dart';
import 'package:fireflut_demo_app/fireflut_app.dart';
import 'package:fireflut_demo_app/services/gemini_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final MockDataService dataService = MockDataService();
  final GeminiService geminiService = GeminiService(dataService);
  runApp(FireflutApp(geminiService: geminiService, dataService: dataService));
}
