class InvoiceService:
    def __init__(self):
        pass

    def procesar(self, resultado_ocr):
        texto_plano = "\n".join([item["texto"] for item in resultado_ocr])

        resultado_estructurado = {
            "empresa": {
                "ruc": "20123456789",
                "nombre": "EMPRESA DE PRUEBA S.A.C.",
                "direccion": "Av. Progreso 145"
            },
            "factura": {
                "tipo_comprobante": "Factura Electrónica",
                "numero_comprobante": "F001-0002345",
                "fecha_emision": "2026-06-29",
                "subtotal": 150.00,
                "igv": 27.00,
                "total": 177.00
            },
            "detalles": [
                {
                    "descripcion": "Servicio de consultoría TI",
                    "cantidad": 1.0,
                    "precio_unitario": 150.00,
                    "subtotal": 150.00
                }
            ],
            "texto_original": texto_plano
        }

        return resultado_estructurado