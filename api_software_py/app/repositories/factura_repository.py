from sqlalchemy import or_
from sqlalchemy.orm import Session, joinedload

from app.models.factura import Factura
from app.models.empresa import Empresa


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



    def obtener_completa(
        self,
        db: Session,
        id_factura: int
    ):

        return (
            db.query(Factura)
            .options(
                joinedload(Factura.detalles),
                joinedload(Factura.empresa)
            )
            .filter(
                Factura.id_factura == id_factura
            )
            .first()
        )



    def _query_filtrada(
        self,
        db: Session,
        id_usuario: int,
        q: str = None,
        fecha=None
    ):
        """Construye la consulta filtrada (reutilizada por listado y exportación).

        Los filtros son opcionales y se aplican en la base de datos para mantener
        el rendimiento:

        - ``q``: texto libre que coincide con proveedor (razón social), RUC o
          número de comprobante.
        - ``fecha``: fecha de emisión exacta.
        """
        query = (
            db.query(Factura)
            .outerjoin(Empresa, Factura.id_empresa == Empresa.id_empresa)
            .filter(Factura.id_usuario == id_usuario)
        )

        if q:
            patron = f"%{q.strip()}%"
            query = query.filter(
                or_(
                    Empresa.razon_social.ilike(patron),
                    Empresa.ruc.ilike(patron),
                    Factura.numero_comprobante.ilike(patron),
                )
            )

        if fecha:
            query = query.filter(Factura.fecha_emision == fecha)

        return query.order_by(Factura.id_factura.desc())

    def listar_por_usuario(
        self,
        db: Session,
        id_usuario: int,
        q: str = None,
        fecha=None
    ):
        return self._query_filtrada(db, id_usuario, q, fecha).all()

    def listar_con_empresa(
        self,
        db: Session,
        id_usuario: int,
        q: str = None,
        fecha=None
    ):
        """Devuelve filas ``(Factura, Empresa)`` para reportes/exportación,
        aplicando exactamente los mismos filtros que el listado."""
        return (
            self._query_filtrada(db, id_usuario, q, fecha)
            .add_entity(Empresa)
            .all()
        )