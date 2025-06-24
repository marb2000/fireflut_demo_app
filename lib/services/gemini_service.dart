import 'dart:async';
import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:fireflut_demo_app/data_services/data_service_interface.dart';
import 'package:fireflut_demo_app/models/location_fact.dart';
import 'package:fireflut_demo_app/models/plan.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Constants for asset paths
class GeminiAssets {
  static const String chatSystemPromptTemplate =
      'assets/chat_system_prompt.txt';
  static const String plansAndServicesManual = 'assets/plans_and_services.md';
  static const String recommendationsSystemPromptTemplate =
      'assets/recomendations_system_prompt.txt';
  static const String locationFactUserPromptTemplate =
      'assets/location_fact_prompt.txt';
}

class GeminiService {
  final UserDataService _dataService;
  GenerativeModel? _chatModel;
  ChatSession? _chatSession;
  String _chatSystemPromptTemplate = "";
  String _plansAndServicesData = "";
  bool _isInitialized = false;

  GeminiService(this._dataService);

  /// Generates a historical fact for a specific location
  Future<LocationFact?> generateLocationFact(
    String cityName,
    String countryName,
  ) async {
    try {
      // Format today's date for the prompt
      final todayFormatted = DateFormat('MMMM d').format(DateTime.now());

      // Load the location fact prompt template
      final locationFactUserPromptTemplate = await rootBundle.loadString(
        GeminiAssets.locationFactUserPromptTemplate,
      );

      // Replace placeholders in the prompt
      final locationFactUserPrompt = locationFactUserPromptTemplate
          .replaceAll('{city}', cityName)
          .replaceAll('{country}', countryName)
          .replaceAll('{today}', todayFormatted);

      // Initialize a Gemini model with appropriate configuration for fact generation
      final factGenerationModel = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-2.5-flash',
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.8,
        ),
      );

      // Generate the fact
      final factResponse = await factGenerationModel.generateContent([
        Content.text(locationFactUserPrompt),
      ]);

