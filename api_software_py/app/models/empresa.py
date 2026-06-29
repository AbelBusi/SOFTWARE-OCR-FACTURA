from sqlalchemy import Column, Integer, String

from app.database import Base


class Empresa(Base):

    __tablename__ = "empresa"

    id_empresa = Column(
        Integer,
        primary_key=True,
        index=True
    )

    ruc = Column(
        String(11),
        unique=True,
        nullable=False
    )

    razon_social = Column(
        String(150),
        nullable=False
    )

    direccion = Column(
        String(200)
    )