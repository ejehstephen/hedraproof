import 'package:flutter/material.dart';
import 'package:hedera_proof/providers/auth_provider.dart';
import 'package:hedera_proof/widgets/gradient_button.dart';
import '../main.dart';
import '../screens/dashboard_screen.dart';
import 'package:provider/provider.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _walletController = TextEditingController();

  bool _isLogin = true;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    // Basic validation can be added here if needed
    // if (!_formKey.currentState!.validate()) {
    //   return;
    // }
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Clear previous errors before a new attempt
    authProvider.clearError();

    if (_isLogin) {
      await authProvider.login(email, password);
    } else {
      final name = _nameController.text.trim();
      final walletAddress = _walletController.text.trim();
      await authProvider.register(name, email, password, walletAddress);
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainLayout()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;
    final errorMessage = authProvider.errorMessage;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A23),
              Color(0xFF0E0E2C),
              Color(0xFF1A1A40),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and Title
                Column(
                  children: [
                    Text(
                      'HederaProof',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00E7FF),
                        shadows: [
                          BoxShadow(
                            color: const Color(0xFF00E7FF).withOpacity(0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Decentralized NFT Receipt System',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFA0A0B3),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),

                // Auth Form
                Container(
                  width: isMobile ? double.infinity : 400,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0E0E2C).withOpacity(0.8),
                        const Color(0xFF1A1A40).withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF7A5CFF).withOpacity(0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7A5CFF).withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          _isLogin ? 'Sign In' : 'Create Account',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFEAEAEA),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLogin
                              ? 'Welcome back to HederaProof'
                              : 'Join the future of NFT receipts',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFA0A0B3),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Name Field (only for registration)
                        if (!_isLogin) ...[
                          _buildFormField(
                            label: 'Full Name',
                            controller: _nameController,
                            hint: 'Enter your full name',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),
                          _buildFormField(
                            label: 'Wallet Address',
                            controller: _walletController,
                            hint: '0.0.123456',
                            icon: Icons.account_balance_wallet_outlined,
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email Field
                        _buildFormField(
                          label: 'Email Address',
                          controller: _emailController,
                          hint: 'your@email.com',
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        _buildPasswordField(),
                        const SizedBox(height: 24),

                        // Error Message
                        if (errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5A6A).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFFF5A6A).withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 18,
                                  color: Color(0xFFFF5A6A),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFFF5A6A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.visible,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Login/Register Button
                        GradientButton(
                          label: _isLogin ? 'Sign In' : 'Create Account',
                          onPressed: () { _handleAuth(); },
                          isLoading: isLoading,
                          icon: _isLogin ? Icons.login : Icons.person_add_alt_1,
                        ),
                        const SizedBox(height: 24),

                        // Toggle between Login/Register
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin
                                  ? "Don't have an account?"
                                  : 'Already have an account?',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFFA0A0B3),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  authProvider.clearError();
                                });
                              },
                              child: Text(
                                _isLogin ? 'Sign Up' : 'Sign In',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF00E7FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Footer
                const Text(
                  'By continuing, you agree to our Terms and Privacy Policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFA0A0B3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFFA0A0B3),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Color(0xFFEAEAEA)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFFA0A0B3).withOpacity(0.5),
            ),
            prefixIcon: Icon(
              icon,
              color: const Color(0xFFA0A0B3),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFFA0A0B3),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: !_showPassword,
          style: const TextStyle(color: Color(0xFFEAEAEA)),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: TextStyle(
              color: const Color(0xFFA0A0B3).withOpacity(0.5),
            ),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: Color(0xFFA0A0B3),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFFA0A0B3),
              ),
              onPressed: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
