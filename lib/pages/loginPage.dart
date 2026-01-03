// Imports the core Flutter Material library (widgets, themes, scaffolds, etc.)
import 'package:flutter/material.dart';

// Imports GoRouter for declarative navigation and route management
import 'package:go_router/go_router.dart';

// Imports your app-wide theme constants (spacing, colors, typography)
import 'package:sfa_merchandising/theme.dart';

import 'package:sfa_merchandising/nav.dart'; // AppRoutes
import 'package:sfa_merchandising/data/auth/auth_repository.dart';


/// Modern, professional login page with elegant design
/// Uses animations, form validation, and clean UI architecture
class LoginPage extends StatefulWidget {
  // Constructor with optional key for widget tree optimization
  const LoginPage({super.key});

  // Creates the mutable state associated with this widget
  @override
  State<LoginPage> createState() => _LoginPageState();
}

// State class handles UI logic, animations, and form state
class _LoginPageState extends State<LoginPage>
    // Needed for AnimationController (provides vsync)
    with SingleTickerProviderStateMixin {

  // Global key used to validate and save the form state
  final _formKey = GlobalKey<FormState>();

  // Controller for reading and modifying email input
  final _emailController = TextEditingController();

  // Controller for reading and modifying password input
  final _passwordController = TextEditingController();

  // Toggles password visibility (eye icon)
  bool _isPasswordVisible = false;

  // Controls loading spinner and disables button during login
  bool _isLoading = false;

  // Controls animation lifecycle (start, stop, dispose)
  late AnimationController _animationController;

  // Fade animation for smooth page entrance
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initializes animation controller with duration
    _animationController = AnimationController(
      vsync: this, // Prevents offscreen animations (performance optimization)
      duration: const Duration(milliseconds: 800),
    );

    // Creates a fade animation from 0 (transparent) to 1 (fully visible)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      // Adds easing curve for natural animation feel
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Starts the animation when page loads
    _animationController.forward();
  }

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();

    super.dispose();
  }

  // Handles login logic and validation
   Future<void> _handleLogin() async {
    final form = _formKey.currentState;
    if (form == null) return;

    FocusScope.of(context).unfocus();
    if (!form.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final repo = AuthRepository();
      final user = await repo.login(email: email, password: password);

      if (!mounted) return;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password.")),
        );
        return;
      }

      // Success (online or offline fallback happened automatically)
      context.go(AppRoutes.dashboard);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Accesses current theme data
    final theme = Theme.of(context);

    // Extracts color scheme for consistent colors
    final colorScheme = theme.colorScheme;

    // Detects dark mode for adaptive styling
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea( // Prevents overlap with system UI
        child: Center(
          child: SingleChildScrollView( // Prevents overflow on small screens
            child: Padding(
              padding: AppSpacing.paddingLg, // Consistent spacing from theme
              child: FadeTransition(
                opacity: _fadeAnimation, // Applies fade-in animation
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(theme), // Logo + title
                    const SizedBox(height: 48),
                    _buildLoginForm(theme, colorScheme, isDark), // Inputs
                    const SizedBox(height: 24),
                    _buildLoginButton(theme, colorScheme), // CTA button
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Builds the top branding section
  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            // Gradient gives modern premium feel
            gradient: const LinearGradient(
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            // Rounded corners
            borderRadius: BorderRadius.circular(20),
            // Soft shadow for depth
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          // Lock icon symbolizes authentication
          child: const Icon(Icons.lock_outline, size: 40, color: Colors.white),
        ),
        const SizedBox(height: 24),

        // Main headline
        Text(
          'Welcome Back',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Sign in to continue',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // Builds the login form
  Widget _buildLoginForm(
      ThemeData theme, ColorScheme colorScheme, bool isDark) {
    return Form(
      key: _formKey, // Connects form to validation logic
      child: Column(
        children: [
          // Email input
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            theme: theme,
            colorScheme: colorScheme,
            isDark: isDark,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your email';
              if (!value.contains('@')) return 'Please enter a valid email';
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Password input
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            icon: Icons.lock_outline,
            isPassword: true,
            theme: theme,
            colorScheme: colorScheme,
            isDark: isDark,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter your password';
              if (value.length < 6) return 'Password must be at least 6 characters';
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Forgot password action
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {}, // TODO: implement reset flow
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF667EEA),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: Text(
                'Forgot Password?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable styled text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required bool isDark,
    TextInputType? keyboardType,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !_isPasswordVisible, // Password masking
      validator: validator,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        // Leading icon
        prefixIcon: Icon(icon, size: 22, color: colorScheme.onSurface.withValues(alpha: 0.5)),

        // Password visibility toggle
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 22,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,

        // Text styles
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),

        // Background fill
        filled: true,
        fillColor: isDark
            ? colorScheme.surface.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),

        // Borders for all states
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF667EEA),
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 2,
          ),
        ),

        // Inner spacing
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  // Builds the login button
  Widget _buildLoginButton(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin, // Disable when loading
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667EEA),
          foregroundColor: Colors.white,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            // Loading spinner
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            // Button label
            : Text(
                'Sign In',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
