from functools import wraps

from flask import request, jsonify

from utils.jwt_helper import verify_token


def jwt_required(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        auth_header = request.headers.get("Authorization")

        if not auth_header:
            return jsonify({"error": "Authorization header is missing."}), 401

        if not auth_header.startswith("Bearer "):
            return jsonify({"error": "Invalid authorization format."}), 401

        token = auth_header.split(" ")[1]

        payload = verify_token(token)

        if payload is None:
            return jsonify({"error": "Invalid or expired token."}), 401

        request.user = payload

        return func(*args, **kwargs)

    return wrapper