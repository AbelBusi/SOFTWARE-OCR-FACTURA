import os
import json

from openai import OpenAI


class InvoiceService:

    def __init__(self):
        self.client = OpenAI(
            api_key=os.getenv("GROQ_API_KEY"),
            base_url="https://api.groq.com/openai/v1"
        )

        self.model = "llama-3.3-70b-versatile"

    def procesar(self, resultado_ocr):

        texto_plano = "\n".join(
            [item["texto"] for item in resultado_ocr]
        )

        prompt = (
            "Eres un asistente experto en contabilidad y extracción de datos. "
            "Tu tarea es procesar el texto extraído por un OCR desde una factura o ticket de compra "
            "y estructurarlo en un formato JSON estricto. "
            "Devuelve ÚNICAMENTE el objeto JSON, sin texto explicativo, sin introducciones ni bloques de código.\n\n"

            "Reglas:\n"
            "1. Convierte la fecha al formato YYYY-MM-DD.\n"
            "2. Si el documento indica IVA o IGV incluido, calcula subtotal e impuesto correctamente.\n"
            "3. Relaciona correctamente cantidades, precios y descripciones.\n"
            "4. Si un dato no existe devuelve cadena vacía o 0.0.\n\n"

            "La estructura debe ser EXACTAMENTE:\n"

            "{\n"
            '  "empresa": {\n'
            '    "ruc": "",\n'
            '    "nombre": "",\n'
            '    "direccion": ""\n'
            "  },\n"
            '  "factura": {\n'
            '    "tipo_comprobante": "",\n'
            '    "numero_comprobante": "",\n'
            '    "fecha_emision": "",\n'
            '    "subtotal": 0.0,\n'
            '    "igv": 0.0,\n'
            '    "total": 0.0\n'
            "  },\n"
            '  "detalles": [\n'
            "    {\n"
            '      "descripcion": "",\n'
            '      "cantidad": 0.0,\n'
            '      "precio_unitario": 0.0,\n'
            '      "subtotal": 0.0\n'
            "    }\n"
            "  ]\n"
            "}\n\n"

            f"Texto OCR:\n{texto_plano}"
        )

        try:

            response = self.client.chat.completions.create(
                model=self.model,
                temperature=0,
                messages=[
                    {
                        "role": "system",
                        "content": "Eres un experto en extracción de información de facturas."
                    },
                    {
                        "role": "user",
                        "content": prompt
                    }
                ]
            )

            texto_respuesta = response.choices[0].message.content.strip()

            if texto_respuesta.startswith("```json"):
                texto_respuesta = texto_respuesta[7:]

            elif texto_respuesta.startswith("```"):
                texto_respuesta = texto_respuesta[3:]

            if texto_respuesta.endswith("```"):
                texto_respuesta = texto_respuesta[:-3]

            texto_respuesta = texto_respuesta.strip()

            return json.loads(texto_respuesta)

        except json.JSONDecodeError:
            return {
                "error": "La IA devolvió un JSON inválido.",
                "respuesta": texto_respuesta
            }

        except Exception as e:
            return {
                "error": str(e)
            }