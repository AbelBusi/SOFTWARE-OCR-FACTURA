from sqlalchemy.orm import Session

from app.models.factura import Factura

from app.repositories.factura_repository import FacturaRepository

from app.schemas.factura import FacturaCreate



class FacturaService:


    def __init__(self):

        self.repository = FacturaRepository()



    def crear(
        self,
        db: Session,
        datos: FacturaCreate,
        id_usuario: int
    ):


        nueva_factura = Factura(

            id_usuario=id_usuario,

            id_empresa=datos.id_empresa,

            tipo_comprobante=datos.tipo_comprobante,

            numero_comprobante=datos.numero_comprobante,

            fecha_emision=datos.fecha_emision,

            subtotal=datos.subtotal,

            igv=datos.igv,

            total=datos.total,

            imagen_url=datos.imagen_url
        )


        return self.repository.crear(
            db,
            nueva_factura
        )