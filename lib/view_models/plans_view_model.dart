import 'dart:async';
import 'package:fireflut_demo_app/data_services/data_service_interface.dart';
import 'package:fireflut_demo_app/data_services/mock_data_service.dart';
import 'package:fireflut_demo_app/models/plan.dart';

class PlansViewModel {
  final UserDataService _dataService = MockDataService();
  late List<Plan> availablePlans;
  late Plan currentPlan;

  PlansViewModel();

  Future<void> initializeViewModel() async {
    currentPlan =
        await _dataService.getUserAccount().then((user) => user.currentPlan);
  }
}
