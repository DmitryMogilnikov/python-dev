from fastapi import APIRouter, Depends, HTTPException, status

from src.models.schemas.product.product_request import ProductRequest
from src.models.schemas.product.product_response import ProductResponse
from src.services.products import ProductsService
from src.services.users import get_current_user_id

router = APIRouter(
    prefix='/products',
    tags=['products'],
)


@router.get('/all', response_model=list[ProductResponse],
            name="Получить список всех продуктов")
def get_all(products_service: ProductsService = Depends(),
            user_id: int = Depends(get_current_user_id)):
    print(user_id)
    return products_service.all()


def get_with_check(product_id: int, products_service: ProductsService):
    result = products_service.get(product_id)
    if not result:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                            detail="Продукт не найден")
    return result


@router.get('/get/{product_id}', response_model=ProductResponse,
            name="Получить один продукт")
def get(product_id: int,
        products_service: ProductsService = Depends(),
        user_id: int = Depends(get_current_user_id)):
    print(user_id)
    return get_with_check(product_id, products_service)


@router.post('/', response_model=ProductResponse,
             status_code=status.HTTP_201_CREATED,
             name="Добавить продукт")
def add(product_schema: ProductRequest,
        product_service: ProductsService = Depends(),
        user_id: int = Depends(get_current_user_id)):
    print(user_id)
    return product_service.add(product_schema, user_id)


@router.put('/{product_id}',
            response_model=ProductResponse,
            name="Обновить информацию о продукте")
def put(product_id: int,
        product_schema: ProductRequest,
        products_service: ProductsService = Depends(),
        user_id: int = Depends(get_current_user_id)):
    print(user_id)
    get_with_check(product_id, products_service)
    return products_service.update(product_id, product_schema, user_id)


@router.delete('/{product_id}',
               status_code=status.HTTP_204_NO_CONTENT,
               name="Удалить продукт")
def delete(product_id: int,
           products_service: ProductsService = Depends(),
           user_id: int = Depends(get_current_user_id)):
    print(user_id)
    get_with_check(product_id, products_service)
    return products_service.delete(product_id)
