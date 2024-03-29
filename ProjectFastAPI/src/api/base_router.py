from fastapi import APIRouter

from src.api import products, users, operations, tanks

router = APIRouter()
router.include_router(users.router)
router.include_router(products.router)
router.include_router(tanks.router)
router.include_router(operations.router)
