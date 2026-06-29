from pydantic import BaseModel

from app.schemas.usuario import UsuarioResponse


class LoginResponse(BaseModel):
    access_token: str
    token_type: str
    usuario: UsuarioResponse
