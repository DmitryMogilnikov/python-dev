from datetime import datetime, timedelta
from typing import Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from passlib.handlers.pbkdf2 import pbkdf2_sha256
from jose import JWTError, jwt

from src.core.settings import settings
from src.models.schemas.user.user_request import UserRequest
from src.models.schemas.utils.jwt_token import JwtToken
from sqlalchemy.orm import Session
from src.db.db import get_session
from src.models.user import User

oauth2_schema = OAuth2PasswordBearer(tokenUrl='/users/authorize')


def get_current_user_id(token: str = Depends(oauth2_schema)) -> int:
    user_id = UsersService.verify_token_id(token)
    return user_id


def get_current_user_role(token: str = Depends(oauth2_schema)) -> str:
    return UsersService.verify_token_role(token)


class UsersService:
    def __init__(self, session: Session = Depends(get_session)):
        self.session = session

    @staticmethod
    def hash_password(password: str) -> str:
        return pbkdf2_sha256.hash(password)

    @staticmethod
    def check_password(password_text: str, password_hash: str) -> bool:
        return pbkdf2_sha256.verify(password_text, password_hash)

    @staticmethod
    def verify_token_id(token: str) -> Optional[int]:
        try:
            payload = jwt.decode(token, settings.jwt_secret,
                                 algorithms=[settings.jwt_algorithm])
        except JWTError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail='Некорректный токен'
            )

        return payload.get('sub')

    @staticmethod
    def verify_token_role(token: str) -> Optional[str]:
        try:
            payload = jwt.decode(token, settings.jwt_secret,
                                 algorithms=[settings.jwt_algorithm])
        except JWTError:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail='Некорректный токен'
            )

        return payload.get('role')

    @staticmethod
    def create_token(user_id: int, role: str) -> JwtToken:
        now = datetime.utcnow()
        payload = {
            'iat': now,
            'exp': now + timedelta(seconds=settings.jwt_expires_seconds),
            'sub': str(user_id),
            'role': str(role),
        }
        token = jwt.encode(payload, settings.jwt_secret,
                           algorithm=settings.jwt_algorithm)
        return JwtToken(access_token=token)

    def register(self, user_schema: UserRequest, creator_user_id: int) -> User:
        user = User(
            username=user_schema.username,
            password_hash=self.hash_password(user_schema.password_text),
            created_by=creator_user_id,
            modified_by=creator_user_id
        )
        self.session.add(user)
        self.session.commit()

    def authorize(self,
                  username: str,
                  password_text: str) -> Optional[JwtToken]:
        user = (
            self.session
            .query(User)
            .filter(User.username == username)
            .first()
        )

        if not user:
            return None
        if not self.check_password(password_text, user.password_hash):
            return None

        return self.create_token(user.id, user.role)

    def all(self) -> list[User]:
        user = (
            self.session
            .query(User)
            .order_by(
                User.id.asc()
            )
            .all()
        )
        return user

    def get(self, user_id: int) -> User:
        user = (
            self.session
            .query(User)
            .filter(
                User.id == user_id
            )
            .first()
        )
        return user

    def update(self,
               user_id: int,
               user_schema: UserRequest,
               creator_user_id: int) -> User:
        user = self.get(user_id)
        for field, value in user_schema:
            setattr(user, field, value)
        setattr(user, 'modified_by', creator_user_id)
        self.session.commit()
        return user

    def delete(self, user_id: int):
        user = self.get(user_id)
        self.session.delete(user)
        self.session.commit()
