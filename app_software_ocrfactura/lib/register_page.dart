import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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

  final ImagePicker _picker = ImagePicker();
  bool _isScanning = false;

  Future<void> _scanDniDocument() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90, // Un toque más de calidad para no perder las letras pequeñas
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

      // 1. Filtrar y limpiar todas las líneas encontradas en el DNI
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          String text = line.text.trim();
          if (text.isNotEmpty) {
            lineasValidas.add(text);
          }
        }
      }

      // 2. Buscar el DNI y extraer los textos cercanos (Apellidos y Nombres)
      for (int i = 0; i < lineasValidas.length; i++) {
        String lineaLimpia = lineasValidas[i].replaceAll(' ', '');

        if (dniRegex.hasMatch(lineaLimpia) && dniDetectado == null) {
          dniDetectado = dniRegex.stringMatch(lineaLimpia);

          // Estrategia Placebo/OCR: Los apellidos y nombres suelen estar en los bloques de texto
          // adyacentes o líneas continuas. Recogemos las líneas alfabéticas cercanas.
          List<String> candidatos = [];
          for (int j = 0; j < lineasValidas.length; j++) {
            // Saltamos el DNI y etiquetas fijas del documento peruano
            String item = lineasValidas[j].toUpperCase();
            if (!dniRegex.hasMatch(item.replaceAll(' ', '')) &&
                !item.contains('REPUBLICA') &&
                !item.contains('PERU') &&
                !item.contains('REGISTRO') &&
                item.length > 2) {
              candidatos.add(lineasValidas[j]);
            }
          }

          // Asignación inteligente por orden de lectura de arriba a abajo
          setState(() {
            _dniController.text = dniDetectado!;
            if (candidatos.length >= 2) {
              _apellidosController.text = candidatos[0]; // Primera línea alfabética grande detectada
              _nombresController.text = candidatos[1];   // Segunda línea
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  onPressed: _isScanning ? null : _scanDniDocument,
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

                // Campo DNI
                TextField(
                  controller: _dniController,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  decoration: const InputDecoration(
                    labelText: "Número de DNI",
                    counterText: "",
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo Apellidos
                TextField(
                  controller: _apellidosController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: "Apellidos Paterno / Materno",
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo Nombres
                TextField(
                  controller: _nombresController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: "Nombres Completos",
                    prefixIcon: Icon(Icons.person_pin_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo Correo
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Correo electrónico",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 20),

                // Campo Contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    prefixIcon: Icon(Icons.lock_outline_rounded),
                  ),
                ),
                const SizedBox(height: 20),

                // Confirmar Contraseña
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Confirmar contraseña",
                    prefixIcon: Icon(Icons.lock_reset_outlined),
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isScanning
                      ? null
                      : () => Navigator.pushReplacementNamed(context, '/dashboard'),
                  child: const Text(
                    "Registrarse",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                TextButton(
                  onPressed: () => Navigator.pop(context),
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