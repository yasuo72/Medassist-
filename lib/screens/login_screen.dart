import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../services/auth_service.dart'; // Assuming this handles OTP logic
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/medical_record_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _useEmailLogin = true; // Renamed for clarity
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _auth = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailFlow() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password required')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _auth.loginUser(email: email, password: password);

      // Retrieve token saved by ApiService and push to AuthProvider
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null && mounted) {
        context.read<AuthProvider>().setToken(token);
        // Also push to MedicalRecordProvider silently
        context.read<MedicalRecordProvider>().setAuthToken(token, silent: true);
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBiometricFlow() async {
    setState(() => _isLoading = true);
    // TODO: Implement actual biometric authentication using local_auth package
    await Future.delayed(const Duration(seconds: 2)); // Simulate check
    bool authenticated = false; // Simulate biometric check result
    if (mounted) {
      if (authenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // TODO: Show biometric authentication failed message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Biometric authentication failed. Try Email/Password.',
            ),
          ),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface, // Use theme background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0), // Increased padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  MdiIcons.shieldLockOutline, // More relevant icon
                  size: 60,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Access your MedAssist+ profile securely.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: 'Poppins',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),

                // Login Method Toggle (Improved Styling)
                SegmentedButton<bool>(
                  segments: const <ButtonSegment<bool>>[
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('Email & Password'),
                      icon: Icon(MdiIcons.emailOutline),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Biometrics'),
                      icon: Icon(MdiIcons.fingerprint),
                    ),
                  ],
                  selected: <bool>{_useEmailLogin},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _useEmailLogin = newSelection.first;
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceVariant
                        .withOpacity(0.3),
                    selectedForegroundColor: theme.colorScheme.onPrimary,
                    selectedBackgroundColor: theme.colorScheme.primary,
                    textStyle: const TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
                const SizedBox(height: 24),

                if (_useEmailLogin) ...[
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'you@example.com',
                      prefixIcon: Icon(
                        MdiIcons.emailOutline,
                        color: theme.colorScheme.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(
                        0.5,
                      ),
                    ),
                    validator:
                        (value) =>
                            (value == null || !value.contains('@'))
                                ? 'Enter a valid email'
                                : null,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(fontFamily: 'Poppins'),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(
                        MdiIcons.lockOutline,
                        color: theme.colorScheme.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(
                        0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Button
                  ElevatedButton.icon(
                    icon: Icon(
                      _isLoading ? MdiIcons.loading : MdiIcons.loginVariant,
                    ),
                    onPressed: _isLoading ? null : _handleEmailFlow,
                    label: Text(_isLoading ? 'Logging in...' : 'Login'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        _isLoading
                            ? null
                            : () => Navigator.pushNamed(context, '/register'),
                    child: const Text('Create an account'),
                  ),
                ] else ...[
                  // Biometric Login Button
                  ElevatedButton.icon(
                    icon: Icon(
                      _isLoading ? MdiIcons.loading : MdiIcons.fingerprint,
                      size: 28,
                    ),
                    onPressed: _isLoading ? null : _handleBiometricFlow,
                    label: Text(
                      _isLoading ? 'Checking...' : 'Login with Biometrics',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: <Widget>[
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'OR CONTINUE WITH',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'Poppins',
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // Social Login Placeholders
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialLoginButton(
                      theme,
                      MdiIcons.google,
                      Colors.redAccent,
                      () {
                        /* TODO: Google Sign In */
                      },
                    ),
                    _buildSocialLoginButton(
                      theme,
                      MdiIcons.apple,
                      Colors.black,
                      () {
                        /* TODO: Apple Sign In */
                      },
                    ),
                    _buildSocialLoginButton(
                      theme,
                      MdiIcons.faceManOutline,
                      theme.colorScheme.secondary,
                      () {
                        /* TODO: Face ID (if separate from general biometric) */
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to registration screen if one exists or handle differently
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registration flow not implemented yet.'),
                      ),
                    );
                  },
                  child: Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            // Extraneous old UI elements removed from here
          ),
        ),
      ),
    );
  }

  // Helper method for social login buttons
  Widget _buildSocialLoginButton(
    ThemeData theme,
    IconData icon,
    Color iconColor,
    VoidCallback onPressed,
  ) {
    return IconButton(
      icon: Icon(icon, size: 30, color: iconColor),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(16),
        backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
    );
  }
}
