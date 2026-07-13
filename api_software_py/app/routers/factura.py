import io
from datetime import date

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from sqlalchemy.orm import Session


from app.database import get_db

from app.services.export_service import ExportService

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

export_service = ExportService()



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



@router.get(
    "/usuario/{id_usuario}/exportar"
)
def exportar_facturas(

    id_usuario: int,

    formato: str = "pdf",

    q: str | None = None,

    fecha: date | None = None,

    db: Session = Depends(get_db)

):

    formato = (formato or "").lower()

    if formato not in export_service.formatos_disponibles():

        raise HTTPException(
            status_code=400,
            detail="Formato no soportado. Use 'pdf' o 'excel'."
        )

    filas = service.listar_con_empresa(db, id_usuario, q=q, fecha=fecha)
    fecha_str = fecha.isoformat() if fecha else None
    contenido = export_service.exportar_general(filas, formato, q=q, fecha=fecha_str)

    sello = date.today().isoformat()
    nombre = f"facturas_{sello}.{export_service.extension(formato)}"

    return StreamingResponse(
        io.BytesIO(contenido),
        media_type=export_service.media_type(formato),
        headers={"Content-Disposition": f"attachment; filename={nombre}"}
    )



@router.get(
    "/{id_factura}/exportar"
)
def exportar_factura_individual(

    id_factura: int,

    formato: str = "pdf",

    db: Session = Depends(get_db)

):

    formato = (formato or "").lower()

    if formato not in export_service.formatos_disponibles():

        raise HTTPException(
            status_code=400,
            detail="Formato no soportado. Use 'pdf' o 'excel'."
        )

    factura = service.obtener_completa(db, id_factura)

    if not factura:

        raise HTTPException(
            status_code=404,
            detail="Factura no encontrada"
        )

    contenido = export_service.exportar_individual(factura, formato)

    sello = date.today().isoformat()
    nombre = f"factura_{id_factura}_{sello}.{export_service.extension(formato)}"

    return StreamingResponse(
        io.BytesIO(contenido),
        media_type=export_service.media_type(formato),
        headers={"Content-Disposition": f"attachment; filename={nombre}"}
    )