      // Parse and return the location fact
      return _parseLocationFactResponse(
        factResponse.text,
        cityName,
        countryName,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error generating location fact: $e');
      }
      return null;
    }
  }

  /// Generates personalized recommendations based on user data and location
  Future<String> generateRecommendations(String userLocation) async {
    try {
      // Load the recommendations system prompt
      final recommendationsSystemPromptTemplate = await rootBundle.loadString(
        GeminiAssets.recommendationsSystemPromptTemplate,
      );

      // Load plans and services data if not already loaded
      if (_plansAndServicesData.isEmpty) {
        _plansAndServicesData = await rootBundle.loadString(
          GeminiAssets.plansAndServicesManual,
        );
      }

      // Get the user data as JSON
      final userData = await _dataService.getUserDataAsJson();

      // Format the prompt with the plans and services info
      String recommendationsSystemPrompt = recommendationsSystemPromptTemplate
          .replaceAll('{plans_and_services}', _plansAndServicesData);

      // Initialize a new Gemini model specifically for recommendations
      final recommendationsModel = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-2.5-flash',
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
        systemInstruction: Content.system(recommendationsSystemPrompt),
      );

      // Generate recommendations based on user location and data
      var response = await recommendationsModel.generateContent([
        Content.text(
          "Generate Recommendations for a user in $userLocation. This is the user data $userData",
        ),
      ]);

      // Return the response text or an empty recommendations array
      return response.text ?? '{"recommendations": []}';
    } catch (error) {
      if (kDebugMode) print('Error generating recommendations: $error');
      return '{"recommendations": []}';
    }
  }

  /// Initializes the Gemini service and creates a chat session
  Future<void> initializeChat() async {
    // Skip initialization if already done
    if (_isInitialized && _chatModel != null) return;

    try {
      // Load prompts and user data
      _chatSystemPromptTemplate = await rootBundle.loadString(
        GeminiAssets.chatSystemPromptTemplate,
      );
      _plansAndServicesData = await rootBundle.loadString(
        GeminiAssets.plansAndServicesManual,
      );
      final userData = await _dataService.getUserDataAsJson();

      // Format the system prompt with the user's data and service information
      final chatSystemInstructions = _chatSystemPromptTemplate
          .replaceAll('{user_data}', userData)
          .replaceAll('{plans_and_services}', _plansAndServicesData);

      // Initialize the Gemini model with function declarations
      _chatModel = FirebaseAI.vertexAI().generativeModel(
        model: 'gemini-2.5-flash',
        tools: [
          Tool.functionDeclarations([
            _dataService.updateUserPlanFuntionDeclaration(),
          ]),
        ],
        systemInstruction: Content.system(chatSystemInstructions),
      );

      // Start a new chat session
      _chatSession = _chatModel!.startChat();
      _isInitialized = true;
    } catch (error) {
      if (kDebugMode) {
        print('Error initializing Gemini via Firebase: $error');
      }
      _isInitialized = false;
      rethrow;
    }
  }

  /// Sends a multi-part message to Gemini and processes any function calls in the response
  Future<String> sendMessageMultiPart(List<Part> messageParts) async {
    if (_chatSession == null || !_isInitialized) {
      await initializeChat();
      if (_chatSession == null) {
        return 'Error: Gemini not initialized.';
      }
    }

    try {
      // Send the message to Gemini
      var response = await _chatSession!.sendMessage(
        Content.multi(messageParts),
      );

      // Process any function calls in the response
      for (var functionCall in response.functionCalls) {
        if (functionCall.name == 'updateUserPlan') {
          // Parse the plan arguments from the function call
          final planArgs = functionCall.args['plan'] as Map<String, dynamic>;
          final dataLimitMap = planArgs['dataLimit'] as Map<String, dynamic>;

          // Handle different number formats (int or double)
          final monthlyPrice = planArgs['monthlyPrice'];
          final double planMonthlyPrice = monthlyPrice is int
              ? monthlyPrice.toDouble()
              : monthlyPrice as double;

          // Create a Plan object
          final userPlan = Plan(
            name: planArgs['name'] as String,
            monthlyPrice: planMonthlyPrice,
            dataLimit: DataLimit.from(dataLimitMap),
            talkText: planArgs['talkText'] as String,
          );

          // Update the user's plan using the data service
          final updateResult = await _dataService.updateUserPlan(userPlan);
          if (kDebugMode) {
            print('Function Called: _dataService.updateUserPlan(userPlan)');
          }

          // Send the function response back to Gemini
          response = await _chatSession!.sendMessage(
            Content.functionResponse(functionCall.name, {
              'success': updateResult.toString(),
            }),
          );
        }
      }

      // Return the text response or an error message
      return response.text ?? 'Error: No text response.';
    } catch (e) {
      if (kDebugMode) {
        print('Error sending multipart message to Gemini via Firebase: $e');
      }
      return 'Error: Failed to send message. Please check your connection or try again.';
    }
  }

  /// Helper method to parse the location fact response from Gemini
  LocationFact? _parseLocationFactResponse(
    String? factResponseText,
    String cityName,
    String countryName,
  ) {
    if (factResponseText == null || factResponseText.isEmpty) {
      return null;
    }

    try {
      // Clean up the response text by removing markdown formatting
      String cleanedJsonText = factResponseText
          .trim()
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      // Parse the JSON
      dynamic parsedJsonData = json.decode(cleanedJsonText);

      // Handle different response formats
      Map<String, dynamic> factJsonData;
      if (parsedJsonData is List) {
        if (parsedJsonData.isEmpty) return null;
        factJsonData = parsedJsonData[0] as Map<String, dynamic>;
      } else if (parsedJsonData is Map<String, dynamic>) {
        factJsonData = parsedJsonData;
      } else {
        if (kDebugMode) {
          print('Unexpected JSON format: $parsedJsonData');
        }
        return null;
      }

      // Create a LocationFact object from the JSON
      return LocationFact.fromJson(factJsonData);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing location fact JSON: $e');
        print('Raw response: $factResponseText');
      }
      return null;
    }
  }
}
