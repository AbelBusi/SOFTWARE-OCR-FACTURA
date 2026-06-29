from sqlalchemy.orm import Session

from app.models.detalle_factura import DetalleFactura

from app.repositories.detalle_factura_repository import (
    DetalleFacturaRepository
)

from app.schemas.detalle_factura import (
    DetalleFacturaCreate
)



class DetalleFacturaService:


    def __init__(self):

        self.repository = DetalleFacturaRepository()



    def crear(
        self,
        db: Session,
        datos: DetalleFacturaCreate,
        id_factura: int
    ):


        detalle = DetalleFactura(

            id_factura=id_factura,

            descripcion=datos.descripcion,

            cantidad=datos.cantidad,

            precio_unitario=datos.precio_unitario,

            subtotal=datos.subtotal
        )


        return self.repository.crear(
            db,
            detalle
        )