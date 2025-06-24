//Path: lib/views/login_screen.dart

import '../common_dependencies.dart';
import '../data_services/data_service_interface.dart';
import '../services/gemini_service.dart';
import '../view_models/login_view_model.dart';

class LoginScreen extends StatefulWidget {
  final UserDataService dataService;
  final GeminiService geminiService;

  const LoginScreen({super.key, required this.dataService, required this.geminiService}); // Update constructor

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'miguel@decervantes.com');
  final _passwordController = TextEditingController(text: '1234');
  bool _isPasswordVisible = false;

  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel(dataService: widget.dataService, geminiService: widget.geminiService);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // Use the ViewModel to handle the login logic
    await _viewModel.login(context, email, password, _formKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 600.0,
                ),
                child: Padding(
                  padding: EdgeInsets.all($styles.insets.sm),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Image.asset(
                            'assets/provider-logo.png',
                            height: 100,
                          ),
                          const SizedBox(height: 48),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter Email',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+.[a-zA-Z]+").hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Enter Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText: !_isPasswordVisible,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              shape: RoundedRectangleBorder(borderRadius: $styles.corners.medRadius),
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [$styles.colors.accent1, $styles.colors.secondary],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  transform: GradientRotation(45 * pi / 180),
                                ),
                                borderRadius: $styles.corners.medRadius,
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                child: Text(
                                  'LOGIN',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => _showForgotPasswordDialog(context, isForgotPassword: false),
                                child: Text('Forgot User?', style: Theme.of(context).textTheme.bodyMedium),
                              ),
                              TextButton(
                                onPressed: () => _showForgotPasswordDialog(context, isForgotPassword: true),
                                child: Text('Forgot Password?', style: Theme.of(context).textTheme.bodyMedium),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!_viewModel.isDataInitialized())
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.7),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context, {required bool isForgotPassword}) {
    TextEditingController recoveryController = TextEditingController();
    String titleText = isForgotPassword ? 'Forgot Password?' : 'Forgot User?';
    String contentText =
        isForgotPassword ? 'Enter your email to recover your password.' : 'Enter your email to recover your username.';
    String hintText = isForgotPassword ? 'Your Email for Password Recovery' : 'Your Email for Username Recovery';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleText),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(contentText),
              const SizedBox(height: 16),
              TextField(
                controller: recoveryController,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Recover'),
              onPressed: () {
                String recoveryEmail = recoveryController.text;
                if (recoveryEmail.isNotEmpty &&
                    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(recoveryEmail)) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Recovery email sent to $recoveryEmail')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid email.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
