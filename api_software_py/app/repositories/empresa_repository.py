from sqlalchemy.orm import Session

from app.models.empresa import Empresa


class EmpresaRepository:


    def crear(
            self,
            db: Session,
            empresa: Empresa
    ):

        db.add(empresa)

        db.commit()

        db.refresh(empresa)

        return empresa



    def obtener_por_ruc(
            self,
            db: Session,
            ruc: str
    ):

        return (
            db.query(Empresa)
            .filter(
                Empresa.ruc == ruc
            )
            .first()
        )