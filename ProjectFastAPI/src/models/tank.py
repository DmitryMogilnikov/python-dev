from sqlalchemy import (Column, DateTime, Float,
                        ForeignKey, Integer, String,
                        func)
from sqlalchemy.orm import relationship

from src.models.base import Base


class Tank(Base):
    __tablename__ = 'tanks'
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    max_capacity = Column(Float, nullable=False)
    current_capacity = Column(Float, nullable=False)
    product_id = Column(Integer, ForeignKey('products.id'),
                        index=True, nullable=False)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    created_by = Column(Integer, ForeignKey('users.id'),
                        default=0, nullable=False)
    modified_at = Column(DateTime, server_default=func.now(),
                         onupdate=func.now(), nullable=False)
    modified_by = Column(Integer, ForeignKey('users.id'),
                         default=0, nullable=False)

    operation = relationship('Operation', back_populates='tank')
