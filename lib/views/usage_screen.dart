import 'dart:async';
import 'package:fireflut_demo_app/data_services/data_service_interface.dart';
import 'package:fireflut_demo_app/models/data_usage.dart';
import 'package:fireflut_demo_app/models/user_account.dart';
import 'package:fireflut_demo_app/view_models/usage_view_model.dart';
import 'package:intl/intl.dart';

import '../common_dependencies.dart';
import '../services/gemini_service.dart';
import '../widgets/bulb_icon.dart';
import 'chat_screen.dart';

class UsageScreen extends StatefulWidget {
  final UserDataService dataService;
  final GeminiService geminiService;
  const UsageScreen({super.key, required this.dataService, required this.geminiService});

  @override
  State<UsageScreen> createState() => _UsageScreenState();
}

class _UsageScreenState extends State<UsageScreen> {
  late Future<UsageViewModel> _usageViewModelFuture;

  @override
  void initState() {
    super.initState();
    _usageViewModelFuture = _initializeUsageViewModel();
  }

  Future<UsageViewModel> _initializeUsageViewModel() async {
    final viewModel = UsageViewModel(widget.dataService);
    await viewModel.initializeViewModel();
    return viewModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: $styles.colors.background,
      appBar: AppBar(
        title: const Text('Device Usage Overview'),
      ),
      body: FutureBuilder<UsageViewModel>(
        future: _usageViewModelFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final viewModel = snapshot.data!;
            final dataUsage = viewModel.dataUsage;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 24,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDeviceOverviewCard(context, viewModel.userAccount),
                    AppCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                dataService: widget.dataService,
                                geminiService: widget.geminiService,
                                initialUserMessage:
                                    'I need more data. Can you give me options for hot spots, international passes, and other services?',
                              ),
                            ),
                          );
                        },
                        decorations: [
                          BoxDecoration(
                              gradient: LinearGradient(
                            colors: [$styles.colors.primary, $styles.colors.background.withAlpha(0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomCenter,
                          ))
                        ],
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            BulbIcon(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Need more data?'),
                                  Text(
                                    'Check out the options for hot spots, international passes, and other services.',
                                    softWrap: true,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: $styles.colors.textSecondary),
                                  )
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 24,
                            ),
                          ],
                        )),
                    _buildDataUsageCard(context, dataUsage),
                    _buildUsageDetailsCard(context, dataUsage),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDeviceOverviewCard(BuildContext context, UserAccount userAccount) {
    return AppCard.withBackgroundColor(
      backgroundColor: $styles.colors.foreground.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(userAccount.name, style: Theme.of(context).textTheme.titleMedium),
              Text(userAccount.phoneNumber, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.phone_android, size: 24, color: Theme.of(context).colorScheme.secondary),
              Text(userAccount.currentPlan.name),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataUsageCard(BuildContext context, DataUsage dataUsage) {
    return AppCard.withBackgroundColor(
      backgroundColor: $styles.colors.foreground.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Data usage', style: Theme.of(context).textTheme.titleMedium),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            ],
          ),
          const Text('${25} days left in billing period',
              textAlign: TextAlign.end, style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Maximum usage'),
              Text(DateFormat('MMM dd').format(dataUsage.maxUsageDate),
                  textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Minimum usage'),
              Text(DateFormat('MMM dd').format(dataUsage.minUsageDate),
                  textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageDetailsCard(BuildContext context, DataUsage dataUsage) {
    return AppCard.withBackgroundColor(
      backgroundColor: $styles.colors.foreground.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('Domestic data'),
            subtitle: Text('0.43GB / Unlimited\nHigh-speed data'),
            trailing: Text('Unlimited'),
          ),
          ListTile(
            title: const Text('Calls (Total duration)'),
            trailing: Text('${dataUsage.callsDurationMinutes} minutes'),
          ),
          ListTile(
            title: const Text('Messages'),
            trailing: Text('${dataUsage.messagesSent} messages'),
          ),
          ListTile(
            title: Text('Usage outside of selected billing period', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('In-flight Wi-Fi\n13 used / Unlimited\nFull Flight sessions'),
            trailing: Text('Unlimited'),
          ),
        ],
      ),
    );
  }
}
