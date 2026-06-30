import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'slide_page_route.dart';
import 'navigation_container.dart';
import 'custom_alert.dart';
import 'services/auth_service.dart';
import 'services/token_storage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _dniController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _nombresController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();

  bool _isScanning = false;
  bool _isSubmitting = false;
  DateTime? _fechaNacimiento;

  Future<void> _scanDniDocument() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (photo == null) return;

      setState(() {
        _isScanning = true;
      });

      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      String? dniDetectado;
      List<String> lineasValidas = [];

      final RegExp dniRegex = RegExp(r'\b\d{8}\b');

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          String text = line.text.trim();
          if (text.isNotEmpty) {
            lineasValidas.add(text);
          }
        }
      }

      for (int i = 0; i < lineasValidas.length; i++) {
        String lineaLimpia = lineasValidas[i].replaceAll(' ', '');

        if (dniRegex.hasMatch(lineaLimpia) && dniDetectado == null) {
          dniDetectado = dniRegex.stringMatch(lineaLimpia);

          List<String> candidatos = [];
          for (int j = 0; j < lineasValidas.length; j++) {
            String item = lineasValidas[j].toUpperCase();
            if (!dniRegex.hasMatch(item.replaceAll(' ', '')) &&
                !item.contains('REPUBLICA') &&
                !item.contains('PERU') &&
                !item.contains('REGISTRO') &&
                item.length > 2) {
              candidatos.add(lineasValidas[j]);
            }
          }

          setState(() {
            _dniController.text = dniDetectado!;
            if (candidatos.length >= 2) {
              _apellidosController.text = candidatos[0];
              _nombresController.text = candidatos[1];
            } else if (candidatos.length == 1) {
              _apellidosController.text = candidatos[0];
            }

            if (_emailController.text.isEmpty) {
              _emailController.text = "$dniDetectado@documento.pe";
            }
          });
          break;
        }
      }

      await textRecognizer.close();

      setState(() {
        _isScanning = false;
      });

      if (dniDetectado != null) {
        _showNotification("Datos del DNI vinculados.");
      } else {
        _showNotification("No se detectó el DNI. Intenta con más luz.");
      }

    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      _showNotification("Error en la lectura de caracteres.");
    }
  }

  Future<void> _seleccionarFechaNacimiento() async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime(hoy.year - 18, hoy.month, hoy.day),
      firstDate: DateTime(1900),
      lastDate: hoy,
      helpText: 'Fecha de nacimiento',
    );

    if (fecha != null) {
      setState(() {
        _fechaNacimiento = fecha;
        _fechaNacimientoController.text =
        "${fecha.year.toString().padLeft(4, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_isSubmitting) return;

    final dni = _dniController.text.trim();
    final nombres = _nombresController.text.trim();
    final apellidos = _apellidosController.text.trim();
    final correo = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (dni.isEmpty ||
        nombres.isEmpty ||
        apellidos.isEmpty ||
        correo.isEmpty ||
        password.isEmpty ||
        _fechaNacimiento == null) {
      CustomAlert.warning(context, "Por favor, completa todos los campos");
      return;
    }

    if (dni.length != 8) {
      CustomAlert.warning(context, "El DNI debe tener 8 dígitos");
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(correo)) {
      CustomAlert.warning(context, "Ingresa un correo electrónico válido");
      return;
    }

    if (password.length < 6) {
      CustomAlert.warning(context, "La contraseña debe tener al menos 6 caracteres");
      return;
    }

    if (password != confirmPassword) {
      CustomAlert.warning(context, "Las contraseñas no coinciden");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 1. Registrar usuario
      await _authService.register(
        dni: dni,
        nombres: nombres,
        apellidos: apellidos,
        fechaNacimiento: _fechaNacimientoController.text,
        correo: correo,
        password: password,
      );

      // 2. Login automático para obtener token + id_usuario
      final loginResult = await _authService.login(correo, password);

      await TokenStorage.saveToken(loginResult.accessToken);
      await TokenStorage.saveUserId(loginResult.usuario.idUsuario);

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
          _isSubmitting = false;
        });
      }
    }
  }

  void _showNotification(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xFF1565C0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _dniController.dispose();
    _apellidosController.dispose();
    _nombresController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fechaNacimientoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = _isScanning || _isSubmitting;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.app_registration_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  "REGISTRO AUTOMATIZADO",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: const Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Escanea tu documento para procesar identidades locales",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF546E7A),
                  ),
                ),
                const SizedBox(height: 32),

                OutlinedButton.icon(
                  onPressed: isBusy ? null : _scanDniDocument,
                  icon: _isScanning
                      ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1565C0))
                  )
                      : const Icon(Icons.document_scanner_rounded),
                  label: Text(
                    _isScanning ? "LEYENDO DOCUMENTO..." : "ESCANEAR DNI PERUANO",
                    style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1565C0),
                    side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                TextField(
                  controller: _dniController,
                  enabled: !isBusy,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  decoration: const InputDecoration(
                    labelText: "Número de DNI",
                    counterText: "",
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _apellidosController,
                  enabled: !isBusy,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: "Apellidos Paterno / Materno",
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _nombresController,
                  enabled: !isBusy,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: "Nombres Completos",
                    prefixIcon: Icon(Icons.person_pin_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _fechaNacimientoController,
                  enabled: !isBusy,
                  readOnly: true,
                  onTap: isBusy ? null : _seleccionarFechaNacimiento,
                  decoration: const InputDecoration(
                    labelText: "Fecha de nacimiento",
                    prefixIcon: Icon(Icons.cake_outlined),
                    suffixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _emailController,
                  enabled: !isBusy,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Correo electrónico",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _passwordController,
                  enabled: !isBusy,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _confirmPasswordController,
                  enabled: !isBusy,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Confirmar contraseña",
                    prefixIcon: Icon(Icons.lock_reset_outlined),
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: isBusy ? null : _handleRegister,
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    "Registrarse",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                TextButton(
                  onPressed: isBusy ? null : () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: const Text(
                    "¿Ya tienes cuenta? Inicia sesión",
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