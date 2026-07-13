import os
import re
import json
import uuid
from openai import OpenAI
from sqlalchemy.orm import Session
from app.repositories.invoice_repository import InvoiceRepository
from app.services.ocr_service import OCRService

from app.config import settings

class InvoiceService:

    def __init__(self):
        self.client = OpenAI(
            api_key=settings.GROQ_API_KEY,
            base_url="https://api.groq.com/openai/v1"
        )
        self.model = "llama-3.3-70b-versatile"
        self.ocr_service = OCRService()

    def procesar(self, resultado_ocr):
        texto_plano = "\n".join([item["texto"] for item in resultado_ocr])

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
                    {"role": "system", "content": "Eres un experto en extracción de información de facturas."},
                    {"role": "user", "content": prompt}
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
            return {"error": "La IA devolvió un JSON inválido.", "respuesta": texto_respuesta}
        except Exception as e:
            return {"error": str(e)}

    def procesar_imagen(self, ruta_imagen: str):
        """Ejecuta OCR + estructuración con IA y devuelve los datos SIN persistir."""
        resultado_ocr = self.ocr_service.extraer_texto(ruta_imagen)
        return self.procesar(resultado_ocr)

    def guardar_datos(self, db: Session, id_usuario: int, datos_json: dict, imagen_url: str = None):
        """Persiste los datos (ya extraídos y posiblemente corregidos por el usuario)."""
        repo = InvoiceRepository(db)
        try:
            empresa_data = dict(datos_json["empresa"])
            ruc = (empresa_data.get("ruc") or "").strip()

            if re.fullmatch(r"\d{11}", ruc):
                # RUC válido: se reutiliza la empresa si ya existe.
                empresa_data["ruc"] = ruc
                empresa = repo.obtener_empresa_por_ruc(ruc)
                if not empresa:
                    empresa = repo.registrar_empresa(empresa_data)
            else:
                # Sin RUC (o no extraíble): se asigna un identificador interno único
                # para que cada factura sin RUC tenga su propia empresa y no colisione
                # con otras. No representa un RUC real y no se expone al usuario.
                empresa_data["ruc"] = f"SINRUC-{uuid.uuid4().hex[:8].upper()}"
                empresa = repo.registrar_empresa(empresa_data)

            factura = repo.registrar_factura(
                id_usuario=id_usuario,
                id_empresa=empresa.id_empresa,
                datos_factura=datos_json["factura"],
                imagen_url=imagen_url
            )

            for detalle in datos_json["detalles"]:
                repo.registrar_detalle(id_factura=factura.id_factura, datos_detalle=detalle)

            repo.commit()
            return {"status": "success", "id_factura": factura.id_factura, "data": datos_json}

        except Exception as e:
            repo.rollback()
            return {"status": "error", "message": f"Error en persistencia: {str(e)}"}

    def procesar_y_guardar(self, db: Session, ruta_imagen: str, id_usuario: int, imagen_url: str = None):
        datos_json = self.procesar_imagen(ruta_imagen)

        if "error" in datos_json:
            return {"status": "error", "message": datos_json["error"]}

        return self.guardar_datos(
            db=db,
            id_usuario=id_usuario,
            datos_json=datos_json,
            imagen_url=imagen_url
        )