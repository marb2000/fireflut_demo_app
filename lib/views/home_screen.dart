import 'package:fireflut_demo_app/common_dependencies.dart';
import 'package:fireflut_demo_app/data_services/data_service_interface.dart';
import 'package:fireflut_demo_app/models/billing_info.dart';
import 'package:fireflut_demo_app/services/gemini_service.dart';
import 'package:fireflut_demo_app/utils/voice_input_mixin.dart';
import 'package:fireflut_demo_app/view_models/home_view_model.dart';
import 'package:fireflut_demo_app/views/billing_screen.dart';
import 'package:fireflut_demo_app/views/chat_screen.dart';
import 'package:fireflut_demo_app/views/settings_screen.dart';
import 'package:fireflut_demo_app/views/usage_screen.dart';
import 'package:fireflut_demo_app/widgets/arc_graph.dart';
import 'package:fireflut_demo_app/widgets/bulb_icon.dart';
import 'package:fireflut_demo_app/widgets/cta_card.dart';
import 'package:intl/intl.dart';

import '../models/user_account.dart';
import '../widgets/balance_summary_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/location_fact_card.dart';

class HomeScreen extends StatefulWidget {
  final UserDataService dataService;
  final GeminiService geminiService;
  const HomeScreen({super.key, required this.dataService, required this.geminiService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with VoiceInputMixin<HomeScreen> {
  late HomeViewModel _viewModel;
  final int _selectedIndex = 0;

  bool showingLocationFact = false;

  final ScrollController _scrollController = ScrollController();

  bool recommendationsInView = false;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(widget.dataService, widget.geminiService);
    _initializeViewModel();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    final threshold = position.maxScrollExtent * 0.2;
    final minThreshold = 50; // if below this threshold, always show recommendations
    if ((threshold < minThreshold || position.pixels >= threshold) && !recommendationsInView) {
      setState(() {
        recommendationsInView = true;
      });
    } else if (threshold >= minThreshold && position.pixels < threshold && recommendationsInView) {
      setState(() {
        recommendationsInView = false;
      });
    }
  }

  @override
  GeminiService get geminiService => widget.geminiService;

  @override
  UserDataService get dataService => widget.dataService;

  Future<void> _initializeViewModel() async {
    try {
      await _viewModel.initializeViewModel();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing: $e')),
        );
      }
    }
  }

