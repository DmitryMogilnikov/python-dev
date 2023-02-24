from fastapi import APIRouter, status, Depends, HTTPException
from fastapi.security import OAuth2PasswordRequestForm

from src.models.schemas.user.user_request import UserRequest
from src.models.schemas.user.user_response import UserResponse
from src.models.schemas.utils.jwt_token import JwtToken
from src.services.role_checker import RoleChecker
from src.services.users import UsersService

router = APIRouter(
    prefix='/users',
    tags=['users'],
)

allow_to_create_resource = RoleChecker(['admin'])


def check_admin(users_service: UsersService):
    if users_service.check_admin():
        raise HTTPException(status_code=status.HTTP_302_FOUND, detail="Администратор существует")
    return users_service.register_admin()


@router.post('/startup',
             status_code=status.HTTP_201_CREATED,
             name='Регистрация администратора')
def create_admin(users_service: UsersService = Depends()):
    return check_admin(users_service)


@router.post('/register',
             status_code=status.HTTP_201_CREATED,
             name='Регистрация пользователя',
             dependencies=[Depends(allow_to_create_resource)])
def register(user_schema: UserRequest, users_service: UsersService = Depends()):
    return users_service.register(user_schema)


@router.post('/authorize',
             response_model=JwtToken,
             name='Авторизация',)
def authorize(auth_schema: OAuth2PasswordRequestForm = Depends(), users_service: UsersService = Depends()):
    result = users_service.authorize(auth_schema.username, auth_schema.password)
    if not result:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail='Не авторизован')
    return result


@router.get('/all',
            response_model=list[UserResponse],
            name="Получить список всех пользователей",
            dependencies=[Depends(allow_to_create_resource)])
def get(users_service: UsersService = Depends()):
    return users_service.all()


def get_with_check(user_id: int, user_service: UsersService):
    result = user_service.get(user_id)
    if not result:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Пользователь не найден")
    return result


@router.get('/get/{user_id}',
            response_model=UserResponse,
            name="Получить одного пользователя",
            dependencies=[Depends(allow_to_create_resource)])
def get(user_id: int, users_service: UsersService = Depends()):
    return get_with_check(user_id, users_service)


@router.put('/{user_id}',
            response_model=UserResponse,
            name="Обновить информацию о пользователе",
            dependencies=[Depends(allow_to_create_resource)])
def put(user_id: int, user_schema: UserRequest, users_service: UsersService = Depends()):
    get_with_check(user_id, users_service)
    return users_service.update(user_id, user_schema)


@router.delete('/{user_id}',
               status_code=status.HTTP_204_NO_CONTENT,
               name="Удалить пользователя",
               dependencies=[Depends(allow_to_create_resource)])
def delete(user_id: int, users_service: UsersService = Depends()):
    get_with_check(user_id, users_service)
    return users_service.delete(user_id)


