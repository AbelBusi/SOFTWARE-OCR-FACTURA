from pydantic import BaseModel


class EmpresaCreate(BaseModel):

    ruc: str
    razon_social: str
    direccion: str | None = None



class EmpresaResponse(BaseModel):

    id_empresa: int
    ruc: str
    razon_social: str
    direccion: str | None


    class Config:
        from_attributes = True