  String getTimeBasedGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour < 12) {
      return "Morning,";
    } else if (hour < 17) {
      return 'Afternoon,';
    } else {
      return 'Evening,';
    }
  }

  String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    } else {
      return '${text.substring(0, maxLength)}...';
    }
  }

  @override
  void onVoiceInputResponse(String response) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          dataService: widget.dataService,
          geminiService: widget.geminiService,
          initialUserMessage: response,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_viewModel.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    TextTheme textTheme = Theme.of(context).textTheme;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
    });

    final currentFact = _viewModel.currentFact;

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // Evenly space the children
                  children: [
                    Image.asset(
                      'assets/provider-logo.png',
                      height: 40.0,
                    ),
                    if (currentFact != null)
                      Consumer<HomeViewModel>(
                        builder: (context, viewModel, child) => OutlinedButton(
                          onPressed: () {
                            if (_scrollController.offset == 0 || !showingLocationFact) {
                              setState(() {
                                showingLocationFact = !showingLocationFact;
                              });
                            }
                            // Scroll to top after state update (but only if not already at the top)
                            if (_scrollController.offset > 0) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              });
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: $styles.colors.foreground.withValues(alpha: showingLocationFact ? 1 : 0.1)),
                            padding: const EdgeInsets.only(
                              top: 6.0,
                              bottom: 6.0,
                              left: 20.0,
                              right: 12.0,
                            ),
                          ),
                          child: Row(spacing: $styles.insets.xs, children: [
                            Text(truncateText(currentFact.city, 20),
                                style: textTheme.bodyMedium?.copyWith(color: $styles.colors.textPrimary)),
                            ColorFiltered(
                              colorFilter: ColorFilter.mode($styles.colors.secondary, BlendMode.srcIn),
                              child: Image.asset(
                                'assets/ai.png',
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ]),
                        ),
                      )
                          .animate()
                          .moveX(begin: 100, duration: 500.ms, curve: Curves.easeOut)
                          .fadeIn(duration: 600.ms)
                          .shimmer(delay: 800.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => _viewModel.initializeViewModel(),
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: $styles.insets.md,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeInOutQuad,
                    switchOutCurve: Curves.easeInOutQuad,
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axisAlignment: -1.0,
                          child: child,
                        ),
                      );
                    },
                    child: showingLocationFact
                        ? Consumer<HomeViewModel>(
                            builder: (context, viewModel, child) => LocationFactCard(
                                  key: ValueKey('LocationFactCard'),
                                  fact: currentFact,
                                  isLoading: viewModel.isLoadingFact,
                                  error: viewModel.locationError,
                                  onRefresh: viewModel.refreshLocationFact,
                                ))
                        : SizedBox.shrink(
                            key: ValueKey('SizedBoxShrink'),
                          ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: $styles.insets.xs,
                        children: [
                          Text(
                            getTimeBasedGreeting(),
                            style: textTheme.headlineLarge,
                          ),
                          Text(
                            _viewModel.userAccount.firstName,
                            style: textTheme.headlineLarge
                                ?.copyWith(fontWeight: FontWeight.w600, color: $styles.colors.secondary),
                          ),
                        ],
                      ),
                      Text(
                        _viewModel.userAccount.phoneNumber,
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  )
                      .animate()
                      .moveX(begin: 50, duration: 600.ms, curve: Curves.easeOut)
                      .fadeIn(duration: 600.ms)
                      .shimmer(duration: 1.seconds, delay: 800.ms),
                  _buildUsageSummaryBanner(context, _viewModel.userAccount),
                  CtaCard(
                      dataService: dataService,
                      geminiService: geminiService,
                      title: 'Customize Your Plan with AI',
                      subtitle: 'Your perfect mobile plan is a chat away'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recommendations for you',
                      ),
                      Transform.translate(
                        offset: const Offset(0, -4),
                        child: Image.asset(
                          'assets/gemini.png',
                          width: 61,
                        ),
                      ),
                    ],
                  ),
                  Consumer<HomeViewModel>(
                    builder: (context, viewModel, child) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: viewModel.recommendations.length,
                        itemBuilder: (context, index) {
                          final recommendation = viewModel.recommendations[index];
                          return GestureDetector(
                            onTap: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    dataService: widget.dataService,
                                    geminiService: widget.geminiService,
                                    initialUserMessage:
                                        'Help me with this recommendation: ${recommendation.title} ${recommendation.description}',
                                  ),
                                ),
                              )
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: $styles.colors.border,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: $styles.insets.xs,
                                children: [
                                  recommendation.icon == Icons.lightbulb_outline
                                      ? BulbIcon()
                                      : Icon(
                                          recommendation.icon,
                                          color: $styles.colors.secondary,
                                        ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recommendation.title,
                                          style: textTheme.bodyMedium,
                                        ),
                                        Text(
                                          recommendation.description,
                                          style: textTheme.bodySmall?.copyWith(color: $styles.colors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              )
                                  .animate(target: recommendationsInView ? 1 : 0)
                                  .slide(
                                    delay: (index * 160).ms,
                                    begin: const Offset(-0.7, 0),
                                    duration: 200.ms,
                                    curve: Curves.easeOut,
                                  )
                                  .fadeIn(duration: 300.ms, curve: Curves.easeOut),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  _buildBillSummaryBanner(context, _viewModel.userAccount.billingInfo),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavBar(selectedIndex: _selectedIndex, onItemTapped: _onItemTapped),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      // _selectedIndex = index; TD: commenting out for now since this nav bar is always on Home
      if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              dataService: widget.dataService,
              geminiService: widget.geminiService,
            ),
          ),
        );
        /*
      } else if (index == 3) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyStuffScreen(
              viewModel: MyStuffViewModel(
                dataService: widget.dataService,
                geminiService: widget.geminiService,
              ),
            ),
          ),
        );
      */
      } else if (index == 4) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsScreen(
              dataService: widget.dataService,
              geminiService: widget.geminiService,
            ),
          ),
        );
      }
    });
  }

  Widget _buildBillSummaryBanner(BuildContext context, BillingInfo billingInfo) {
    return BalanceSummaryCard(
      billingInfo: billingInfo,
      decorations: [
        BoxDecoration(
            gradient: LinearGradient(
          colors: [$styles.colors.primary, $styles.colors.background.withAlpha(0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ))
      ],
      currentBalanceTextStyle: TextStyle(color: $styles.colors.accent2),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  BillingScreen(dataService: widget.dataService, geminiService: widget.geminiService))),
    );
  }

  Widget _buildUsageSummaryBanner(BuildContext context, UserAccount userAccount) {
    TextTheme textTheme = Theme.of(context).textTheme;

    final dataUsage = userAccount.dataUsage;
    double? dataLimitNumber = userAccount.currentPlan.dataLimit.numberValue;

    const maxGraphWidth = 450.0;

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UsageScreen(
                    dataService: widget.dataService,
                    geminiService: widget.geminiService,
                  ))),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxGraphWidth),
            child: ClipRect(
                child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.6,
              child: AspectRatio(
                aspectRatio: 1,
                child: ArcGraph(
                  percentage: 1,
                  strokeWidth: 30,
                  color: $styles.colors.foreground.withValues(alpha: 0.1),
                ),
              ),
            )),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxGraphWidth),
            child: ClipRect(
                child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.6,
              child: AspectRatio(
                aspectRatio: 1,
                child: Animate().custom(
                    duration: 2000.ms,
                    curve: Curves.bounceOut,
                    begin: 0.001,
                    end: dataLimitNumber == null ? 0.001 : dataUsage.totalDataUsedGB / dataLimitNumber,
                    builder: (context, value, child) {
                      return ArcGraph(
                        percentage: value,
                        strokeWidth: 30,
                        gradient: SweepGradient(
                          colors: [
                            $styles.colors.accent1,
                            $styles.colors.primary,
                            $styles.colors.secondary,
                            $styles.colors.foreground,
                          ],
                          stops: [0.5, 0.63, 0.75, 1],
                        ),
                        animating: true,
                      );
                    }),
              ),
            )),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: $styles.insets.xxs,
                children: [
                  Animate().custom(
                      duration: 2000.ms,
                      curve: Curves.easeOut,
                      begin: dataLimitNumber,
                      end: userAccount.dataLeftGB,
                      builder: (context, value, child) {
                        return Text(
                            dataLimitNumber != null && userAccount.dataLeftGB != null ? value.toStringAsFixed(2) : '∞',
                            style: textTheme.headlineLarge?.copyWith(fontSize: 64, fontWeight: FontWeight.w600));
                      }),
                  Text('GB', style: textTheme.headlineLarge?.copyWith(fontSize: 24)),
                ],
              ),
              Text('High speed data left', style: TextStyle(color: $styles.colors.textSecondary)),
              Text('Reloads on ${DateFormat('MMMM d').format(userAccount.billingInfo.dueDate)}'),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxGraphWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.mail),
                        Text('${dataUsage.messagesSent} texts', style: TextStyle(color: $styles.colors.textSecondary)),
                      ],
                    ),
                    Column(
                      children: [
                        const Icon(Icons.call),
                        Text('${dataUsage.callsDurationMinutes} mins',
                            style: TextStyle(color: $styles.colors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
