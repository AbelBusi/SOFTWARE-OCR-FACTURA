from pydantic import BaseModel, Field


class ChatMensaje(BaseModel):

    rol: str
    texto: str


class ChatRequest(BaseModel):

    id_usuario: int
    pregunta: str
    historial: list[ChatMensaje] = Field(default_factory=list)


class ChatResponse(BaseModel):

    respuesta: str
