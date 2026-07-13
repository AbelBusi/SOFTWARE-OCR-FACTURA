package com.example.app_software_ocrfactura

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream

class MainActivity : FlutterActivity() {

    private val canal = "app/downloads"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, canal)
            .setMethodCallHandler { call, result ->
                if (call.method == "guardarEnDescargas") {
                    try {
                        val nombre = call.argument<String>("nombre")!!
                        val mime = call.argument<String>("mime") ?: "application/octet-stream"
                        val bytes = call.argument<ByteArray>("bytes")!!
                        result.success(guardarEnDescargas(nombre, mime, bytes))
                    } catch (e: Exception) {
                        result.error("SAVE_FAILED", e.message, null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    /** Guarda el archivo en la carpeta pública Descargas y devuelve su ruta/uri. */
    private fun guardarEnDescargas(nombre: String, mime: String, bytes: ByteArray): String {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10+: MediaStore (sin permisos, visible en la app Archivos).
            val valores = ContentValues().apply {
                put(MediaStore.Downloads.DISPLAY_NAME, nombre)
                put(MediaStore.Downloads.MIME_TYPE, mime)
                put(MediaStore.Downloads.IS_PENDING, 1)
            }
            val resolver = applicationContext.contentResolver
            val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, valores)
                ?: throw Exception("No se pudo crear el archivo en Descargas")

            resolver.openOutputStream(uri)?.use { it.write(bytes) }
                ?: throw Exception("No se pudo escribir el archivo")

            valores.clear()
            valores.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, valores, null, null)
            return uri.toString()
        } else {
            // Android 9 y anteriores: escritura directa (requiere WRITE_EXTERNAL_STORAGE).
            val dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            if (!dir.exists()) dir.mkdirs()
            val archivo = File(dir, nombre)
            FileOutputStream(archivo).use { it.write(bytes) }
            return archivo.absolutePath
        }
    }
}
