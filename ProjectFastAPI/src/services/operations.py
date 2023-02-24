import csv
from datetime import datetime
from io import StringIO

from fastapi import Depends

from sqlalchemy.orm import Session
from src.db.db import get_session
from src.models.operation import Operation
from src.models.schemas.operation.operation_request import OperationRequest


class OperationsService:
    def __init__(self, session: Session = Depends(get_session)):
        self.session = session

    def all(self) -> list[Operation]:
        operations = (
            self.session
            .query(Operation)
            .order_by(
                Operation.id.asc()
            )
            .all()
        )
        return operations

    def get(self, operation_id: int) -> Operation:
        operation = (
            self.session
            .query(Operation)
            .where(
                Operation.id == operation_id
            )
            .first()
        )
        return operation

    def all_operations_for_tank(self, tank_id: int) -> Operation:
        operation = (
            self.session
            .query(Operation)
            .where(
                Operation.tank_id == tank_id
            )
            .all()
        )
        return operation

    def download(
            self,
            tank_id: int,
            product_id: int,
            date_start: datetime,
            date_end: datetime
    ) -> StringIO:
        operations = (
            self.session
            .query(Operation)
            .filter(
                Operation.tank_id == tank_id,
                Operation.product_id == product_id,
                Operation.date_start.between(date_start, date_end),
                Operation.date_end.between(date_start, date_end),
            )
            .all()
        )

        headers_list = ["id", "mass", "date_start",
                        "date_end", "tank_id", "product_id",
                        "created_at", "created_by", "modified_at",
                        "modified_by"]

        output = StringIO()
        writer = csv.DictWriter(output, fieldnames=headers_list)
        writer.writeheader()
        for op in operations:
            writer.writerow(
                {
                    "id": op.id,
                    "mass": op.mass,
                    "date_start": op.date_start,
                    "date_end": op.date_end,
                    "tank_id": op.tank_id,
                    "product_id": op.product_id,
                    "created_at": op.created_at,
                    "created_by": op.created_by,
                    "modified_at": op.modified_at,
                    "modified_by": op.modified_by,
                }
            )
        output.seek(0)
        return output

    def add(self,
            operation_schema: OperationRequest,
            user_id: int) -> Operation:
        operation = Operation(
            **operation_schema.dict(),
            created_by=user_id,
            modified_by=user_id,
        )
        self.session.add(operation)
        self.session.commit()
        return operation

    def update(self,
               operation_id: int,
               operation_schema: OperationRequest,
               user_id: int) -> Operation:
        operation = self.get(operation_id)
        for field, value in operation_schema:
            setattr(operation, field, value)
        setattr(operation, 'modified_by', user_id)
        self.session.commit()
        return operation

    def delete(self, operation_id: int):
        operation = self.get(operation_id)
        self.session.delete(operation)
        self.session.commit()
