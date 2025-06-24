import 'dart:async';
import 'package:fireflut_demo_app/data_services/mock_data_service.dart';
import 'package:fireflut_demo_app/services/gemini_service.dart';
import 'package:fireflut_demo_app/views/login_screen.dart';

import 'common_dependencies.dart';

class FireflutApp extends StatefulWidget {
  final GeminiService geminiService;
  final MockDataService dataService;

  const FireflutApp(
      {super.key, required this.geminiService, required this.dataService});

  @override
  FireflutAppState createState() => FireflutAppState();
}

class FireflutAppState extends State<FireflutApp> {
  late final MockDataService _dataService;
  late final GeminiService _geminiService;
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _geminiService = widget.geminiService;
    _dataService = widget.dataService;
    _initializationFuture = _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _dataService.initialize();
      await _geminiService.initializeChat();
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    $styles = AppStyle(screenSize: MediaQuery.of(context).size);
    return FutureBuilder<void>(
      future: _initializationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: $styles.colors.toThemeData(),
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: $styles.colors.toThemeData(),
            home: Scaffold(
              body: Center(
                  child: Text('Error initializing app: ${snapshot.error}')),
            ),
          );
        } else {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: appName,
            theme: $styles.colors.toThemeData(),
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            $styles.colors.primary.withValues(alpha: 0.75),
                            $styles.colors.background,
                          ],
                          stops: [0, 1],
                          center: Alignment(-0.4, -0.4),
                          radius: 0.75,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(duration: 1.seconds),
                  child!,
                ],
              );
            },
            home: LoginScreen(
                dataService: _dataService, geminiService: _geminiService),
          );
        }
      },
    );
  }
}
