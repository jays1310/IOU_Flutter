from database.mongo import MongoDB
from models.user_model import UserModel
from utils.password_helper import hash_password, verify_password
from utils.jwt_helper import generate_token
from bson import ObjectId


class AuthService:
    def __init__(self):
        self.db = MongoDB.get_database()
        self.users = self.db["users"]

    def sign_up(self, user: UserModel):
        # Check if email already exists
        if self.users.find_one({"email": user.email}):
            raise ValueError("Email already exists.")

        # Check if phone number already exists
        if self.users.find_one({"phoneNumber": user.phone_number}):
            raise ValueError("Phone number already exists.")

        # Hash password before saving
        user.password = hash_password(user.password)

        # Save user
        result = self.users.insert_one(user.to_dict())

        # Generate JWT
        token = generate_token(str(result.inserted_id))

        return {
            "message": "User registered successfully.",
            "token": token,
        }

    def login(self, email: str, password: str):
        user_data = self.users.find_one({"email": email})

        if not user_data:
            raise ValueError("Invalid email or password.")

        user = UserModel.from_dict(user_data)

        if not verify_password(password, user.password):
            raise ValueError("Invalid email or password.")

        token = generate_token(user.id)

        return {
            "message": "Login successful.",
            "token": token,
        }

    def get_current_user(self, user_id: str):
        user_data = self.users.find_one({
            "_id": ObjectId(user_id)
        })

        if not user_data:
            raise ValueError("User not found.")

        return {
            "_id": str(user_data["_id"]),
            "username": user_data.get("username", ""),
            "phoneNumber": user_data.get("phoneNumber", ""),
            "email": user_data.get("email", ""),
        }

    # =========================================================
    # CHANGE PASSWORD
    # =========================================================

    def change_password(
        self,
        user_id: str,
        current_password: str,
        new_password: str,
    ):
        # -----------------------------------------------------
        # Find current user
        # -----------------------------------------------------

        user_data = self.users.find_one({
            "_id": ObjectId(user_id)
        })

        if not user_data:
            raise ValueError("User not found.")

        # -----------------------------------------------------
        # Verify current password
        # -----------------------------------------------------

        if not verify_password(
            current_password,
            user_data["password"],
        ):
            raise ValueError("Current password is incorrect.")

        # -----------------------------------------------------
        # Prevent using the same password
        # -----------------------------------------------------

        if verify_password(
            new_password,
            user_data["password"],
        ):
            raise ValueError(
                "New password must be different from your current password."
            )

        # -----------------------------------------------------
        # Hash new password
        # -----------------------------------------------------

        hashed_password = hash_password(new_password)

        # -----------------------------------------------------
        # Update password
        # -----------------------------------------------------

        self.users.update_one(
            {
                "_id": ObjectId(user_id)
            },
            {
                "$set": {
                    "password": hashed_password
                }
            },
        )

        return {
            "message": "Password changed successfully."
        }


    # =========================================================
    # FORGOT PASSWORD
    # =========================================================

    def check_phone_number(self, phone_number: str):
        user_data = self.users.find_one({
            "phoneNumber": phone_number
        })

        if not user_data:
            raise ValueError("No account found with this phone number.")

        return {
            "_id": str(user_data["_id"]),
            "username": user_data.get("username", ""),
            "phoneNumber": user_data.get("phoneNumber", ""),
            "email": user_data.get("email", ""),
        }

    def reset_password(self, phone_number: str, new_password: str):
        user_data = self.users.find_one({
            "phoneNumber": phone_number
        })

        if not user_data:
            raise ValueError("No account found with this phone number.")

        hashed_password = hash_password(new_password)

        self.users.update_one(
            {
                "_id": user_data["_id"]
            },
            {
                "$set": {
                    "password": hashed_password
                }
            },
        )

        return {
            "message": "Password changed successfully."
        }