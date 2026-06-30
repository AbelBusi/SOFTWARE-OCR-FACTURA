import 'package:flutter/material.dart';
import 'slide_page_route.dart';
import 'navigation_container.dart';
import 'custom_alert.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      CustomAlert.warning(context, "Por favor, completa todos los campos");
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      CustomAlert.warning(context, "Ingresa un correo electrónico válido");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(email, password);

      await TokenStorage.saveToken(result.accessToken);
      await TokenStorage.saveUserId(result.usuario.idUsuario);
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        SlidePageRoute(
          page: const MainNavigationContainer(),
          routeName: '/dashboard',
        ),
      );
    } catch (e) {
      if (!mounted) return;

      CustomAlert.error(
        context,
        e.toString().replaceFirst("Exception: ", ""),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.document_scanner_rounded,
                  size: 72,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  "OCR FACTURA",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Ingresa tus credenciales para continuar",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  enabled: !_isLoading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Correo electrónico",
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  enabled: !_isLoading,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      "Entrar",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    Navigator.pushNamed(context, '/register');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: const Text(
                    "¿No tienes cuenta? Regístrate aquí",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}