from flask import Blueprint, request, jsonify

from database.mongo import MongoDB

contacts_bp = Blueprint("contacts", __name__)

db = MongoDB.get_database()
users = db["users"]


@contacts_bp.route("/registered", methods=["POST"])
def get_registered_contacts():
    data = request.get_json()

    phone_numbers = data.get("phoneNumbers", [])

    registered_users = list(
        users.find(
            {
                "phoneNumber": {
                    "$in": phone_numbers
                }
            },
            {
                "_id": 1,
                "username": 1,
                "phoneNumber": 1,
                "email": 1,
            },
        )
    )

    # ------------------------------------------------------------
    # Convert MongoDB ObjectId into a String
    # ------------------------------------------------------------

    for user in registered_users:
        user["_id"] = str(user["_id"])

    print("\n========== REGISTERED USERS ==========")

    for user in registered_users:
        print(user)

    print("======================================\n")

    return jsonify(registered_users)