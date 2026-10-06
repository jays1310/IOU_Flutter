from bson import ObjectId

from database.mongo import MongoDB
from models.group_model import GroupModel, generate_random_invite_code


class GroupService:
    def __init__(self):
        self.db = MongoDB.get_database()
        self.groups = self.db.groups
        self.users = self.db.users
        self.transactions = self.db.transactions

    # ================================================================
    # CREATE GROUP
    # ================================================================

    def create_group(
        self,
        group: GroupModel,
        member_phone_numbers: list,
    ):
        group.invite_code = self._generate_unique_invite_code()

        members = [ObjectId(group.created_by)]

        users = self.users.find({
            "phoneNumber": {
                "$in": member_phone_numbers
            }
        })

        for user in users:
            if user["_id"] not in members:
                members.append(user["_id"])

        group.members = [str(member) for member in members]

        result = self.groups.insert_one(group.to_dict())

        created_group = self.groups.find_one({
            "_id": result.inserted_id
        })

        created_group_model = GroupModel.from_dict(
            created_group
        )

        member_details = self._get_member_details(
            created_group_model.members
        )

        return created_group_model.to_response(
            member_details=member_details
        )

    # ================================================================
    # ADD MEMBERS TO EXISTING GROUP
    # ================================================================

    def add_members(
        self,
        group_id: str,
        user_id: str,
        member_phone_numbers: list,
    ):
        # ------------------------------------------------------------
        # Validate group ID
        # ------------------------------------------------------------

        try:
            group_object_id = ObjectId(group_id)
        except Exception:
            raise Exception("Invalid group ID.")

        # ------------------------------------------------------------
        # Get group
        # ------------------------------------------------------------

        group = self.groups.find_one({
            "_id": group_object_id
        })

        if group is None:
            raise Exception("Group not found.")

        # ------------------------------------------------------------
        # Existing members
        # ------------------------------------------------------------

        existing_members = group.get("members", [])

        # Convert existing members to strings only for comparison.
        # This makes the method tolerant of old mixed-type data.
        existing_member_ids = {
            str(member)
            for member in existing_members
        }

        # ------------------------------------------------------------
        # Check whether current user belongs to the group
        # ------------------------------------------------------------

        current_user_object_id = ObjectId(user_id)

        if str(current_user_object_id) not in existing_member_ids:
            raise Exception(
                "You are not a member of this group."
            )

        # ------------------------------------------------------------
        # Find users using their phone numbers
        # ------------------------------------------------------------

        users = list(
            self.users.find({
                "phoneNumber": {
                    "$in": member_phone_numbers
                }
            })
        )

        if not users:
            raise Exception(
                "No registered users found."
            )

        # ------------------------------------------------------------
        # Normalize ALL existing members to ObjectId
        #
        # This is important because older groups may contain a
        # mixture of ObjectId and string values.
        # ------------------------------------------------------------

        normalized_members = [
            ObjectId(str(member))
            for member in existing_members
        ]

        # ------------------------------------------------------------
        # Add new members as ObjectId
        # ------------------------------------------------------------

        new_members = []

        for user in users:
            user_object_id = user["_id"]
            user_id_string = str(user_object_id)

            # Avoid duplicate members
            if user_id_string not in existing_member_ids:
                new_members.append(user_object_id)

        # ------------------------------------------------------------
        # Nothing new to add
        # ------------------------------------------------------------

        if not new_members:
            raise Exception(
                "All selected users are already members of this group."
            )

        # ------------------------------------------------------------
        # Updated members
        #
        # Every value in this list is now an ObjectId.
        # ------------------------------------------------------------

        updated_members = normalized_members + new_members

        # ------------------------------------------------------------
        # Update MongoDB
        # ------------------------------------------------------------

        self.groups.update_one(
            {
                "_id": group_object_id
            },
            {
                "$set": {
                    "members": updated_members
                }
            }
        )

        # ------------------------------------------------------------
        # Get updated group
        # ------------------------------------------------------------

        updated_group = self.groups.find_one({
            "_id": group_object_id
        })

        updated_group_model = GroupModel.from_dict(
            updated_group
        )

        member_details = self._get_member_details(
            updated_group_model.members
        )

        return updated_group_model.to_response(
            member_details=member_details
        )

    # ================================================================
    # JOIN GROUP USING INVITE CODE
    # ================================================================

    def join_group(
        self,
        invite_code: str,
        user_id: str,
    ):
        # ------------------------------------------------------------
        # Validate invite code
        # ------------------------------------------------------------

        if not invite_code:
            raise Exception("Invite code is required.")

        invite_code = invite_code.strip()

        # ------------------------------------------------------------
        # Validate user ID
        # ------------------------------------------------------------

        try:
            user_object_id = ObjectId(user_id)
        except Exception:
            raise Exception("Invalid user ID.")

        # ------------------------------------------------------------
        # Find group using invite code
        # ------------------------------------------------------------

        group = self.groups.find_one({
            "invite_code": invite_code
        })

        if group is None:
            raise Exception("Invalid invite code.")

        # ------------------------------------------------------------
        # Existing members
        # ------------------------------------------------------------

        existing_members = group.get("members", [])

        # Compare IDs using strings so this remains tolerant of
        # any older mixed-type member data.
        existing_member_ids = {
            str(member)
            for member in existing_members
        }

        user_id_string = str(user_object_id)

        # ------------------------------------------------------------
        # User is already a member
        # ------------------------------------------------------------

        if user_id_string in existing_member_ids:
            group_model = GroupModel.from_dict(group)

            member_details = self._get_member_details(
                group_model.members
            )

            return group_model.to_response(
                member_details=member_details
            )

        # ------------------------------------------------------------
        # Normalize existing members to ObjectId
        # ------------------------------------------------------------

        normalized_members = [
            ObjectId(str(member))
            for member in existing_members
        ]

        # ------------------------------------------------------------
        # Add current user
        # ------------------------------------------------------------

        normalized_members.append(user_object_id)

        # ------------------------------------------------------------
        # Update MongoDB
        # ------------------------------------------------------------

        self.groups.update_one(
            {
                "_id": group["_id"]
            },
            {
                "$set": {
                    "members": normalized_members
                }
            }
        )

        # ------------------------------------------------------------
        # Get updated group
        # ------------------------------------------------------------

        updated_group = self.groups.find_one({
            "_id": group["_id"]
        })

        if updated_group is None:
            raise Exception("Group could not be loaded after joining.")

        updated_group_model = GroupModel.from_dict(
            updated_group
        )

        member_details = self._get_member_details(
            updated_group_model.members
        )

        return updated_group_model.to_response(
            member_details=member_details
        )

    # ================================================================
    # LEAVE GROUP
    # ================================================================

    def leave_group(
        self,
        group_id: str,
        user_id: str,
    ):
        # ------------------------------------------------------------
        # Validate group ID
        # ------------------------------------------------------------

        try:
            group_object_id = ObjectId(group_id)
        except Exception:
            raise Exception("Invalid group ID.")

        # ------------------------------------------------------------
        # Get group
        # ------------------------------------------------------------

        group = self.groups.find_one({
            "_id": group_object_id
        })

        if group is None:
            raise Exception("Group not found.")

        # ------------------------------------------------------------
        # Validate user ID
        # ------------------------------------------------------------

        try:
            user_object_id = ObjectId(user_id)
        except Exception:
            raise Exception("Invalid user ID.")

        # ------------------------------------------------------------
        # Existing members
        # ------------------------------------------------------------

        existing_members = group.get("members", [])

        # ------------------------------------------------------------
        # Check whether current user belongs to the group
        #
        # Member IDs may come from older data in either string or
        # ObjectId form, so compare using string representations.
        # ------------------------------------------------------------

        user_id_string = str(user_object_id)

        if not any(
            str(member) == user_id_string
            for member in existing_members
        ):
            raise Exception(
                "You are not a member of this group."
            )

        # ------------------------------------------------------------
        # Check whether current user is the group creator/admin
        # ------------------------------------------------------------

        created_by = group.get("created_by")

        is_admin = str(created_by) == user_id_string

        # ------------------------------------------------------------
        # ADMIN + ONLY MEMBER
        #
        # If the creator is the only member, leaving the group means
        # there would be no members left. In this case, delete the
        # entire group instead.
        # ------------------------------------------------------------

        if is_admin and len(existing_members) == 1:
            self.groups.delete_one({
                "_id": group_object_id
            })

            return {
                "message": "You have left the group and the group has been deleted."
            }

        # ------------------------------------------------------------
        # ADMIN + OTHER MEMBERS
        #
        # The creator cannot leave while other members still exist.
        # ------------------------------------------------------------

        if is_admin:
            raise Exception(
                "Group admin cannot leave the group while other members exist."
            )

        # ------------------------------------------------------------
        # NORMAL MEMBER
        #
        # Remove current user from members.
        # ------------------------------------------------------------

        updated_members = [
            member
            for member in existing_members
            if str(member) != user_id_string
        ]

        # ------------------------------------------------------------
        # Update group
        # ------------------------------------------------------------

        self.groups.update_one(
            {
                "_id": group_object_id
            },
            {
                "$set": {
                    "members": updated_members
                }
            }
        )

        return {
            "message": "You have left the group successfully."
        }

    # ================================================================
    # GET USER GROUP BALANCE
    # ================================================================

    def _get_user_group_balance(
        self,
        group_id: str,
        user_id: str,
    ):
        i_owe = 0.0
        owes_me = 0.0

        transactions = self.transactions.find({
            "group_id": ObjectId(group_id)
        })

        for transaction in transactions:

            transaction_type = transaction.get(
                "transaction_type"
            )

            # ========================================================
            # EXPENSE
            # ========================================================

            if transaction_type == "expense":

                paid_by = transaction.get("paid_by")

                if paid_by is None:
                    continue

                paid_by = str(paid_by)

                participants = transaction.get(
                    "participants",
                    []
                )

                for participant in participants:

                    participant_id = str(
                        participant["user_id"]
                    )

                    share = float(
                        participant.get("share", 0)
                    )

                    # ------------------------------------------------
                    # Current user paid for another member.
                    #
                    # That member owes the current user.
                    # ------------------------------------------------

                    if paid_by == user_id:

                        if participant_id == user_id:
                            continue

                        owes_me += share

                    # ------------------------------------------------
                    # Another member paid for the current user.
                    #
                    # Current user owes that member.
                    # ------------------------------------------------

                    elif participant_id == user_id:

                        i_owe += share

            # ========================================================
            # SETTLEMENT
            # ========================================================

            elif transaction_type == "settlement":

                payer = transaction.get("payer")
                receiver = transaction.get("receiver")

                if payer is None or receiver is None:
                    continue

                payer = str(payer)
                receiver = str(receiver)

                amount = float(
                    transaction.get("amount", 0)
                )

                # ------------------------------------------------
                # Current user paid someone.
                #
                # This reduces what the current user owes.
                # ------------------------------------------------

                if payer == user_id:
                    i_owe -= amount

                # ------------------------------------------------
                # Someone paid the current user.
                #
                # This reduces what they owe the current user.
                # ------------------------------------------------

                elif receiver == user_id:
                    owes_me -= amount

        return {
            "i_owe": round(max(i_owe, 0.0), 2),
            "owes_me": round(max(owes_me, 0.0), 2),
        }

    # ================================================================
    # GET USER GROUPS
    # ================================================================

    def get_user_groups(self, user_id: str):
        print("========== GET USER GROUPS ==========")
        print("USER ID:", user_id)

        groups = self.groups.find({
            "members": {
                "$in": [ObjectId(user_id)]
            }
        })

        response = []

        for group in groups:
            print("GROUP:", group)

            group_model = GroupModel.from_dict(group)

            print("MEMBERS:", group_model.members)

            member_details = self._get_member_details(
                group_model.members
            )

            print("MEMBER DETAILS:", member_details)

            # ------------------------------------------------------------
            # Get latest activity for this group
            # ------------------------------------------------------------

            latest_transaction = self.transactions.find_one(
                {
                    "group_id": group["_id"]
                },
                sort=[
                    ("created_at", -1)
                ],
            )

            last_activity = None

            if latest_transaction:
                created_at = latest_transaction.get("created_at")

                if created_at:
                    last_activity = created_at.isoformat()

            # ------------------------------------------------------------
            # Build group response
            # ------------------------------------------------------------

            group_response = group_model.to_response(
                member_details=member_details
            )

            group_response["last_activity"] = last_activity

            group_balance = self._get_user_group_balance(
                group_id=str(group["_id"]),
                user_id=user_id,
            )

            group_response["i_owe"] = group_balance["i_owe"]
            group_response["owes_me"] = group_balance["owes_me"]

            response.append(group_response)

        print("RESPONSE:", response)
        print("=====================================")

        return response

    # ================================================================
    # GET MEMBER DETAILS
    # ================================================================

    def _get_member_details(self, member_ids: list):
        object_ids = [
            ObjectId(member_id)
            for member_id in member_ids
        ]

        users = self.users.find(
            {
                "_id": {
                    "$in": object_ids
                }
            },
            {
                "_id": 1,
                "username": 1,
                "phoneNumber": 1,
            },
        )

        return [
            {
                "id": str(user["_id"]),
                "username": user.get("username", ""),
                "phoneNumber": user.get("phoneNumber", ""),
            }
            for user in users
        ]

    # ================================================================
    # GENERATE UNIQUE INVITE CODE
    # ================================================================

    def _generate_unique_invite_code(self):
        while True:
            code = generate_random_invite_code()

            if self.groups.find_one({
                "invite_code": code
            }) is None:
                return code