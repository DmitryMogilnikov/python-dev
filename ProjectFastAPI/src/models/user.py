from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, func

from src.models.base import Base


class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    username = Column(String, nullable=False)
    password_hash = Column(String, nullable=False)
    role = Column(String, default='viewer')
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    created_by = Column(Integer, ForeignKey('users.id'),
                        default=1, nullable=False)
    modified_at = Column(DateTime, server_default=func.now(),
                         onupdate=func.now(), nullable=False)
    modified_by = Column(Integer, ForeignKey('users.id'),
                         default=1, nullable=False)
