from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.chat import ChatRequest, ChatResponse
from app.services.chat_service import ChatService

router = APIRouter(
    prefix="/chat",
    tags=["Chat"]
)

service = ChatService()


@router.post("", response_model=ChatResponse)
def conversar(
    payload: ChatRequest,
    db: Session = Depends(get_db)
):
    pregunta = (payload.pregunta or "").strip()

    if not pregunta:
        raise HTTPException(
            status_code=400,
            detail="La pregunta no puede estar vacía."
        )

    try:
        respuesta = service.responder(
            db=db,
            id_usuario=payload.id_usuario,
            pregunta=pregunta,
            historial=[m.model_dump() for m in payload.historial]
        )
    except Exception:
        raise HTTPException(
            status_code=503,
            detail="El asistente no está disponible en este momento. Inténtalo de nuevo en unos segundos."
        )

    return ChatResponse(respuesta=respuesta)
