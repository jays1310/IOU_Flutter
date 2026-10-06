from flask import Blueprint, request, jsonify

from models.user_model import UserModel
from services.auth_service import AuthService
from middleware.jwt_auth import jwt_required

auth_bp = Blueprint("auth", __name__)

auth_service = AuthService()


@auth_bp.route("/signup", methods=["POST"])
def signup():
    try:
        data = request.get_json()

        user = UserModel(
            username=data["username"],
            phone_number=data["phoneNumber"],
            email=data["email"],
            password=data["password"],
        )

        result = auth_service.sign_up(user)

        return jsonify(result), 201

    except ValueError as e:
        return jsonify({
            "error": str(e)
        }), 400

    except Exception as e:
        import traceback
        traceback.print_exc()

        return jsonify({
            "error": str(e)
        }), 500


@auth_bp.route("/login", methods=["POST"])
def login():
    try:
        data = request.get_json()

        result = auth_service.login(
            email=data["email"],
            password=data["password"],
        )

        return jsonify(result), 200

    except ValueError as e:
        return jsonify({"error": str(e)}), 401

    except Exception as e:
        import traceback

        traceback.print_exc()

        return jsonify({
            "error": str(e)
        }), 500


@auth_bp.route("/me", methods=["GET"])
@jwt_required
def get_current_user():
    try:
        user = auth_service.get_current_user(
            request.user["user_id"]
        )

        return jsonify(user), 200

    except ValueError as e:
        return jsonify({
            "error": str(e)
        }), 404

    except Exception as e:
        import traceback
        traceback.print_exc()

        return jsonify({
            "error": str(e)
        }), 500

# =========================================================
# CHANGE PASSWORD
# =========================================================

@auth_bp.route("/change-password", methods=["PUT"])
@jwt_required
def change_password():
    try:
        data = request.get_json()

        current_password = data.get("currentPassword")
        new_password = data.get("newPassword")

        if not current_password or not new_password:
            return jsonify({
                "error": "Current password and new password are required."
            }), 400

        result = auth_service.change_password(
            user_id=request.user["user_id"],
            current_password=current_password,
            new_password=new_password,
        )

        return jsonify(result), 200

    except ValueError as e:
        return jsonify({
            "error": str(e)
        }), 400

    except Exception as e:
        import traceback
        traceback.print_exc()

        return jsonify({
            "error": str(e)
        }), 500

# =========================================================
# FORGOT PASSWORD - CHECK PHONE NUMBER
# =========================================================

@auth_bp.route("/forgot-password/check-phone", methods=["POST"])
def check_forgot_password_phone():
    try:
        data = request.get_json()

        phone_number = data.get("phoneNumber")

        if not phone_number:
            return jsonify({
                "error": "Phone number is required."
            }), 400

        result = auth_service.check_phone_number(phone_number)

        return jsonify(result), 200

    except ValueError as e:
        return jsonify({
            "error": str(e)
        }), 404

    except Exception as e:
        import traceback
        traceback.print_exc()

        return jsonify({
            "error": str(e)
        }), 500


# =========================================================
# FORGOT PASSWORD - RESET PASSWORD
# =========================================================

@auth_bp.route("/forgot-password/reset", methods=["PUT"])
def reset_forgot_password():
    try:
        data = request.get_json()

        phone_number = data.get("phoneNumber")
        new_password = data.get("newPassword")

        if not phone_number or not new_password:
            return jsonify({
                "error": "Phone number and new password are required."
            }), 400

        result = auth_service.reset_password(
            phone_number=phone_number,
            new_password=new_password,
        )

        return jsonify(result), 200

    except ValueError as e:
        return jsonify({
            "error": str(e)
        }), 404

    except Exception as e:
        import traceback
        traceback.print_exc()

        return jsonify({
            "error": str(e)
        }), 500