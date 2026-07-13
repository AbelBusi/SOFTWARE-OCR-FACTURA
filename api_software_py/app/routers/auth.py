from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db

from app.schemas.usuario import (
    UsuarioCreate,
    UsuarioResponse,
    UsuarioLogin,
    UsuarioPerfilResponse
)

from app.schemas.auth import LoginResponse

from app.services.usuario_service import UsuarioService

router = APIRouter(
    prefix="/auth",
    tags=["Autenticación"]
)

service = UsuarioService()


@router.post(
    "/register",
    response_model=UsuarioResponse,
    status_code=201
)
def registrar(
    usuario: UsuarioCreate,
    db: Session = Depends(get_db)
):

    try:
        return service.registrar(db, usuario)

    except ValueError as e:
        raise HTTPException(
            status_code=400,
            detail=str(e)
        )


@router.post(
    "/login",
    response_model=LoginResponse
)
def login(
    datos: UsuarioLogin,
    db: Session = Depends(get_db)
):

    try:
        return service.login(
            db,
            datos.correo,
            datos.password
        )

    except ValueError as e:
        raise HTTPException(
            status_code=401,
            detail=str(e)
        )


@router.get(
    "/usuario/{id_usuario}",
    response_model=UsuarioPerfilResponse
)
def obtener_perfil(
    id_usuario: int,
    db: Session = Depends(get_db)
):

    usuario = service.obtener_perfil(db, id_usuario)

    if not usuario:
        raise HTTPException(
            status_code=404,
            detail="Usuario no encontrado"
        )

    return usuario