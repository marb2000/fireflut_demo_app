import 'package:fireflut_demo_app/data_services/data_service_interface.dart';
import 'package:fireflut_demo_app/services/gemini_service.dart';
import 'package:fireflut_demo_app/views/billing_screen.dart';
import 'package:fireflut_demo_app/views/login_screen.dart';
import 'package:fireflut_demo_app/views/profile_screen.dart';
import '../common_dependencies.dart';

class SettingsScreen extends StatelessWidget {
  final UserDataService dataService;
  final GeminiService geminiService;
  const SettingsScreen(
      {super.key, required this.dataService, required this.geminiService});

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginScreen(
              dataService: dataService, geminiService: geminiService)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: $styles.colors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: $styles.insets.sm),
        children: [
          AppCard.withBackgroundColor(
            backgroundColor: $styles.colors.border,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Profile'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                                dataService: dataService,
                                geminiService: geminiService,
                              )),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text('Billing & Payments'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BillingScreen(
                              dataService: dataService,
                              geminiService: geminiService)),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Security'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to security settings
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.lock_person_outlined),
                  title: const Text('Permission & controls'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to permission & controls settings
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.devices_other),
                  title: const Text('Device settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to device settings
                  },
                  shape: const Border(
                    bottom: BorderSide.none,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          AppCard.withBackgroundColor(
            backgroundColor: $styles.colors.border,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to notification settings
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: const Text('Location access'),
                  trailing: const Text('Settings',
                      style: TextStyle(color: Color(0xFF607D8B))),
                  onTap: () {
                    // Navigate to location access settings
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.contacts_outlined),
                  title: const Text('Contacts access'),
                  trailing: const Text('Update',
                      style: TextStyle(color: Color(0xFF607D8B))),
                  onTap: () {
                    // Navigate to contacts access settings
                  },
                  shape: const Border(
                    bottom: BorderSide.none,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          AppCard.withBackgroundColor(
            backgroundColor: $styles.colors.border,
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () {
                _logout(context);
              },
              shape: const Border(
                bottom: BorderSide.none,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text('App Version 10.4.3 (1615875145)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.0)),
            ),
          ),
        ],
      ),
    );
  }
}
