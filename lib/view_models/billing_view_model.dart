import 'dart:async';
import 'package:fireflut_demo_app/data_services/data_service_interface.dart';
import 'package:fireflut_demo_app/models/billing_info.dart';
import 'package:fireflut_demo_app/models/user_account.dart';

class BillingViewModel {
  final UserDataService _dataService;
  late BillingInfo billingInfo;
  late UserAccount userAccount;

  BillingViewModel(this._dataService);

  Future<void> initializeViewModel() async {
    userAccount = await _dataService.getUserAccount();
    billingInfo = userAccount.billingInfo;
  }
}
