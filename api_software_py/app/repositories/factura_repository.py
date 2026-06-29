from sqlalchemy.orm import Session

from app.models.factura import Factura


class FacturaRepository:


    def crear(
        self,
        db: Session,
        factura: Factura
    ):

        db.add(factura)

        db.commit()

        db.refresh(factura)

        return factura



    def listar_por_usuario(
        self,
        db: Session,
        id_usuario: int
    ):

        return (
            db.query(Factura)
            .filter(
                Factura.id_usuario == id_usuario
            )
            .all()
        )