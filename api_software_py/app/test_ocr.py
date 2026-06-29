import os
import json
from app.services.ocr_service import OCRService
from app.services.invoice_service import InvoiceService

ruta = os.path.join(
    os.path.dirname(__file__),
    "..",
    "uploads",
    "prueba.jpg"
)
ruta = os.path.abspath(ruta)

print("Verificando entorno de prueba...")
print("Ruta del archivo:", ruta)
print("Archivo encontrado:", os.path.exists(ruta))

if os.path.exists(ruta):
    ocr = OCRService()
    resultado_ocr = ocr.extraer_texto(ruta)

    invoice_service = InvoiceService()
    factura_procesada = invoice_service.procesar(resultado_ocr)

    print("\n==========================================")
    print("      RESULTADO FACTURA ESTRUCTURADA      ")
    print("==========================================")
    print(json.dumps(factura_procesada, indent=4, ensure_ascii=False))
else:
    print("Error: Coloca una imagen válida en la ruta especificada antes de ejecutar.")