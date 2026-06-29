from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database import get_db

from app.schemas.detalle_factura import (
    DetalleFacturaCreate,
    DetalleFacturaResponse
)

from app.services.detalle_factura_service import (
    DetalleFacturaService
)



router = APIRouter(

    prefix="/detalle-factura",

    tags=["Detalle Factura"]

)



service = DetalleFacturaService()



@router.post(
    "/{id_factura}",
    response_model=DetalleFacturaResponse
)
def crear_detalle(

    id_factura: int,

    detalle: DetalleFacturaCreate,

    db: Session = Depends(get_db)

):

    return service.crear(

        db,

        detalle,

        id_factura

    )