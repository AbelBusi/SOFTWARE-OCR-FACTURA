from abc import ABC, abstractmethod

from openai import OpenAI

from app.config import settings


class AIChatProvider(ABC):

    @abstractmethod
    def responder(self, mensajes: list[dict]) -> str:
        ...


class GroqChatProvider(AIChatProvider):

    def __init__(self):
        self.client = OpenAI(
            api_key=settings.GROQ_API_KEY_CHATBOT,
            base_url="https://api.groq.com/openai/v1"
        )
        self.model = "llama-3.3-70b-versatile"

    def responder(self, mensajes: list[dict]) -> str:
        response = self.client.chat.completions.create(
            model=self.model,
            temperature=0.3,
            timeout=30,
            messages=mensajes
        )
        return response.choices[0].message.content.strip()


def obtener_proveedor() -> AIChatProvider:
    return GroqChatProvider()
