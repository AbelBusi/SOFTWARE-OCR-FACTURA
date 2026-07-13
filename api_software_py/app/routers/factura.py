from datetime import date

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session


from app.database import get_db

from app.schemas.factura import (
    FacturaCreate,
    FacturaResponse
)

from app.schemas.detalle_factura import (
    DetalleFacturaResponse
)

from app.schemas.factura import (
    FacturaDetalleResponse
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


    return service.crear(

        db,

        factura,

        1

    )




@router.get(
    "/{id_factura}",
    response_model=FacturaResponse
)
def obtener_factura(

    id_factura: int,

    db: Session = Depends(get_db)

):

    factura = service.obtener_por_id(

        db,

        id_factura

    )


    if not factura:

        raise HTTPException(

            status_code=404,

            detail="Factura no encontrada"

        )


    return factura



@router.get(
    "/{id_factura}/detalles",
    response_model=FacturaDetalleResponse
)
def obtener_factura_detalles(

    id_factura: int,

    db: Session = Depends(get_db)

):

    factura = service.obtener_con_detalles(

        db,

        id_factura

    )


    if not factura:

        raise HTTPException(

            status_code=404,

            detail="Factura no encontrada"

        )


    return factura



@router.get(
    "/usuario/{id_usuario}",
    response_model=list[FacturaResponse]
)
def listar_facturas_usuario(

    id_usuario: int,

    q: str | None = None,

    fecha: date | None = None,

    db: Session = Depends(get_db)

):

    return service.listar_por_usuario(

        db,

        id_usuario,

        q=q,

        fecha=fecha

    )