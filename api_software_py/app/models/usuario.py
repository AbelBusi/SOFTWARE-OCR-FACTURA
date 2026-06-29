from sqlalchemy import Column, Integer, String, Date, TIMESTAMP, func

from app.database import Base


class Usuario(Base):
    __tablename__ = "usuario"

    id_usuario = Column(Integer, primary_key=True, index=True)

    dni = Column(String(8), unique=True, nullable=False)

    nombres = Column(String(100), nullable=False)

    apellidos = Column(String(100), nullable=False)

    fecha_nacimiento = Column(Date)

    correo = Column(String(150), unique=True, nullable=False)

    password = Column(String(255), nullable=False)

    fecha_registro = Column(
        TIMESTAMP,
        server_default=func.now()
    )