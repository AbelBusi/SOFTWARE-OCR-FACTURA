from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
import os
import shutil

from app.database import get_db
from app.services.invoice_service import InvoiceService

router = APIRouter(
    prefix="/facturas",
    tags=["Facturas"]
)

@router.post("/procesar")
def procesar_factura(
    id_usuario: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    upload_dir = "uploads"
    os.makedirs(upload_dir, exist_ok=True)
    ruta_local = os.path.join(upload_dir, file.filename)

    with open(ruta_local, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    service = InvoiceService()
    resultado = service.procesar_y_guardar(
        db=db,
        ruta_imagen=ruta_local,
        id_usuario=id_usuario,
        imagen_url=ruta_local
    )

    if resultado["status"] == "error":
        raise HTTPException(status_code=400, detail=resultado["message"])

    return resultado