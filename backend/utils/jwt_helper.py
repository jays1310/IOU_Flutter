import jwt
from datetime import datetime, timedelta, UTC

from config import Config


def generate_token(user_id: str) -> str:
    """
    Generate a JWT token for the given user ID.
    """
    payload = {
        "user_id": user_id,
        "exp": datetime.now(UTC) + timedelta(seconds=Config.JWT_EXPIRATION),
        "iat": datetime.now(UTC),
    }

    return jwt.encode(payload, Config.SECRET_KEY, algorithm="HS256")


def verify_token(token: str):
    """
    Verify and decode a JWT token.
    Returns the payload if valid, otherwise None.
    """
    try:
        return jwt.decode(token, Config.SECRET_KEY, algorithms=["HS256"])
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None