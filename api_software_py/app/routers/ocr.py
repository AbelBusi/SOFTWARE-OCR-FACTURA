from fastapi import APIRouter, UploadFile, File
import shutil
import os


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
        file: UploadFile = File(...)
):

    ruta = f"{UPLOAD_DIR}/{file.filename}"


    with open(ruta, "wb") as buffer:

        shutil.copyfileobj(
            file.file,
            buffer
        )


    return {
        "mensaje": "Imagen recibida",
        "archivo": ruta
    }