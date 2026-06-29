from sqlalchemy.orm import Session

from app.models.detalle_factura import DetalleFactura


class DetalleFacturaRepository:


    def crear(
        self,
        db: Session,
        detalle: DetalleFactura
    ):

        db.add(detalle)

        db.commit()

        db.refresh(detalle)

        return detalle



    def listar_por_factura(
        self,
        db: Session,
        id_factura: int
    ):

        return (
            db.query(DetalleFactura)
            .filter(
                DetalleFactura.id_factura == id_factura
            )
            .all()
        )