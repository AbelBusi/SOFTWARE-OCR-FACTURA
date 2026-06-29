from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db

from app.schemas.empresa import (
    EmpresaCreate,
    EmpresaResponse
)

from app.services.empresa_service import EmpresaService



router = APIRouter(

    prefix="/empresa",

    tags=["Empresa"]

)


service = EmpresaService()



@router.post(
    "",
    response_model=EmpresaResponse
)
def crear_empresa(

    empresa: EmpresaCreate,

    db: Session = Depends(get_db)

):

    return service.crear(
        db,
        empresa
    )