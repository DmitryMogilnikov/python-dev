from sqlalchemy import Column, Integer, Float, DateTime, ForeignKey, func
from sqlalchemy.orm import relationship

from src.models.base import Base


class Operation(Base):
    __tablename__ = 'operations'
    id = Column(Integer, primary_key=True)
    mass = Column(Float, nullable=False)
    date_start = Column(DateTime, nullable=False)
    date_end = Column(DateTime, nullable=False)
    tank_id = Column(Integer, ForeignKey('tanks.id'), index=True)
    product_id = Column(Integer, ForeignKey('products.id'), index=True)
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    created_by = Column(Integer, default=0, nullable=False) #ForeignKey('users.id')
    modified_at = Column(DateTime, server_default=func.now(),  onupdate=func.now(), nullable=False)
    modified_by = Column(Integer, default=0, nullable=False) #ForeignKey('users.id')

    tank = relationship('Tank', back_populates='operation')
    product = relationship('Product', back_populates='operation')
