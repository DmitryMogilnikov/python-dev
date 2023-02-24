from fastapi import Depends, HTTPException, status

from src.models.user import User
from src.services.users import get_current_user_role, get_current_user_id


class RoleChecker:
    def __init__(self, allowed_roles: list):
        self.allowed_roles = allowed_roles

    def __call__(self, user: User = Depends(get_current_user_role)):
        if user not in self.allowed_roles:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Операция запрещена")
