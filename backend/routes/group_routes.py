from flask import Blueprint, request, jsonify

from middleware.jwt_auth import jwt_required
from models.group_model import GroupModel
from services.group_service import GroupService


group_bp = Blueprint("group", __name__)

group_service = GroupService()


# =====================================================================
# CREATE GROUP
# =====================================================================

@group_bp.route("/create", methods=["POST"])
@jwt_required
def create_group():
    try:
        data = request.get_json()

        member_phone_numbers = data["member_phone_numbers"]

        group = GroupModel(
            group_name=data["group_name"],
            created_by=request.user["user_id"],
        )

        result = group_service.create_group(
            group,
            member_phone_numbers,
        )

        return jsonify(result), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# =====================================================================
# ADD MEMBERS TO EXISTING GROUP
# =====================================================================

@group_bp.route("/<group_id>/add-members", methods=["POST"])
@jwt_required
def add_members(group_id):
    try:
        data = request.get_json()

        member_phone_numbers = data["member_phone_numbers"]

        result = group_service.add_members(
            group_id=group_id,
            user_id=request.user["user_id"],
            member_phone_numbers=member_phone_numbers,
        )

        return jsonify(result), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# =====================================================================
# JOIN GROUP USING INVITE CODE
# =====================================================================

@group_bp.route("/join", methods=["POST"])
@jwt_required
def join_group():
    try:
        data = request.get_json()

        invite_code = data["invite_code"]

        result = group_service.join_group(
            invite_code=invite_code,
            user_id=request.user["user_id"],
        )

        return jsonify(result), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# =====================================================================
# LEAVE GROUP
# =====================================================================

@group_bp.route("/<group_id>/leave", methods=["POST"])
@jwt_required
def leave_group(group_id):
    try:
        result = group_service.leave_group(
            group_id=group_id,
            user_id=request.user["user_id"],
        )

        return jsonify(result), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# =====================================================================
# GET MY GROUPS
# =====================================================================

@group_bp.route("/my-groups", methods=["GET"])
@jwt_required
def get_my_groups():
    try:
        groups = group_service.get_user_groups(
            request.user["user_id"]
        )

        return jsonify(groups), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500