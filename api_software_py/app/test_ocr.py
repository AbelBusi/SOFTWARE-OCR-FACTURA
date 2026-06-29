import os
from services.ocr_service import OCRService


ruta = os.path.join(
    os.path.dirname(__file__),
    "..",
    "uploads",
    "factura.png"
)

ruta = os.path.abspath(ruta)

print("Ruta:", ruta)
print("Existe:", os.path.exists(ruta))


ocr = OCRService()

resultado = ocr.extraer_texto(ruta)


for item in resultado:
    print(item)