import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'slide_page_route.dart';
import 'navigation_container.dart';
import 'custom_alert.dart';
import 'services/auth_service.dart';
import 'services/token_storage.dart';
import 'l10n/app_localizations.dart';

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

  // Aviso (no bloqueante) de posible foto tomada a una pantalla
  bool _posibleFotoPantalla = false;

  Future<void> _scanDniDocument() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (photo == null) return;

      setState(() {
        _isScanning = true;
        _posibleFotoPantalla = false;
      });

      // 1. Heurística: ¿parece foto de una pantalla (moiré / sobreexposición)?
      final bool sospechoso = await _pareceFotoDePantalla(photo.path);

      // 2. OCR normal
      final inputImage = InputImage.fromFilePath(photo.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      String? dniDetectado;
      List<String> lineasValidas = [];

      final RegExp dniRegex = RegExp(r'\b\d{8}\b');
      final RegExp fechaRegex = RegExp(r'\b(\d{1,2})[\/\-.](\d{1,2})[\/\-.](\d{2,4})\b');

      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          String text = line.text.trim();
          if (text.isNotEmpty) {
            lineasValidas.add(text);
          }
        }
      }

      // --- Detección de DNI, nombres y apellidos (igual que antes) ---
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

      // --- Detección de fecha de nacimiento ---
      final DateTime? fechaDetectada = _extraerFechaNacimiento(lineasValidas, fechaRegex);
      if (fechaDetectada != null) {
        setState(() {
          _fechaNacimiento = fechaDetectada;
          _fechaNacimientoController.text =
          "${fechaDetectada.year.toString().padLeft(4, '0')}-${fechaDetectada.month.toString().padLeft(2, '0')}-${fechaDetectada.day.toString().padLeft(2, '0')}";
        });
      }

      await textRecognizer.close();

      setState(() {
        _isScanning = false;
        _posibleFotoPantalla = sospechoso;
      });

      if (dniDetectado != null) {
        _showNotification(
          fechaDetectada != null
              ? "Datos del DNI vinculados, incluida la fecha de nacimiento."
              : "Datos del DNI vinculados. Verifica la fecha de nacimiento.",
        );
      } else {
        _showNotification("No se detectó el DNI. Intenta con más luz.");
      }

      if (sospechoso) {
        _showNotification(
          "La imagen parece tomada desde una pantalla. Si tienes el DNI físico, vuelve a escanear.",
        );
      }
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      _showNotification("Error en la lectura de caracteres.");
    }
  }

  /// Busca la fecha de nacimiento cerca de la palabra "NACIMIENTO".
  /// Si no encuentra la etiqueta, usa la fecha más antigua de todas las
  /// encontradas (en un DNI suele haber nacimiento / emisión / caducidad,
  /// y nacimiento es siempre la más antigua).
  DateTime? _extraerFechaNacimiento(List<String> lineas, RegExp fechaRegex) {
    DateTime? _parsear(String texto) {
      final m = fechaRegex.firstMatch(texto);
      if (m == null) return null;
      int d = int.tryParse(m.group(1) ?? '') ?? 0;
      int mo = int.tryParse(m.group(2) ?? '') ?? 0;
      int y = int.tryParse(m.group(3) ?? '') ?? 0;
      if (y < 100) y += (y < 30 ? 2000 : 1900);
      if (d < 1 || d > 31 || mo < 1 || mo > 12) return null;
      try {
        final fecha = DateTime(y, mo, d);
        final hoy = DateTime.now();
        if (fecha.isAfter(hoy) || fecha.year < 1900) return null;
        return fecha;
      } catch (_) {
        return null;
      }
    }

    // 1. Buscar por etiqueta "NACIMIENTO"
    for (int i = 0; i < lineas.length; i++) {
      if (lineas[i].toUpperCase().contains('NACIMIENTO')) {
        // La fecha puede estar en la misma línea o en las 2 siguientes
        for (int j = i; j < min(i + 3, lineas.length); j++) {
          final fecha = _parsear(lineas[j]);
          if (fecha != null) return fecha;
        }
      }
    }

    // 2. Fallback: tomar la fecha más antigua entre todas las detectadas
    DateTime? masAntigua;
    for (final linea in lineas) {
      final fecha = _parsear(linea);
      if (fecha != null && (masAntigua == null || fecha.isBefore(masAntigua))) {
        masAntigua = fecha;
      }
    }
    return masAntigua;
  }

  /// Heurística local (sin servidor, sin costo) para detectar si la foto
  /// fue tomada a una pantalla en vez de al documento físico.
  ///
  /// IMPORTANTE: esto NO es un sistema de anti-spoofing certificado.
  /// Detecta dos señales típicas de fotografiar una pantalla:
  ///   - patrón moiré / ruido de alta frecuencia (choque de rejillas de píxeles)
  ///   - sobreexposición / poca variación de brillo (retroiluminación)
  /// Un atacante cuidadoso (buena resolución, ángulo, distancia) puede evadirla.
  /// Para producción con requisitos serios de seguridad, se recomienda un
  /// SDK dedicado de verificación de documentos (Regula, Sumsub, Onfido, etc.)
  Future<bool> _pareceFotoDePantalla(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final original = img.decodeImage(bytes);
      if (original == null) return false;

      final resized = img.copyResize(original, width: 300);
      final gray = img.grayscale(resized);

      int edgeSum = 0;
      int pares = 0;
      int sumLum = 0;
      int sumSq = 0;
      int sobreexpuestos = 0;
      final total = gray.width * gray.height;

      for (int y = 0; y < gray.height; y++) {
        for (int x = 0; x < gray.width; x++) {
          final l = img.getLuminance(gray.getPixel(x, y)).round();
          sumLum += l;
          sumSq += l * l;
          if (l > 245) sobreexpuestos++;

          if (x < gray.width - 1 && y < gray.height - 1) {
            final lr = img.getLuminance(gray.getPixel(x + 1, y)).round();
            final ld = img.getLuminance(gray.getPixel(x, y + 1)).round();
            edgeSum += (l - lr).abs() + (l - ld).abs();
            pares++;
          }
        }
      }

      final edgeDensity = pares > 0 ? edgeSum / pares : 0;
      final mean = sumLum / total;
      final variance = (sumSq / total) - (mean * mean);
      final ratioSobreexpuesto = sobreexpuestos / total;

      final bool patronMoire = edgeDensity > 18;
      final bool brilloSospechoso = ratioSobreexpuesto > 0.12 || variance < 200;

      return patronMoire || brilloSospechoso;
    } catch (_) {
      // Si el análisis falla, no bloqueamos el flujo por esto
      return false;
    }
  }

  Future<void> _seleccionarFechaNacimiento() async {
    final hoy = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(hoy.year - 18, hoy.month, hoy.day),
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
      CustomAlert.warning(context, context.tr('fill_all_fields'));
      return;
    }

    if (dni.length != 8) {
      CustomAlert.warning(context, context.tr('dni_8_digits'));
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(correo)) {
      CustomAlert.warning(context, context.tr('invalid_email'));
      return;
    }

    if (password.length < 6) {
      CustomAlert.warning(context, context.tr('password_min'));
      return;
    }

    if (password != confirmPassword) {
      CustomAlert.warning(context, context.tr('passwords_no_match'));
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
                  context.tr('register_title'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: const Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('register_subtitle'),
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
                    _isScanning ? context.tr('reading_document') : context.tr('scan_dni'),
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

                if (_posibleFotoPantalla) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFB74D)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF6C00)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "La foto parece tomada de una pantalla. Verifica los datos o vuelve a escanear con el documento físico.",
                            style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFFEF6C00)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                TextField(
                  controller: _dniController,
                  enabled: !isBusy,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  decoration: InputDecoration(
                    labelText: context.tr('dni_number'),
                    counterText: "",
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _apellidosController,
                  enabled: !isBusy,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: context.tr('lastnames'),
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _nombresController,
                  enabled: !isBusy,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: context.tr('names'),
                    prefixIcon: const Icon(Icons.person_pin_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _fechaNacimientoController,
                  enabled: !isBusy,
                  readOnly: true,
                  onTap: isBusy ? null : _seleccionarFechaNacimiento,
                  decoration: InputDecoration(
                    labelText: context.tr('birth_date'),
                    prefixIcon: const Icon(Icons.cake_outlined),
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _emailController,
                  enabled: !isBusy,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: context.tr('email'),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _passwordController,
                  enabled: !isBusy,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: context.tr('password'),
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _confirmPasswordController,
                  enabled: !isBusy,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: context.tr('confirm_password'),
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
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
                      : Text(
                    context.tr('register_button'),
                    style: const TextStyle(
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
                  child: Text(
                    context.tr('have_account'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
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