import 'dart:async';
import 'package:fireflut_demo_app/common_dependencies.dart';
import 'package:fireflut_demo_app/data_services/data_service_interface.dart';
import 'package:fireflut_demo_app/services/gemini_service.dart';
import 'package:fireflut_demo_app/view_models/profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  final UserDataService dataService;
  final GeminiService geminiService;

  const ProfileScreen(
      {super.key, required this.dataService, required this.geminiService});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileViewModel> _viewModelFuture;

  @override
  void initState() {
    super.initState();
    _viewModelFuture = _initializeViewModel();
  }

  Future<ProfileViewModel> _initializeViewModel() async {
    final viewModel = ProfileViewModel(widget.dataService);
    await viewModel.initializeViewModel();
    return viewModel;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: $styles.colors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<ProfileViewModel>(
        future: _viewModelFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final viewModel = snapshot.data!;
            final userAccount = viewModel.userAccount;

            return ListView(
              padding: EdgeInsets.symmetric(horizontal: $styles.insets.sm),
              children: [
                AppCard.withBackgroundColor(
                    backgroundColor: $styles.colors.border,
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Name'),
                          subtitle: Text(userAccount.name),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to name edit
                          },
                        ),
                        ListTile(
                          title: const Text('Email address'),
                          subtitle: Text(userAccount.email),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to email edit
                          },
                        ),
                        ListTile(
                          title: const Text('Phone number'),
                          subtitle: Text(userAccount.phoneNumber),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to phone number edit
                          },
                          shape: const Border(
                            bottom: BorderSide.none,
                          ),
                        )
                      ],
                    )),
                const Divider(),
                AppCard.withBackgroundColor(
                  backgroundColor: $styles.colors.border,
                  child: ListTile(
                    title: const Text('Discounts'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to discounts screen
                    },
                    shape: const Border(
                      bottom: BorderSide.none,
                    ),
                  ),
                ),
                const Divider(),
                AppCard.withBackgroundColor(
                  backgroundColor: $styles.colors.border,
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Usage address (for this device)'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to usage address edit
                        },
                      ),
                      ListTile(
                        title: const Text('E911 Address (for this device)'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to E911 address edit
                        },
                      ),
                      ListTile(
                        title: const Text('Billing address'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Navigate to billing address edit
                        },
                        shape: const Border(
                          bottom: BorderSide.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
