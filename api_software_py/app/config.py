from pydantic_settings import BaseSettings


class Settings(BaseSettings):

    DB_HOST: str
    DB_PORT: int
    DB_USER: str
    DB_PASSWORD: str
    DB_NAME: str

    SECRET_KEY: str
    ALGORITHM: str
    ACCESS_TOKEN_EXPIRE_MINUTES: int

    GROQ_API_KEY: str
    GROQ_API_KEY_CHATBOT: str

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()