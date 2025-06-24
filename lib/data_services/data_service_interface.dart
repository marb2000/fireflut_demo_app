import 'dart:async';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:fireflut_demo_app/models/plan.dart';
import 'package:fireflut_demo_app/models/user_account.dart';

abstract class UserDataService {
  Future<void> initialize();
  Future<UserAccount> getUserAccount();
  Future<Map<String, String>> getLoginData();
  Future<String> getUserDataAsJson();
  Future<bool> updateUserPlan(Plan newPlan);
  FunctionDeclaration updateUserPlanFuntionDeclaration();
}
