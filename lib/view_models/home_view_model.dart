import 'dart:async';
import 'dart:convert';
import 'package:fireflut_demo_app/data_services/data_service_interface.dart';
import 'package:fireflut_demo_app/models/location_fact.dart';
import 'package:fireflut_demo_app/models/recommendation.dart';
import 'package:fireflut_demo_app/models/user_account.dart';
import 'package:fireflut_demo_app/services/gemini_service.dart';
import 'package:fireflut_demo_app/services/location_service.dart';
import 'package:fireflut_demo_app/views/chat_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final UserDataService _dataService;
  final GeminiService _geminiService;
  final LocationService _locationService = LocationService();

  late UserAccount userAccount;
  List<Recommendation> recommendations = [];
  bool _isInitialized = false;

  LocationFact? _currentFact;
  bool _isLoadingFact = false;
  String? _locationError;

  HomeViewModel(this._dataService, this._geminiService) {
    recommendations = _getDefaultRecommendations();
  }

  bool get isInitialized => _isInitialized;
  LocationFact? get currentFact => _currentFact;
  bool get isLoadingFact => _isLoadingFact;
  String? get locationError => _locationError;

  Future<void> initializeViewModel() async {
    if (_isInitialized) {
      await _loadRecommendations();
      return;
    }

    try {
      // Load user account first
      userAccount = await _dataService.getUserAccount();
      _isInitialized = true;
      notifyListeners();

      // Load recommendations with location
      await _loadRecommendations();
      await refreshLocationFact();
    } catch (e) {
      if (kDebugMode) print('Error: $e');
      rethrow;
    }
  }

  Future<void> _loadRecommendations() async {
    try {
      final location = await _locationService.getCurrentLocation();
      final city = location?.city ?? "Unknown";
      final geminiResponse = await _geminiService.generateRecommendations(city);

      if (kDebugMode) {
        print('Gemini Response: $geminiResponse');
      }

      final parsedRecommendations = _parseGeminiRecommendations(geminiResponse);
      if (parsedRecommendations.isNotEmpty) {
        recommendations = parsedRecommendations;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading recommendations: $e');
      }
    }
  }

  Future<void> refreshLocationFact() async {
    if (_isLoadingFact) return;

    _isLoadingFact = true;
    _locationError = null;
    notifyListeners();

    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        final fact = await _geminiService.generateLocationFact(
          location.city,
          location.country,
        );

        if (fact != null && fact.fact.isNotEmpty) {
          _currentFact = fact;
          _locationError = null;
        } else {
          _currentFact = LocationFact(
            city: location.city,
            country: location.country,
            fact:
                "This area is covered by our high-speed network with excellent signal strength.",
          );
        }
      } else {
        _locationError = 'Unable to determine location';
        _currentFact = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing location fact: $e');
      }
      _locationError = 'Error loading location fact';
      _currentFact = null;
    } finally {
      _isLoadingFact = false;
      notifyListeners();
    }
  }

  List<Recommendation> _parseGeminiRecommendations(String geminiResponse) {
    try {
      final decodedJson = json.decode(geminiResponse);

      if (decodedJson is Map<String, dynamic> &&
          decodedJson.containsKey('recommendations')) {
        final recommendationsJson =
            decodedJson['recommendations'] as List<dynamic>;

        if (recommendationsJson.isEmpty) {
          return _getDefaultRecommendations();
        }

        return recommendationsJson
            .whereType<Map<String, dynamic>>()
            .map((recommendationJson) => Recommendation(
                  service: (recommendationJson['service'] as String?) ??
                      'General Service',
                  title:
                      (recommendationJson['recommendation_text'] as String?) ??
                          'Personalized Recommendation',
                  description: (recommendationJson['description'] as String?) ??
                      'Check out this personalized recommendation based on your usage.',
                  icon: _getIconForService(
                      recommendationJson['service'] as String? ?? ''),
                ))
            .toList();
      }
      return _getDefaultRecommendations();
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing recommendations: $e');
      }
      return _getDefaultRecommendations();
    }
  }

  IconData _getIconForService(String service) {
    switch (service.toLowerCase()) {
      case 'data':
      case 'internet':
        return Icons.data_usage;
      case 'voice':
      case 'calls':
        return Icons.phone;
      case 'messaging':
      case 'text':
        return Icons.message;
      case 'entertainment':
      case 'streaming':
        return Icons.movie;
      case 'international':
      case 'roaming':
        return Icons.flight;
      default:
        return Icons.lightbulb_outline;
    }
  }

  List<Recommendation> _getDefaultRecommendations() {
    return [
      const Recommendation(
        service: 'Data Plan',
        icon: Icons.data_usage,
        title: 'Optimize Your Data Usage',
        description:
            'Based on your recent usage patterns, you might benefit from our updated data plans.',
      ),
      const Recommendation(
        service: 'Entertainment',
        icon: Icons.movie,
        title: 'Streaming Benefits',
        description:
            'Get more from your plan with included premium streaming services.',
      ),
      const Recommendation(
        service: 'Security',
        icon: Icons.security,
        title: 'Protect Your Device',
        description:
            'Enhance your mobile security with our device protection plans.',
      ),
    ];
  }

  void navigateToChatWithVoice(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          dataService: _dataService,
          geminiService: _geminiService,
          openVoiceDialogOnInit: true,
        ),
      ),
    );
  }
}
