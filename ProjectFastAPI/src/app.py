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


#@app.post('/register', status_code=status.HTTP_201_CREATED, name='Регистрация администратора')
#def create_admin(user_service: UsersService = Depends()):
#    if not user_service.check_admin():
#        return user_service.register_admin()