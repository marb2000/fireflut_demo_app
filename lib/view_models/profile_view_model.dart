import 'dart:async';
import 'package:fireflut_demo_app/data_services/data_service_interface.dart';
import 'package:fireflut_demo_app/models/user_account.dart';

class ProfileViewModel {
  final UserDataService _dataService;
  late UserAccount userAccount;

  ProfileViewModel(this._dataService);

  Future<void> initializeViewModel() async {
    userAccount = await _dataService.getUserAccount();
  }
}
