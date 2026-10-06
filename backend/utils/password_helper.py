from flask_bcrypt import Bcrypt


bcrypt = Bcrypt()


def hash_password(password: str) -> str:
    """
    Hash a plain text password.
    """
    return bcrypt.generate_password_hash(password).decode("utf-8")


def verify_password(password: str, hashed_password: str) -> bool:
    """
    Verify a plain text password against its hash.
    """
    return bcrypt.check_password_hash(hashed_password, password)