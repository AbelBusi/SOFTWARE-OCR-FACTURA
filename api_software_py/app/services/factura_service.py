from sqlalchemy.orm import Session

from app.models.factura import Factura
from app.repositories.factura_repository import FacturaRepository
from app.repositories.invoice_repository import InvoiceRepository
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



    def obtener_por_id(
        self,
        db: Session,
        id_factura: int
    ):

        return self.repository.obtener_por_id(
            db,
            id_factura
        )



    def obtener_con_detalles(
        self,
        db: Session,
        id_factura: int
    ):

        return self.repository.obtener_con_detalles(
            db,
            id_factura
        )



    def obtener_completa(
        self,
        db: Session,
        id_factura: int
    ):

        return self.repository.obtener_completa(
            db,
            id_factura
        )



    def actualizar(
        self,
        db: Session,
        id_factura: int,
        datos_json: dict
    ):

        repo = InvoiceRepository(db)

        factura = repo.obtener_factura_activa(id_factura)

        if not factura:
            return None

        try:
            empresa = repo.resolver_empresa(dict(datos_json["empresa"]))
            repo.actualizar_factura(factura, empresa.id_empresa, datos_json["factura"])
            repo.reemplazar_detalles(factura.id_factura, datos_json["detalles"])
            repo.commit()
            return self.repository.obtener_completa(db, id_factura)
        except Exception:
            repo.rollback()
            raise



    def eliminar(
        self,
        db: Session,
        id_factura: int
    ):

        repo = InvoiceRepository(db)
        return repo.eliminar_logico(id_factura)



    def listar_por_usuario(
        self,
        db: Session,
        id_usuario: int,
        q: str = None,
        fecha=None
    ):

        return self.repository.listar_por_usuario(
            db,
            id_usuario,
            q=q,
            fecha=fecha
        )



    def listar_con_empresa(
        self,
        db: Session,
        id_usuario: int,
        q: str = None,
        fecha=None
    ):

        return self.repository.listar_con_empresa(
            db,
            id_usuario,
            q=q,
            fecha=fecha
        )