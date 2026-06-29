from sqlalchemy.orm import Session

from app.models.empresa import Empresa
from app.repositories.empresa_repository import EmpresaRepository
from app.schemas.empresa import EmpresaCreate


class EmpresaService:


    def __init__(self):

        self.repository = EmpresaRepository()



    def crear(
            self,
            db: Session,
            datos: EmpresaCreate
    ):

        empresa_existente = (
            self.repository
            .obtener_por_ruc(
                db,
                datos.ruc
            )
        )


        if empresa_existente:
            return empresa_existente



        nueva_empresa = Empresa(

            ruc=datos.ruc,

            razon_social=datos.razon_social,

            direccion=datos.direccion

        )


        return self.repository.crear(
            db,
            nueva_empresa
        )