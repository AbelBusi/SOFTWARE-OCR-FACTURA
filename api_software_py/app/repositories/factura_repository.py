from sqlalchemy.orm import Session, joinedload

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



    def obtener_por_id(
        self,
        db: Session,
        id_factura: int
    ):

        return (
            db.query(Factura)
            .filter(
                Factura.id_factura == id_factura
            )
            .first()
        )



    def obtener_con_detalles(
        self,
        db: Session,
        id_factura: int
    ):

        return (
            db.query(Factura)
            .options(
                joinedload(Factura.detalles)
            )
            .filter(
                Factura.id_factura == id_factura
            )
            .first()
        )



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