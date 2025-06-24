import 'package:flutter/material.dart';
import '../data_services/data_service_interface.dart';
import '../services/gemini_service.dart';
import '../data_services/mock_data_service.dart';
import '../views/home_screen.dart';

class LoginViewModel {
  final UserDataService dataService;
  final GeminiService geminiService;

  LoginViewModel({required this.dataService, required this.geminiService});

  Future<bool> login(BuildContext context, String email, String password,
      GlobalKey<FormState> formKey) async {
    if (formKey.currentState!.validate()) {
      final currentContext = context;
      final loginData = await dataService.getLoginData();
      final testEmail = loginData['email'];
      final testPassword = loginData['password'];

      if (email == testEmail && password == testPassword) {
        if (currentContext.mounted) {
          Navigator.pushReplacement(
            currentContext,
            MaterialPageRoute(
                builder: (context) => HomeScreen(
                    dataService: dataService, geminiService: geminiService)),
          );
        }
        return true;
      } else {
        if (currentContext.mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(
                content: Text('Login failed. Please check your credentials.')),
          );
        }
        return false;
      }
    }
    return false;
  }

  bool isDataInitialized() {
    return (dataService as MockDataService).isDataInitialized();
  }
}
