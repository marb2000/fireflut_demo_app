import 'dart:async';
import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/user_account.dart';
import '../models/plan.dart';
import '../models/billing_info.dart';
import '../models/bill_history_item.dart';
import '../models/data_usage.dart';
import '../models/monthly_usage_history_item.dart';
import 'data_service_interface.dart';

class MockDataService implements UserDataService {
  // Private fields
  Map<String, dynamic>? _mockUserData;
  final Completer<void> _initializationCompleter = Completer<void>();
  bool _isInitialized = false;
  UserAccount? _userAccount;

  // Constants
  static const String _dataPath = 'assets/usage_data.json';

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadMockUserData();
      _isInitialized = true;
      _initializationCompleter.complete();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing MockDataService: $e');
      }
      _initializationCompleter.completeError(e);
      rethrow;
    }
  }

  /// Loads mock user data from assets
  Future<Map<String, dynamic>> _loadMockUserData() async {
    try {
      final String jsonString = await rootBundle.loadString(_dataPath);
      _mockUserData = json.decode(jsonString);
      return _mockUserData!;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading mock user data: $e');
      }
      rethrow;
    }
  }

  /// Ensures the service is properly initialized before use
  void _ensureInitialized() {
    if (!_isInitialized || _mockUserData == null) {
      throw Exception("Mock data not initialized. Call initialize() first.");
    }
  }

  /// Checks if data is initialized
  bool isDataInitialized() => _isInitialized;

  @override
  Future<String> getUserDataAsJson() async {
    await _waitForInitialization();
    return jsonEncode(_mockUserData);
  }

  @override
  Future<UserAccount> getUserAccount() async {
    await _waitForInitialization();

    // Return cached user account if available
    if (_userAccount != null) {
      return _userAccount!;
    }

    // Parse user account from mock data
    _userAccount = _createUserAccountFromMockData();
    return _userAccount!;
  }

  /// Creates a UserAccount object from the mock data
  UserAccount _createUserAccountFromMockData() {
    final userData = _mockUserData!;
    final user = userData['user'];
    final currentPlan = userData['currentPlan'];
    final billingInfo = userData['billingInfo'];
    final dataUsage = userData['dataUsage'];

    return UserAccount(
      firstName: user['firstName'] as String,
      lastName: user['lastName'] as String,
      phoneNumber: user['phoneNumber'] as String,
      email: user['email'] as String,
      currentPlan: _createPlanFromData(currentPlan),
      billingInfo: _createBillingInfoFromData(billingInfo),
      dataUsage: _createDataUsageFromData(dataUsage),
      monthlyUsageHistory: _createMonthlyUsageHistoryFromData(userData),
    );
  }

  /// Creates a Plan object from map data
  Plan _createPlanFromData(Map<String, dynamic> planData) {
    return Plan(
      name: planData['name'] as String,
      monthlyPrice: planData['monthlyPrice'] as double,
      dataLimit: DataLimit.from(planData['dataLimit']),
      talkText: planData['talkText'] as String,
    );
  }

  /// Creates a BillingInfo object from map data
  BillingInfo _createBillingInfoFromData(Map<String, dynamic> billingData) {
    return BillingInfo(
      currentBalance: billingData['currentBalance'] as double,
      dueDate: DateTime.parse(billingData['dueDate'] as String),
      autoPayEnabled: billingData['autoPayEnabled'] as bool,
      paymentMethod: billingData['paymentMethod'] as String,
      billHistory:
          (billingData['billHistory'] as List<dynamic>)
              .map(
                (item) => BillHistoryItem(
                  date: DateTime.parse(item['date'] as String),
                  amount: item['amount'] as double,
                ),
              )
              .toList(),
    );
  }

  /// Creates a DataUsage object from map data
  DataUsage _createDataUsageFromData(Map<String, dynamic> usageData) {
    return DataUsage(
      totalDataUsedGB: usageData['totalDataUsedGB'] as double,
      maxUsage: usageData['maxUsage'] as double,
      maxUsageDate: DateTime.parse(usageData['maxUsageDate'] as String),
      minUsage: usageData['minUsage'] as double,
      minUsageDate: DateTime.parse(usageData['minUsageDate'] as String),
      callsDurationMinutes: usageData['callsDurationMinutes'] as double,
      messagesSent: usageData['messagesSent'] as int,
    );
  }

  /// Creates monthly usage history items from user data
  List<MonthlyUsageHistoryItem> _createMonthlyUsageHistoryFromData(
    Map<String, dynamic> userData,
  ) {
    return (userData['monthlyUsageHistory'] as List<dynamic>)
        .map(_parseMonthlyUsageHistoryItem)
        .toList();
  }

  /// Parses a single monthly usage history item
  MonthlyUsageHistoryItem _parseMonthlyUsageHistoryItem(dynamic item) {
    return MonthlyUsageHistoryItem(
      month: DateTime.parse(item['month'] as String),
      callsCount: item['callsCount'] as int,
      messagesCount: item['messagesCount'] as int,
      inFlightServicesCount: item['inFlightServicesCount'] as int,
      dataConsumedGB: item['dataConsumedGB'] as double,
      streamingServicesCount: item['streamingServicesCount'] as int,
      dataRoamingGB: item['dataRoamingGB'] as double,
      callsRoamingCount: item['callsRoamingCount'] as int,
      messagesRoamingCount: item['messagesRoamingCount'] as int,
      locations: List<String>.from(item['locations']),
    );
  }

  @override
  Future<Map<String, String>> getLoginData() async {
    await _waitForInitialization();

    final user = _mockUserData!['user'];
    return {
      'email': user['email'] as String,
      'password': user['password'] as String,
    };
  }

  @override
  Future<bool> updateUserPlan(Plan newPlan) async {
    await _waitForInitialization();

    try {
      // Ensure we have the user account loaded
      _userAccount ??= await getUserAccount();

      // Update the plan in the user account object
      _userAccount!.currentPlan = newPlan;

      // Update the plan in the mock data for persistence
      _updatePlanInMockData(newPlan);

      if (kDebugMode) {
        print('Plan successfully updated to: ${newPlan.name}');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user plan: $e');
      }
      return false;
    }
  }

  /// Updates the plan data in the mock user data
  void _updatePlanInMockData(Plan newPlan) {
    if (_mockUserData != null && _mockUserData!.containsKey('currentPlan')) {
      _mockUserData!['currentPlan'] = {
        'name': newPlan.name,
        'monthlyPrice': newPlan.monthlyPrice,
        'dataLimit': _getDataLimitValue(newPlan.dataLimit),
        'talkText': newPlan.talkText,
      };
    }
  }

  /// Gets the appropriate value from a DataLimit object
  dynamic _getDataLimitValue(DataLimit dataLimit) {
    return dataLimit.numberValue ?? dataLimit.stringValue ?? "Unlimited";
  }

  /// A helper method to wait for initialization
  Future<void> _waitForInitialization() async {
    await _initializationCompleter.future;
    _ensureInitialized();
  }

  @override
  FunctionDeclaration updateUserPlanFuntionDeclaration() {
    return FunctionDeclaration(
      'updateUserPlan',
      'Update the user\'s current plan to a new plan',
      parameters: {
        'plan': Schema.object(
          properties: {
            'name': Schema.string(description: 'The name of the plan'),
            'monthlyPrice': Schema.number(
              description: 'The monthly price of the plan in dollars',
            ),
            'dataLimit': Schema.object(
              properties: {
                'type': Schema.string(
                  description: 'The type of data limit value',
                ),
                'value': Schema.string(
                  description:
                      'The value of the data limit as a string, even if it\'s a number',
                ),
              },
              description: 'The data limit of the plan',
            ),
            'talkText': Schema.string(
              description: 'Description of talk and text benefits',
            ),
          },
        ),
      },
    );
  }
}
