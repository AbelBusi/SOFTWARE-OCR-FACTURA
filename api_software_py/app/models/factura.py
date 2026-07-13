from sqlalchemy import (
    Column,
    Integer,
    String,
    Date,
    DECIMAL,
    TIMESTAMP,
    ForeignKey,
    func
)

from sqlalchemy.orm import relationship

from app.database import Base


class Factura(Base):

    __tablename__ = "factura"


    id_factura = Column(
        Integer,
        primary_key=True,
        index=True
    )


    id_usuario = Column(
        Integer,
        ForeignKey("usuario.id_usuario"),
        nullable=False
    )


    id_empresa = Column(
        Integer,
        ForeignKey("empresa.id_empresa")
    )


    tipo_comprobante = Column(
        String(50)
    )


    numero_comprobante = Column(
        String(50)
    )


    fecha_emision = Column(
        Date
    )


    subtotal = Column(
        DECIMAL(10,2)
    )


    igv = Column(
        DECIMAL(10,2)
    )


    total = Column(
        DECIMAL(10,2)
    )


    imagen_url = Column(
        String(255)
    )


    estado = Column(
        Integer,
        nullable=False,
        server_default="1"
    )


    observaciones = Column(
        String(255)
    )


    fecha_registro = Column(
        TIMESTAMP,
        server_default=func.now()
    )


    # relación con detalle_factura
    detalles = relationship(
        "DetalleFactura",
        back_populates="factura",
        cascade="all, delete-orphan"
    )


    empresa = relationship("Empresa")