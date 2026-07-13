from datetime import date, datetime
from pydantic import BaseModel, EmailStr


class UsuarioCreate(BaseModel):
    dni: str
    nombres: str
    apellidos: str
    fecha_nacimiento: date
    correo: EmailStr
    password: str


class UsuarioLogin(BaseModel):
    correo: EmailStr
    password: str


class UsuarioResponse(BaseModel):
    id_usuario: int
    dni: str
    nombres: str
    apellidos: str
    correo: EmailStr

    class Config:
        from_attributes = True


class UsuarioPerfilResponse(BaseModel):
    id_usuario: int
    dni: str
    nombres: str
    apellidos: str
    correo: EmailStr
    fecha_nacimiento: date | None = None
    fecha_registro: datetime | None = None

    class Config:
        from_attributes = True