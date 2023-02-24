from typing import Optional

from pydantic import BaseModel
from datetime import datetime

from src.models.schemas.product.product_response import ProductResponse
from src.models.schemas.tank.tank_response import TankResponse


class OperationResponseBase(BaseModel):
    id: int
    mass: float
    date_start: datetime
    date_end: datetime
    tank_id: int
    product_id: int
    created_at: datetime
    created_by: int
    modified_at: datetime
    modified_by: int

    class Config:
        orm_mode = True


class OperationResponse(OperationResponseBase):
    tank: Optional[TankResponse]
    product: Optional[ProductResponse]
