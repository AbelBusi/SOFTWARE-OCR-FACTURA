from sqlalchemy.orm import Session
from app.models.empresa import Empresa
from app.models.factura import Factura
from app.models.detalle_factura import DetalleFactura
from datetime import datetime

class InvoiceRepository:

    def __init__(self, db: Session):
        self.db = db

    def obtener_empresa_por_ruc(self, ruc: str):
        return self.db.query(Empresa).filter(Empresa.ruc == ruc).first()

    def buscar_factura_duplicada(self, id_usuario: int, ruc: str, numero_comprobante: str, total):
        """Busca una factura ya registrada por el mismo usuario que coincida con la
        que se intenta guardar. Devuelve la factura existente o None.

        Clave de negocio: número de comprobante + emisor (RUC). Cuando no hay RUC
        válido, se refuerza con el total para reducir falsos positivos.
        """
        numero = (numero_comprobante or "").strip()
        if not numero:
            return None

        query = (
            self.db.query(Factura)
            .filter(Factura.id_usuario == id_usuario)
            .filter(Factura.numero_comprobante == numero)
        )

        ruc = (ruc or "").strip()
        if ruc:
            query = query.join(Empresa, Factura.id_empresa == Empresa.id_empresa)
            query = query.filter(Empresa.ruc == ruc)
        else:
            query = query.filter(Factura.total == total)

        return query.first()

    def registrar_empresa(self, datos_empresa: dict):
        empresa = Empresa(
            ruc=datos_empresa["ruc"],
            razon_social=datos_empresa["nombre"],
            direccion=datos_empresa["direccion"]
        )
        self.db.add(empresa)
        self.db.flush()
        return empresa

    def registrar_factura(self, id_usuario: int, id_empresa: int, datos_factura: dict, imagen_url: str):
        fecha_str = datos_factura.get("fecha_emision")
        fecha_emision = datetime.strptime(fecha_str, "%Y-%m-%d").date() if fecha_str else None

        factura = Factura(
            id_usuario=id_usuario,
            id_empresa=id_empresa,
            tipo_comprobante=datos_factura.get("tipo_comprobante"),
            numero_comprobante=datos_factura.get("numero_comprobante"),
            fecha_emision=fecha_emision,
            subtotal=datos_factura.get("subtotal"),
            igv=datos_factura.get("igv"),
            total=datos_factura.get("total"),
            imagen_url=imagen_url
        )
        self.db.add(factura)
        self.db.flush()
        return factura

    def registrar_detalle(self, id_factura: int, datos_detalle: dict):
        detalle = DetalleFactura(
            id_factura=id_factura,
            descripcion=datos_detalle.get("descripcion"),
            cantidad=datos_detalle.get("cantidad"),
            precio_unitario=datos_detalle.get("precio_unitario"),
            subtotal=datos_detalle.get("subtotal")
        )
        self.db.add(detalle)

    def commit(self):
        self.db.commit()

    def rollback(self):
        self.db.rollback()