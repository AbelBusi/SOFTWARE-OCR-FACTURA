from fastapi import FastAPI

from app.database import Base, engine
import app.models

from app.routers.auth import router as auth_router
from app.routers.empresa import router as empresa_router

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="OCR Factura API",
    version="1.0.0"
)

app.include_router(auth_router)
app.include_router(empresa_router)


@app.get("/")
def inicio():
    return {
        "mensaje": "API funcionando correctamente"
    }