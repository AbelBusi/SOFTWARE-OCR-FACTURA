from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from sqlalchemy.orm import Session
import shutil
import os

from app.database import get_db
from app.services.invoice_service import InvoiceService

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
    ruta = f"{UPLOAD_DIR}/{file.filename}"

    with open(ruta, "wb") as buffer:
        shutil.copyfileobj(
            file.file,
            buffer
        )

    service = InvoiceService()
    resultado = service.procesar_y_guardar(
        db=db,
        ruta_imagen=ruta,
        id_usuario=id_usuario,
        imagen_url=ruta
    )

    if resultado["status"] == "error":
        raise HTTPException(
            status_code=400,
            detail=resultado["message"]
        )

    return resultado