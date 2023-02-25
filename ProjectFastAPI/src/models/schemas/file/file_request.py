from datetime import datetime
from pydantic import BaseModel


class FileRequest(BaseModel):
    tank_id: int
    product_id: int
    date_start: datetime
    date_end: datetime
