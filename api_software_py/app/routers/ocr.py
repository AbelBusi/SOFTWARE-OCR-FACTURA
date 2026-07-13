from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from sqlalchemy.orm import Session
from datetime import datetime
import shutil
import os

from app.database import get_db
from app.services.invoice_service import InvoiceService
from app.schemas.ocr import GuardarFacturaRequest
from app.utils.storage import limpiar_imagenes_huerfanas

router = APIRouter(
    prefix="/ocr",
    tags=["OCR"]
)

UPLOAD_DIR = "uploads"

os.makedirs(
    UPLOAD_DIR,
    exist_ok=True
)


@router.post("/upload")
async def subir_imagen(
        id_usuario: int,
        file: UploadFile = File(...),
        db: Session = Depends(get_db)
):
    """Procesa la imagen con OCR + IA y devuelve los datos extraídos SIN guardarlos.

    El usuario debe revisarlos y confirmarlos luego mediante /ocr/guardar.
    """
    # Limpieza best-effort de imágenes de revisiones anteriores que nunca se
    # confirmaron. Nunca debe interrumpir el procesamiento de la nueva imagen.
    try:
        limpiar_imagenes_huerfanas(db, UPLOAD_DIR)
    except Exception:
        pass

    ruta = f"{UPLOAD_DIR}/{file.filename}"

    with open(ruta, "wb") as buffer:
        shutil.copyfileobj(
            file.file,
            buffer
        )

    service = InvoiceService()
    datos_json, confianza = service.procesar_imagen(ruta)

    if "error" in datos_json:
        raise HTTPException(
            status_code=400,
            detail=datos_json["error"]
        )

    return {
        "status": "success",
        "imagen_url": ruta,
        "confianza": confianza,
        "data": datos_json
    }


@router.post("/guardar")
async def guardar_factura(
        payload: GuardarFacturaRequest,
        db: Session = Depends(get_db)
):
    """Persiste los datos de la factura ya revisados y corregidos por el usuario."""

    fecha = payload.factura.fecha_emision.strip() if payload.factura.fecha_emision else ""
    if fecha:
        try:
            datetime.strptime(fecha, "%Y-%m-%d")
        except ValueError:
            raise HTTPException(
                status_code=400,
                detail="La fecha de emisión debe tener el formato AAAA-MM-DD."
            )

    datos_json = {
        "empresa": payload.empresa.model_dump(),
        "factura": payload.factura.model_dump(),
        "detalles": [detalle.model_dump() for detalle in payload.detalles]
    }

    service = InvoiceService()
    resultado = service.guardar_datos(
        db=db,
        id_usuario=payload.id_usuario,
        datos_json=datos_json,
        imagen_url=payload.imagen_url,
        forzar=payload.forzar
    )

    if resultado["status"] == "duplicado":
        # 409 Conflict: la app lo interpreta para pedir confirmación al usuario.
        raise HTTPException(
            status_code=409,
            detail=resultado["message"]
        )

    if resultado["status"] == "error":
        raise HTTPException(
            status_code=400,
            detail=resultado["message"]
        )

    return resultado
