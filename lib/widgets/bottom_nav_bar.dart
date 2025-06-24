import '../common_dependencies.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required int selectedIndex,
    required onItemTapped,
  })  : _selectedIndex = selectedIndex,
        _onItemTapped = onItemTapped;

  final int _selectedIndex;
  final void Function(int index) _onItemTapped;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      destinations: <NavigationDestination>[
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.shopping_bag), label: 'Shop'),
        NavigationDestination(
          icon: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [$styles.colors.primary, $styles.colors.background.withAlpha(0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/ai.png',
                width: 24,
                height: 24,
              ),
            ),
          ),
          label: 'Chat',
        ),
        NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Billing'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
