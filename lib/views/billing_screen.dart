import 'dart:async';
import 'package:fireflut_demo_app/common_dependencies.dart';
import 'package:fireflut_demo_app/data_services/data_service_interface.dart';
import 'package:fireflut_demo_app/models/monthly_usage_history_item.dart';
import 'package:fireflut_demo_app/view_models/billing_view_model.dart';
import 'package:fireflut_demo_app/widgets/cta_card.dart';
import 'package:intl/intl.dart';

import '../services/gemini_service.dart';
import '../widgets/balance_summary_card.dart';

class BillingScreen extends StatefulWidget {
  final UserDataService dataService;
  final GeminiService geminiService;

  const BillingScreen({super.key, required this.dataService, required this.geminiService});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late Future<BillingViewModel> _billingViewModelFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _billingViewModelFuture = _initializeBillingViewModel();
  }

  Future<BillingViewModel> _initializeBillingViewModel() async {
    final viewModel = BillingViewModel(widget.dataService);
    await viewModel.initializeViewModel();
    return viewModel;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: $styles.colors.background,
      appBar: AppBar(
        title: const Text('Billing & Payments'),
        bottom: TabBar(
          padding: EdgeInsets.symmetric(horizontal: $styles.insets.sm),
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'FAQ'),
          ],
        ),
      ),
      body: FutureBuilder<BillingViewModel>(
          future: _billingViewModelFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final viewModel = snapshot.data!;
              return TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(
                    child: _buildBillingOverviewTab(context, viewModel),
                  ),
                  SingleChildScrollView(
                    child: _buildBillingFaqTab(context),
                  ),
                ],
              );
            }
          }),
    );
  }

  Widget _buildBillingOverviewTab(BuildContext context, BillingViewModel viewModel) {
    final billingInfo = viewModel.billingInfo;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: $styles.insets.sm,
        children: [
          BalanceSummaryCard(
            billingInfo: billingInfo,
            decorations: [
              BoxDecoration(
                color: $styles.colors.foreground.withValues(alpha: 0.1),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.receipt_long,
              color: $styles.colors.textSecondary,
              size: $styles.insets.md,
            ),
            label: Text(
              'Download Current Bill (PDF)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: $styles.colors.textSecondary),
            ),
          ),
          _buildHistoryTab(context, viewModel.userAccount.monthlyUsageHistory),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, List<MonthlyUsageHistoryItem> monthlyUsageHistory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          color: $styles.colors.border,
        ),
        Text(
          'History',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          itemCount: monthlyUsageHistory.length,
          itemBuilder: (context, index) {
            final usage = monthlyUsageHistory[index];
            return Card(
              color: Colors.transparent,
              child: ExpansionTile(
                leading: Icon(
                  Icons.history,
                  color: $styles.colors.textSecondary,
                ),
                title: Text(DateFormat('MMM yyyy').format(usage.month)),
                children: <Widget>[
                  ListTile(
                      title: Text('Data Consumed'), trailing: Text('${usage.dataConsumedGB.toStringAsFixed(2)} GB')),
                  ListTile(title: Text('Calls Count'), trailing: Text('${usage.callsCount}')),
                  ListTile(title: Text('Messages Count'), trailing: Text('${usage.messagesCount}')),
                  ListTile(title: Text('In-flight Services'), trailing: Text('${usage.inFlightServicesCount}')),
                  ListTile(title: Text('Streaming Services'), trailing: Text('${usage.streamingServicesCount}')),
                  ListTile(title: Text('Data Roaming'), trailing: Text('${usage.dataRoamingGB.toStringAsFixed(2)} GB')),
                  ListTile(title: Text('Calls Roaming'), trailing: Text('${usage.callsRoamingCount}')),
                  ListTile(title: Text('Messages Roaming'), trailing: Text('${usage.messagesRoamingCount}')),
                  ListTile(
                    title: const Text('Locations:'),
                    subtitle: Text(usage.locations.join(', ')),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBillingFaqTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Popular billing topics', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ListTile(
            title: const Text('Equipment promotions and credits'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Partial charges (prorated)'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Payment arrangements'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          const SizedBox(height: 20),
          CtaCard(
              dataService: widget.dataService,
              geminiService: widget.geminiService,
              title: 'Can\'t find what you\'re looking for?',
              subtitle: 'Chat with us')
        ],
      ),
    );
  }
}
