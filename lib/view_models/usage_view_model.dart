import 'dart:async';
import 'package:fireflut_demo_app/data_services/data_service_interface.dart';
import 'package:fireflut_demo_app/models/data_usage.dart';
import 'package:fireflut_demo_app/models/user_account.dart';

class UsageViewModel {
  final UserDataService _dataService;
  late DataUsage dataUsage;
  late UserAccount userAccount;

  UsageViewModel(this._dataService);

  Future<void> initializeViewModel() async {
    userAccount = await _dataService.getUserAccount();
    dataUsage = userAccount.dataUsage;
  }
}
