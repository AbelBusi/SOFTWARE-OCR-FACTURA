from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session


from app.database import get_db

from app.schemas.factura import (
    FacturaCreate,
    FacturaResponse
)

from app.services.factura_service import FacturaService


router = APIRouter(

    prefix="/factura",

    tags=["Factura"]

)


service = FacturaService()



@router.post(
    "",
    response_model=FacturaResponse
)
def crear_factura(

    factura: FacturaCreate,

    db: Session = Depends(get_db)

):

    # temporalmente usamos usuario 1

    return service.crear(

        db,

        factura,

        1

    )