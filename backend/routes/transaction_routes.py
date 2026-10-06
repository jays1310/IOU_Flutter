from flask import Blueprint, jsonify, request
import traceback

from middleware.jwt_auth import jwt_required
from models.transaction_model import TransactionModel
from services.transaction_service import TransactionService


transaction_bp = Blueprint(
    "transaction",
    __name__,
)

transaction_service = TransactionService()


@transaction_bp.route("/expense", methods=["POST"])
@jwt_required
def create_expense():
    try:
        data = request.get_json()

        transaction = TransactionModel(
            group_id=data["group_id"],
            transaction_type="expense",
            description=data["description"],
            amount=float(data["amount"]),
            created_by=request.user["user_id"],
            paid_by=data["paid_by"],
            split_type=data["split_type"],
            split_details=data["split_details"],
        )

        result = transaction_service.create_expense(
            transaction
        )

        return jsonify(result), 201

    except Exception as e:
        print("\n========== CREATE EXPENSE ERROR ==========")
        print(str(e))
        traceback.print_exc()
        print("==========================================\n")

        return jsonify({
            "error": str(e)
        }), 500


@transaction_bp.route("/settlement", methods=["POST"])
@jwt_required
def create_settlement():
    try:
        data = request.get_json()

        result = transaction_service.create_settlement(
            group_id=data["group_id"],
            payer_id=request.user["user_id"],
            receiver_id=data["receiver_id"],
            amount=float(data["amount"]),
        )

        return jsonify(result), 201

    except Exception as e:
        print("\n========== CREATE SETTLEMENT ERROR ==========")
        print(str(e))
        traceback.print_exc()
        print("==============================================\n")

        return jsonify({
            "error": str(e)
        }), 500


@transaction_bp.route("/group/<group_id>", methods=["GET"])
@jwt_required
def get_group_transactions(group_id):
    try:
        transactions = transaction_service.get_group_transactions(
            group_id=group_id,
            user_id=request.user["user_id"],
        )

        return jsonify(transactions), 200

    except Exception as e:
        print("\n========== GET TRANSACTIONS ERROR ==========")
        print(str(e))
        traceback.print_exc()
        print("============================================\n")

        return jsonify({
            "error": str(e)
        }), 500


@transaction_bp.route(
    "/group/<group_id>/balance",
    methods=["GET"],
)
@jwt_required
def get_group_balance_summary(group_id):
    try:
        balances = transaction_service.get_group_balance_summary(
            group_id=group_id,
            user_id=request.user["user_id"],
        )

        return jsonify(balances), 200

    except Exception as e:
        print("\n========== GET BALANCE SUMMARY ERROR ==========")
        print(str(e))
        traceback.print_exc()
        print("===============================================\n")

        return jsonify({
            "error": str(e)
        }), 500


# =========================================================
# INDIVIDUAL TRANSACTIONS
# =========================================================

@transaction_bp.route(
    "/individual/expense",
    methods=["POST"],
)
@jwt_required
def create_individual_expense():
    try:
        data = request.get_json()

        current_user_id = request.user["user_id"]
        individual_user_id = data["individual_user_id"]

        # -----------------------------------------------------
        # Resolve paid_by
        #
        # Flutter can send:
        #
        # current_user
        # individual_user
        # -----------------------------------------------------

        paid_by = data["paid_by"]

        if paid_by == "current_user":
            paid_by = current_user_id

        elif paid_by == "individual_user":
            paid_by = individual_user_id

        # -----------------------------------------------------
        # Resolve split detail user IDs
        #
        # Flutter can use the same markers inside split_details.
        # -----------------------------------------------------

        split_details = []

        for detail in data.get("split_details", []):

            user_id = detail["user_id"]

            if user_id == "current_user":
                user_id = current_user_id

            elif user_id == "individual_user":
                user_id = individual_user_id

            split_details.append({
                **detail,
                "user_id": user_id,
            })

        transaction = TransactionModel(
            transaction_type="expense",
            description=data["description"],
            amount=float(data["amount"]),
            created_by=current_user_id,
            individual_user_id=individual_user_id,
            paid_by=paid_by,
            split_type=data["split_type"],
            split_details=split_details,
        )

        result = transaction_service.create_individual_expense(
            transaction
        )

        return jsonify(result), 201

    except Exception as e:
        print("\n========== CREATE INDIVIDUAL EXPENSE ERROR ==========")
        print(str(e))
        traceback.print_exc()
        print("======================================================\n")

        return jsonify({
            "error": str(e)
        }), 500


@transaction_bp.route(
    "/individual/<other_user_id>",
    methods=["GET"],
)
@jwt_required
def get_individual_transactions(other_user_id):
    try:
        transactions = transaction_service.get_individual_transactions(
            user_id=request.user["user_id"],
            other_user_id=other_user_id,
        )

        return jsonify(transactions), 200

    except Exception as e:
        print("\n========== GET INDIVIDUAL TRANSACTIONS ERROR ==========")
        print(str(e))
        traceback.print_exc()
        print("========================================================\n")

        return jsonify({
            "error": str(e)
        }), 500


@transaction_bp.route(
    "/individual",
    methods=["GET"],
)
@jwt_required
def get_individual_relationships():
    try:
        relationships = transaction_service.get_individual_relationships(
            user_id=request.user["user_id"],
        )

        return jsonify(relationships), 200

    except Exception as e:
        print("\n========== GET INDIVIDUAL RELATIONSHIPS ERROR ==========")
        print(str(e))
        traceback.print_exc()
        print("=========================================================\n")

        return jsonify({
            "error": str(e)
        }), 500


@transaction_bp.route(
    "/individual/settlement",
    methods=["POST"],
)
@jwt_required
def create_individual_settlement():
    try:
        data = request.get_json()

        result = transaction_service.create_individual_settlement(
            user_id=request.user["user_id"],
            other_user_id=data["individual_user_id"],
            amount=float(data["amount"]),
        )

        return jsonify(result), 201

    except Exception as e:
        print("\n========== CREATE INDIVIDUAL SETTLEMENT ERROR ==========")
        print(str(e))
        traceback.print_exc()
        print("=========================================================\n")

        return jsonify({
            "error": str(e)
        }), 500


@transaction_bp.route(
    "/individual/<other_user_id>/balance",
    methods=["GET"],
)
@jwt_required
def get_individual_balance(other_user_id):
    try:
        balance = transaction_service.get_individual_balance(
            user_id=request.user["user_id"],
            other_user_id=other_user_id,
        )

        return jsonify(balance), 200

    except Exception as e:
        print("\n========== GET INDIVIDUAL BALANCE ERROR ==========")
        print(str(e))
        traceback.print_exc()
        print("===================================================\n")

        return jsonify({
            "error": str(e)
        }), 500