from sqlalchemy import Column, Integer, DateTime, String, func, ForeignKey
from sqlalchemy.orm import relationship

from src.models.base import Base


class Product(Base):
    __tablename__ = 'products'
    id = Column(Integer, primary_key=True)
    name = Column(String)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    created_by = Column(Integer, ForeignKey('users.id'),
                        default=0, nullable=False)
    modified_at = Column(DateTime, server_default=func.now(),
                         onupdate=func.now(), nullable=False)
    modified_by = Column(Integer, ForeignKey('users.id'),
                         default=0, nullable=False)

    operation = relationship('Operation', back_populates='product')
