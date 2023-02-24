from fastapi import APIRouter, Depends, HTTPException, status

from src.models.schemas.tank.tank_request import TankRequest
from src.models.schemas.tank.tank_response import TankResponse
from src.services.tanks import TanksService
from src.services.users import get_current_user_id

router = APIRouter(
    prefix='/tanks',
    tags=['tanks'],
)


@router.get('/all', response_model=list[TankResponse],
            name="Получить список всех резервуаров")
def get_all(tanks_service: TanksService = Depends(),
            user_id: int = Depends(get_current_user_id)):
    print(user_id)
    return tanks_service.all()


def get_with_check(tank_id: int, tanks_service: TanksService):
    result = tanks_service.get(tank_id)
    if not result:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail="Резервуар не найден")
    return result


@router.get('/get/{tank_id}',
            response_model=TankResponse,
            name="Получить один резервуар")
def get(tank_id: int,
        tanks_service: TanksService = Depends(),
        user_id: int = Depends(get_current_user_id)):
    print(user_id)
    return get_with_check(tank_id, tanks_service)


@router.post('/', response_model=TankResponse,
             status_code=status.HTTP_201_CREATED,
             name="Добавить резервуар")
def add(tank_schema: TankRequest,
        tanks_service: TanksService = Depends(),
        user_id: int = Depends(get_current_user_id)):
    print(user_id)
    return tanks_service.add(tank_schema, user_id)


@router.get('/get/{tank_id}/new_current_capacity',
            response_model=TankResponse,
            name="Обновить значение резервуара")
def update_capacity(tank_id: int,
                    new_current_capacity: float,
                    tanks_service: TanksService = Depends(),
                    user_id: int = Depends(get_current_user_id)):
    print(user_id)
    if get_with_check(tank_id, tanks_service):
        return tanks_service.update_capacity(tank_id,
                                             new_current_capacity,
                                             user_id)


@router.put('/{tank_id}',
            response_model=TankResponse,
            name="Обновить информацию о резервуаре")
def put(tank_id: int,
        tank_schema: TankRequest,
        tanks_service: TanksService = Depends(),
        user_id: int = Depends(get_current_user_id)):
    print(user_id)
    get_with_check(tank_id, tanks_service)
    return tanks_service.update(tank_id, tank_schema, user_id)


@router.delete('/{tank_id}',
               status_code=status.HTTP_204_NO_CONTENT,
               name="Удалить резервуар")
def delete(tank_id: int,
           tank_service: TanksService = Depends(),
           user_id: int = Depends(get_current_user_id)):
    print(user_id)
    get_with_check(tank_id, tank_service)
    return tank_service.delete(tank_id)
