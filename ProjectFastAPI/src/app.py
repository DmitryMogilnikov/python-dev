from fastapi import FastAPI

from src.api.base_router import router
from src.db.db import Session

app = FastAPI(
    title='FastAPI приложение',
    description='Домашнее задание к спринту №6',
    version='0.0.1',
)

app.include_router(router)

session = Session()
