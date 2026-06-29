from sqlalchemy.orm import Session

from app.models.usuario import Usuario


class UsuarioRepository:

    def obtener_por_correo(self, db: Session, correo: str):

        return (
            db.query(Usuario)
            .filter(Usuario.correo == correo)
            .first()
        )

    def obtener_por_dni(self, db: Session, dni: str):

        return (
            db.query(Usuario)
            .filter(Usuario.dni == dni)
            .first()
        )

    def crear(self, db: Session, usuario: Usuario):

        db.add(usuario)

        db.commit()

        db.refresh(usuario)

        return usuario