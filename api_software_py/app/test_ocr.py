import os
import json

from dotenv import load_dotenv

from app.services.ocr_service import OCRService
from app.services.invoice_service import InvoiceService


base_dir = os.path.dirname(os.path.abspath(__file__))

load_dotenv(
    os.path.join(base_dir, "..", ".env")
)

ruta = os.path.abspath(
    os.path.join(base_dir, "..", "uploads", "prueba.jpg")
)

ruta_cache = os.path.abspath(
    os.path.join(base_dir, "..", "uploads", "cache_ocr.json")
)

print("Verificando entorno de prueba...")

if os.path.exists(ruta):

    if os.path.exists(ruta_cache):

        print("Cargando OCR desde cache...")

        with open(ruta_cache, "r", encoding="utf-8") as f:
            resultado_ocr = json.load(f)

    else:

        print("Procesando imagen con PaddleOCR...")

        ocr = OCRService()

        resultado_ocr = ocr.extraer_texto(ruta)

        with open(ruta_cache, "w", encoding="utf-8") as f:
            json.dump(
                resultado_ocr,
                f,
                ensure_ascii=False,
                indent=4
            )

    invoice_service = InvoiceService()

    factura = invoice_service.procesar(resultado_ocr)

    print("\n====================================")
    print("FACTURA ESTRUCTURADA")
    print("====================================")
    print(json.dumps(
        factura,
        indent=4,
        ensure_ascii=False
    ))

else:
    print("No existe la imagen de prueba.")