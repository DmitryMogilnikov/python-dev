from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import StreamingResponse

from src.models.schemas.operation.operation_request import OperationRequest
from src.models.schemas.operation.operation_response import OperationResponse, OperationResponseBase
from src.services.operations import OperationsService
from src.services.users import get_current_user_id

router = APIRouter(
    prefix='/operations',
    tags=['operations'],
)


@router.get('/all', response_model=list[OperationResponse], name="Получить список всех операций")
def get(operation_service: OperationsService = Depends(),
        user_id: int = Depends(get_current_user_id)):
    print(user_id)
    return operation_service.all()


def get_with_check(operation_id: int, operations_service: OperationsService):
    result = operations_service.get(operation_id)
    if not result:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Операция не найдена")
    return result


@router.get('/get/{operation_id}', response_model=OperationResponseBase, name="Получить одну операцию")
def get(operation_id: int,
        operations_service: OperationsService = Depends(),
        user_id: int = Depends(get_current_user_id)):
    print(user_id)
    return get_with_check(operation_id, operations_service)


@router.get('/get/{tank_id}/all_operations',
            name="Получить все операции для резервуара")
def get_all_operations(tank_id: int,
                       operations_service: OperationsService = Depends(),
                       user_id: int = Depends(get_current_user_id)):
    print(user_id)
    result = operations_service.all_operations_for_tank(tank_id)
    if not result:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Резервуар не найден")
    return result


@router.get('/download', name="Скачать данные")
def download(tank_id: int,
             product_id: int,
             date_start: datetime,
             date_end: datetime,
             operations_service: OperationsService = Depends(),
             user_id: int = Depends(get_current_user_id)):
    print(user_id)
    report = operations_service.download(tank_id, product_id, date_start, date_end)
    return StreamingResponse(report, media_type='text/csv',
                             headers={"Content-Disposition": "filename=file.csv"})


@router.post('/', response_model=OperationResponseBase, status_code=status.HTTP_201_CREATED, name="Добавить операцию")
def add(operation_schema: OperationRequest,
        operations_service: OperationsService = Depends(),
        user_id: int = Depends(get_current_user_id)):
    print(user_id)
    return operations_service.add(operation_schema)


@router.put('/{operation_id}', response_model=OperationResponseBase, name="Обновить информацию об операции")
def put(operation_id: int,
        operation_schema: OperationRequest,
        operation_service: OperationsService = Depends(),
        user_id: int = Depends(get_current_user_id)):
    print(user_id)
    get_with_check(operation_id, operation_service)
    return operation_service.update(operation_id, operation_schema)


@router.delete('/{operation_id}', status_code=status.HTTP_204_NO_CONTENT, name="Удалить операцию")
def put(operation_id: int,
        operation_service: OperationsService = Depends(),
        user_id: int = Depends(get_current_user_id)):
    print(user_id)
    get_with_check(operation_id, operation_service)
    return operation_service.delete(operation_id)
