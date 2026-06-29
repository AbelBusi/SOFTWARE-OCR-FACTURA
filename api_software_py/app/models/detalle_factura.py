from sqlalchemy import (
    Column,
    Integer,
    String,
    DECIMAL,
    ForeignKey
)

from sqlalchemy.orm import relationship


from app.database import Base


class DetalleFactura(Base):

    __tablename__ = "detalle_factura"


    id_detalle = Column(
        Integer,
        primary_key=True,
        index=True
    )


    id_factura = Column(
        Integer,
        ForeignKey("factura.id_factura"),
        nullable=False
    )


    descripcion = Column(
        String(200)
    )


    cantidad = Column(
        DECIMAL(10,2)
    )


    precio_unitario = Column(
        DECIMAL(10,2)
    )


    subtotal = Column(
        DECIMAL(10,2)
    )

    factura = relationship(
        "Factura",
        back_populates="detalles"
    )