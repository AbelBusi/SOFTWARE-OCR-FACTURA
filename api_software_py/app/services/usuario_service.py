from sqlalchemy.orm import Session

from app.models.usuario import Usuario
from app.repositories.usuario_repository import UsuarioRepository
from app.schemas.usuario import UsuarioCreate
from app.security.password import hash_password

from app.security.jwt import create_access_token
from app.security.password import verify_password

from app.schemas.auth import LoginResponse
from app.schemas.usuario import UsuarioResponse


class UsuarioService:

    def __init__(self):
        self.repository = UsuarioRepository()

    def registrar(self, db: Session, datos: UsuarioCreate):

        # Verificar correo
        usuario = self.repository.obtener_por_correo(db, datos.correo)

        if usuario:
            raise ValueError("El correo ya está registrado.")

        # Verificar DNI
        usuario = self.repository.obtener_por_dni(db, datos.dni)

        if usuario:
            raise ValueError("El DNI ya está registrado.")

        nuevo_usuario = Usuario(
            dni=datos.dni,
            nombres=datos.nombres,
            apellidos=datos.apellidos,
            fecha_nacimiento=datos.fecha_nacimiento,
            correo=datos.correo,
            password=hash_password(datos.password)
        )

        return self.repository.crear(db, nuevo_usuario)

    def obtener_perfil(self, db: Session, id_usuario: int):

        return self.repository.obtener_por_id(db, id_usuario)

    def login(self, db: Session, correo: str, password: str):

        usuario = self.repository.obtener_por_correo(
            db,
            correo
        )

        if not usuario:
            raise ValueError("Correo o contraseña incorrectos.")

        if not verify_password(password, usuario.password):
            raise ValueError("Correo o contraseña incorrectos.")

        token = create_access_token(
            {
                "sub": str(usuario.id_usuario)
            }
        )

        return LoginResponse(
            access_token=token,
            token_type="bearer",
            usuario=UsuarioResponse.model_validate(usuario)
        )