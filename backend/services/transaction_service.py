from bson import ObjectId

from database.mongo import MongoDB
from models.transaction_model import TransactionModel
from utils.split_calculator import SplitCalculator


class TransactionService:

    def __init__(self):
        self.db = MongoDB.get_database()

        self.transactions = self.db.transactions
        self.groups = self.db.groups
        self.users = self.db.users

    # =========================================================
    # GROUP TRANSACTIONS
    # =========================================================

    def create_expense(
        self,
        transaction: TransactionModel,
    ):
        # Check if group exists
        group = self.groups.find_one({
            "_id": ObjectId(transaction.group_id)
        })

        if group is None:
            raise Exception("Group not found.")

        # Verify creator is a member of the group
        if ObjectId(transaction.created_by) not in group["members"]:
            raise Exception("You are not a member of this group.")

        # Verify every participant belongs to the group
        group_members = {
            str(member)
            for member in group["members"]
        }

        for participant in transaction.split_details:
            if participant["user_id"] not in group_members:
                raise Exception(
                    "One or more participants are not members of this group."
                )

        # Calculate final participant shares
        transaction.participants = SplitCalculator.calculate(
            split_type=transaction.split_type,
            amount=transaction.amount,
            split_details=transaction.split_details,
        )

        # Save transaction
        result = self.transactions.insert_one(
            transaction.to_dict()
        )

        created_transaction = self.transactions.find_one({
            "_id": result.inserted_id
        })

        return TransactionModel.from_dict(
            created_transaction
        ).to_response()

    def get_group_transactions(
        self,
        group_id: str,
        user_id: str,
    ):
        # Check if group exists
        group = self.groups.find_one({
            "_id": ObjectId(group_id)
        })

        if group is None:
            raise Exception("Group not found.")

        # Verify the requesting user is a member of the group
        if ObjectId(user_id) not in group["members"]:
            raise Exception("You are not a member of this group.")

        # Get all transactions belonging to this group
        transactions = self.transactions.find(
            {
                "group_id": ObjectId(group_id)
            }
        ).sort(
            "created_at",
            -1
        )

        response = []

        for transaction in transactions:
            transaction_model = TransactionModel.from_dict(
                transaction
            )

            response.append(
                transaction_model.to_response()
            )

        return response

    def create_settlement(
        self,
        group_id: str,
        payer_id: str,
        receiver_id: str,
        amount: float,
    ):
        # ---------------------------------------------------------
        # Validate amount
        # ---------------------------------------------------------

        if amount <= 0:
            raise Exception(
                "Settlement amount must be greater than zero."
            )

        # ---------------------------------------------------------
        # Check if group exists
        # ---------------------------------------------------------

        group = self.groups.find_one({
            "_id": ObjectId(group_id)
        })

        if group is None:
            raise Exception("Group not found.")

        # ---------------------------------------------------------
        # Verify payer is a group member
        # ---------------------------------------------------------

        if ObjectId(payer_id) not in group["members"]:
            raise Exception(
                "Payer is not a member of this group."
            )

        # ---------------------------------------------------------
        # Verify receiver is a group member
        # ---------------------------------------------------------

        if ObjectId(receiver_id) not in group["members"]:
            raise Exception(
                "Receiver is not a member of this group."
            )

        # ---------------------------------------------------------
        # Payer and receiver cannot be the same person
        # ---------------------------------------------------------

        if payer_id == receiver_id:
            raise Exception(
                "Payer and receiver cannot be the same user."
            )

        # ---------------------------------------------------------
        # Calculate current outstanding balance between
        # payer and receiver.
        #
        # Positive payer_balance:
        #     Receiver owes payer.
        #
        # Negative payer_balance:
        #     Payer owes receiver.
        # ---------------------------------------------------------

        payer_balance = 0.0

        transactions = self.transactions.find({
            "group_id": ObjectId(group_id)
        })

        for transaction in transactions:

            transaction_type = transaction.get(
                "transaction_type"
            )

            # =====================================================
            # EXPENSE
            # =====================================================

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

                    if (
                        paid_by == payer_id
                        and participant_id == receiver_id
                    ):
                        payer_balance += share

                    elif (
                        paid_by == receiver_id
                        and participant_id == payer_id
                    ):
                        payer_balance -= share

            # =====================================================
            # SETTLEMENT
            # =====================================================

            elif transaction_type == "settlement":

                settlement_payer = transaction.get("payer")
                settlement_receiver = transaction.get(
                    "receiver"
                )

                if (
                    settlement_payer is None
                    or settlement_receiver is None
                ):
                    continue

                settlement_payer = str(
                    settlement_payer
                )

                settlement_receiver = str(
                    settlement_receiver
                )

                settlement_amount = float(
                    transaction.get("amount", 0)
                )

                if (
                    settlement_payer == payer_id
                    and settlement_receiver == receiver_id
                ):
                    payer_balance += settlement_amount

                elif (
                    settlement_payer == receiver_id
                    and settlement_receiver == payer_id
                ):
                    payer_balance -= settlement_amount

        payer_balance = round(
            payer_balance,
            2,
        )

        outstanding_amount = round(
            -payer_balance,
            2,
        )

        if outstanding_amount <= 0:
            raise Exception(
                "You do not owe any outstanding amount to this member."
            )

        if amount > outstanding_amount:
            raise Exception(
                f"Settlement amount cannot exceed "
                f"your outstanding balance of "
                f"₹{outstanding_amount:.2f}."
            )

        settlement = TransactionModel(
            group_id=group_id,
            transaction_type="settlement",
            amount=float(amount),
            created_by=payer_id,
            description="Settlement",
            payer=payer_id,
            receiver=receiver_id,
        )

        result = self.transactions.insert_one(
            settlement.to_dict()
        )

        created_settlement = self.transactions.find_one({
            "_id": result.inserted_id
        })

        return TransactionModel.from_dict(
            created_settlement
        ).to_response()

    def get_group_balance_summary(
        self,
        group_id: str,
        user_id: str,
    ):
        # ---------------------------------------------------------
        # Check if group exists
        # ---------------------------------------------------------

        group = self.groups.find_one({
            "_id": ObjectId(group_id)
        })

        if group is None:
            raise Exception("Group not found.")

        # ---------------------------------------------------------
        # Verify requesting user is a group member
        # ---------------------------------------------------------

        if ObjectId(user_id) not in group["members"]:
            raise Exception(
                "You are not a member of this group."
            )

        # ---------------------------------------------------------
        # Initialize balances
        #
        # Positive balance:
        #   The other member owes the current user.
        #
        # Negative balance:
        #   The current user owes the other member.
        # ---------------------------------------------------------

        balances = {
            str(member_id): 0.0
            for member_id in group["members"]
            if str(member_id) != user_id
        }

        # ---------------------------------------------------------
        # Get all group transactions
        # ---------------------------------------------------------

        transactions = self.transactions.find({
            "group_id": ObjectId(group_id)
        })

        for transaction in transactions:

            transaction_type = transaction.get(
                "transaction_type"
            )

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

                    if paid_by == user_id:

                        if participant_id == user_id:
                            continue

                        if participant_id in balances:
                            balances[participant_id] += share

                    elif participant_id == user_id:

                        if paid_by in balances:
                            balances[paid_by] -= share

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

                if payer == user_id:

                    if receiver in balances:
                        balances[receiver] += amount

                elif receiver == user_id:

                    if payer in balances:
                        balances[payer] -= amount

        # ---------------------------------------------------------
        # Round balances and attach member information
        # ---------------------------------------------------------

        response = []

        for member_id, balance in balances.items():

            balance = round(
                balance,
                2,
            )

            member = self.users.find_one({
                "_id": ObjectId(member_id)
            })

            if member is None:
                continue

            response.append({
                "user_id": member_id,
                "username": member.get(
                    "username",
                    ""
                ),
                "phoneNumber": member.get(
                    "phoneNumber",
                    ""
                ),
                "balance": balance,
            })

        return response

    # =========================================================
    # INDIVIDUAL TRANSACTIONS
    # =========================================================

    def create_individual_expense(
        self,
        transaction: TransactionModel,
    ):
        # ---------------------------------------------------------
        # Validate individual user
        # ---------------------------------------------------------

        if not transaction.individual_user_id:
            raise Exception(
                "Individual user is required."
            )

        if not transaction.created_by:
            raise Exception(
                "Transaction creator is required."
            )

        if transaction.created_by == transaction.individual_user_id:
            raise Exception(
                "You cannot create an individual transaction with yourself."
            )

        # ---------------------------------------------------------
        # Validate amount
        # ---------------------------------------------------------

        if transaction.amount <= 0:
            raise Exception(
                "Expense amount must be greater than zero."
            )

        current_user_id = str(
            transaction.created_by
        )

        other_user_id = str(
            transaction.individual_user_id
        )

        # ---------------------------------------------------------
        # Check if the other user exists
        # ---------------------------------------------------------

        other_user = self.users.find_one({
            "_id": ObjectId(other_user_id)
        })

        if other_user is None:
            raise Exception(
                "User not found."
            )

        # ---------------------------------------------------------
        # Validate paid_by
        #
        # Only the two people involved in the individual
        # transaction can be the payer.
        # ---------------------------------------------------------

        if not transaction.paid_by:
            raise Exception(
                "Paid by user is required."
            )

        paid_by = str(
            transaction.paid_by
        )

        if paid_by not in {
            current_user_id,
            other_user_id,
        }:
            raise Exception(
                "Paid by user must be one of the two users."
            )

        # ---------------------------------------------------------
        # Validate split details
        # ---------------------------------------------------------

        if not transaction.split_details:
            raise Exception(
                "At least one participant is required."
            )

        participant_ids = []

        for detail in transaction.split_details:

            participant_id = str(
                detail.get("user_id", "")
            )

            if not participant_id:
                raise Exception(
                    "Every split participant must have a user ID."
                )

            if participant_id not in {
                current_user_id,
                other_user_id,
            }:
                raise Exception(
                    "Individual transactions can only contain "
                    "the two users involved."
                )

            if participant_id in participant_ids:
                raise Exception(
                    "A participant cannot appear more than once."
                )

            participant_ids.append(
                participant_id
            )

        # =========================================================
        # CASE 2 / CASE 3
        #
        # Only ONE person is selected in Split Between.
        #
        # That person receives 100% of the expense.
        #
        # The selected person must NOT be the person who paid.
        #
        # Example:
        #
        # Jay paid
        # Split Between = Chetna
        #
        # Chetna -> 100%
        #
        # OR
        #
        # Chetna paid
        # Split Between = Jay
        #
        # Jay -> 100%
        # =========================================================

        if len(participant_ids) == 1:

            participant_id = participant_ids[0]

            if participant_id == paid_by:
                raise Exception(
                    "When only one person is selected, "
                    "that person cannot also be the payer."
                )

            if transaction.split_type != "exact":
                raise Exception(
                    "A single-person individual expense "
                    "must use exact split."
                )

            detail = transaction.split_details[0]

            try:
                share_value = float(
                    detail.get("value", 0)
                )
            except (TypeError, ValueError):
                raise Exception(
                    "Invalid split amount."
                )

            if share_value <= 0:
                raise Exception(
                    "The selected participant must have "
                    "a positive share."
                )

            if abs(
                share_value - transaction.amount
            ) > 0.01:
                raise Exception(
                    "The selected participant must be "
                    "responsible for the full expense amount."
                )

        # =========================================================
        # CASE 1
        #
        # Both people are selected.
        #
        # Both must have a positive share.
        #
        # 100 / 0 is invalid.
        # 0 / 100 is invalid.
        # =========================================================

        elif len(participant_ids) == 2:

            expected_participants = {
                current_user_id,
                other_user_id,
            }

            if set(participant_ids) != expected_participants:
                raise Exception(
                    "Both individual participants must be "
                    "the current user and the selected user."
                )

            if transaction.split_type not in {
                "equal",
                "exact",
                "percentage",
            }:
                raise Exception(
                    "Invalid split type for a two-person "
                    "individual expense."
                )

        else:
            raise Exception(
                "An individual expense can contain only "
                "one or both participants."
            )

        # ---------------------------------------------------------
        # Calculate final participant shares
        # ---------------------------------------------------------

        transaction.participants = SplitCalculator.calculate(
            split_type=transaction.split_type,
            amount=transaction.amount,
            split_details=transaction.split_details,
        )

        # ---------------------------------------------------------
        # Validate calculated shares
        # ---------------------------------------------------------

        calculated_participant_ids = set()

        total_share = 0.0

        for participant in transaction.participants:

            participant_id = str(
                participant.get("user_id")
            )

            share = float(
                participant.get("share", 0)
            )

            calculated_participant_ids.add(
                participant_id
            )

            total_share += share

            # Every participant must have a positive
            # responsibility.
            if share <= 0:
                raise Exception(
                    "Every selected participant must have "
                    "a positive share."
                )

        # ---------------------------------------------------------
        # Ensure the final shares add up to the full amount.
        # ---------------------------------------------------------

        if abs(
            total_share - transaction.amount
        ) > 0.01:
            raise Exception(
                "Participant shares must equal "
                "the total expense amount."
            )

        # ---------------------------------------------------------
        # For the one-person case, make sure the selected
        # participant is exactly 100%.
        # ---------------------------------------------------------

        if len(participant_ids) == 1:

            if calculated_participant_ids != {
                participant_ids[0]
            }:
                raise Exception(
                    "Invalid participant calculation."
                )

            calculated_share = float(
                transaction.participants[0].get(
                    "share",
                    0
                )
            )

            if abs(
                calculated_share - transaction.amount
            ) > 0.01:
                raise Exception(
                    "The selected participant must be "
                    "responsible for 100% of the expense."
                )

        # ---------------------------------------------------------
        # For the two-person case, both people must be present
        # and both must have positive shares.
        # ---------------------------------------------------------

        else:

            if calculated_participant_ids != {
                current_user_id,
                other_user_id,
            }:
                raise Exception(
                    "Both users must be present in the "
                    "final participant calculation."
                )

        # ---------------------------------------------------------
        # Save individual transaction
        # ---------------------------------------------------------

        result = self.transactions.insert_one(
            transaction.to_dict()
        )

        created_transaction = self.transactions.find_one({
            "_id": result.inserted_id
        })

        return TransactionModel.from_dict(
            created_transaction
        ).to_response()

    def create_individual_settlement(
        self,
        user_id: str,
        other_user_id: str,
        amount: float,
    ):
        # ---------------------------------------------------------
        # Validate users
        # ---------------------------------------------------------

        if user_id == other_user_id:
            raise Exception(
                "You cannot settle an individual transaction with yourself."
            )

        current_user = self.users.find_one({
            "_id": ObjectId(user_id)
        })

        if current_user is None:
            raise Exception(
                "User not found."
            )

        other_user = self.users.find_one({
            "_id": ObjectId(other_user_id)
        })

        if other_user is None:
            raise Exception(
                "User not found."
            )

        # ---------------------------------------------------------
        # Validate amount
        # ---------------------------------------------------------

        if amount <= 0:
            raise Exception(
                "Settlement amount must be greater than zero."
            )

        # ---------------------------------------------------------
        # Calculate current outstanding balance
        #
        # Positive balance:
        #     Other user owes current user.
        #
        # Negative balance:
        #     Current user owes other user.
        # ---------------------------------------------------------

        current_balance = 0.0

        transactions = self.transactions.find({
            "individual_user_id": {
                "$in": [
                    ObjectId(user_id),
                    ObjectId(other_user_id),
                ]
            },
            "created_by": {
                "$in": [
                    ObjectId(user_id),
                    ObjectId(other_user_id),
                ]
            },
        })

        for transaction in transactions:

            transaction_type = transaction.get(
                "transaction_type"
            )

            # =====================================================
            # EXPENSE
            # =====================================================

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
                        participant.get("user_id")
                    )

                    share = float(
                        participant.get("share", 0)
                    )

                    # Current user paid for other user
                    if (
                        paid_by == user_id
                        and participant_id == other_user_id
                    ):
                        current_balance += share

                    # Other user paid for current user
                    elif (
                        paid_by == other_user_id
                        and participant_id == user_id
                    ):
                        current_balance -= share

            # =====================================================
            # SETTLEMENT
            # =====================================================

            elif transaction_type == "settlement":

                settlement_payer = transaction.get("payer")
                settlement_receiver = transaction.get(
                    "receiver"
                )

                if (
                    settlement_payer is None
                    or settlement_receiver is None
                ):
                    continue

                settlement_payer = str(
                    settlement_payer
                )

                settlement_receiver = str(
                    settlement_receiver
                )

                settlement_amount = float(
                    transaction.get("amount", 0)
                )

                # Current user paid the settlement
                if (
                    settlement_payer == user_id
                    and settlement_receiver == other_user_id
                ):
                    current_balance += settlement_amount

                # Other user paid the settlement
                elif (
                    settlement_payer == other_user_id
                    and settlement_receiver == user_id
                ):
                    current_balance -= settlement_amount

        current_balance = round(
            current_balance,
            2,
        )

        # ---------------------------------------------------------
        # Current user must actually owe the other user
        # ---------------------------------------------------------

        outstanding_amount = round(
            -current_balance,
            2,
        )

        if outstanding_amount <= 0:
            raise Exception(
                "You do not owe any outstanding amount to this user."
            )

        # ---------------------------------------------------------
        # Settlement cannot exceed outstanding amount
        # ---------------------------------------------------------

        if amount > outstanding_amount:
            raise Exception(
                f"Settlement amount cannot exceed "
                f"your outstanding balance of "
                f"₹{outstanding_amount:.2f}."
            )

        # ---------------------------------------------------------
        # Create settlement transaction
        # ---------------------------------------------------------

        settlement = TransactionModel(
            individual_user_id=other_user_id,
            transaction_type="settlement",
            amount=float(amount),
            created_by=user_id,
            description="Settlement",
            payer=user_id,
            receiver=other_user_id,
        )

        result = self.transactions.insert_one(
            settlement.to_dict()
        )

        created_settlement = self.transactions.find_one({
            "_id": result.inserted_id
        })

        return TransactionModel.from_dict(
            created_settlement
        ).to_response()

    def get_individual_transactions(
        self,
        user_id: str,
        other_user_id: str,
    ):
        # ---------------------------------------------------------
        # Validate users
        # ---------------------------------------------------------

        if user_id == other_user_id:
            raise Exception(
                "You cannot view an individual transaction with yourself."
            )

        current_user = self.users.find_one({
            "_id": ObjectId(user_id)
        })

        if current_user is None:
            raise Exception(
                "User not found."
            )

        other_user = self.users.find_one({
            "_id": ObjectId(other_user_id)
        })

        if other_user is None:
            raise Exception(
                "User not found."
            )

        # ---------------------------------------------------------
        # Find transactions between these two users
        # ---------------------------------------------------------

        transactions = self.transactions.find({
            "individual_user_id": {
                "$in": [
                    ObjectId(user_id),
                    ObjectId(other_user_id),
                ]
            },
            "created_by": {
                "$in": [
                    ObjectId(user_id),
                    ObjectId(other_user_id),
                ]
            },
        }).sort(
            "created_at",
            -1
        )

        response = []

        for transaction in transactions:

            transaction_model = TransactionModel.from_dict(
                transaction
            )

            transaction_creator = str(
                transaction.get("created_by")
            )

            transaction_other_user = str(
                transaction.get("individual_user_id")
            )

            valid_pair = (
                transaction_creator in {
                    user_id,
                    other_user_id,
                }
                and transaction_other_user in {
                    user_id,
                    other_user_id,
                }
                and transaction_creator != transaction_other_user
            )

            if not valid_pair:
                continue

            response.append(
                transaction_model.to_response()
            )

        return response

    def get_individual_balance(
        self,
        user_id: str,
        other_user_id: str,
    ):
        # ---------------------------------------------------------
        # Validate users
        # ---------------------------------------------------------

        if user_id == other_user_id:
            raise Exception(
                "You cannot calculate an individual balance with yourself."
            )

        current_user = self.users.find_one({
            "_id": ObjectId(user_id)
        })

        if current_user is None:
            raise Exception(
                "User not found."
            )

        other_user = self.users.find_one({
            "_id": ObjectId(other_user_id)
        })

        if other_user is None:
            raise Exception(
                "User not found."
            )

        # ---------------------------------------------------------
        # Get all transactions between the two users
        # ---------------------------------------------------------

        transactions = self.transactions.find({
            "individual_user_id": {
                "$in": [
                    ObjectId(user_id),
                    ObjectId(other_user_id),
                ]
            },
            "created_by": {
                "$in": [
                    ObjectId(user_id),
                    ObjectId(other_user_id),
                ]
            },
        })

        balance = 0.0

        for transaction in transactions:

            transaction_type = transaction.get(
                "transaction_type"
            )

            # =====================================================
            # EXPENSE
            # =====================================================

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

                    # Current user paid for the other user.
                    # Other user owes current user.

                    if (
                        paid_by == user_id
                        and participant_id == other_user_id
                    ):
                        balance += share

                    # Other user paid for current user.
                    # Current user owes other user.

                    elif (
                        paid_by == other_user_id
                        and participant_id == user_id
                    ):
                        balance -= share

            # =====================================================
            # SETTLEMENT
            # =====================================================

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

                # Current user paid the other user.
                # Their debt decreases.

                if (
                    payer == user_id
                    and receiver == other_user_id
                ):
                    balance += amount

                # Other user paid current user.
                # Their debt to current user decreases.

                elif (
                    payer == other_user_id
                    and receiver == user_id
                ):
                    balance -= amount

        balance = round(
            balance,
            2,
        )

        return {
            "user_id": other_user_id,
            "username": other_user.get(
                "username",
                ""
            ),
            "phoneNumber": other_user.get(
                "phoneNumber",
                ""
            ),
            "balance": balance,
        }

    def get_individual_relationships(self, user_id: str):
        try:
            user_object_id = ObjectId(user_id)
        except Exception:
            raise Exception("Invalid user ID.")

        # ------------------------------------------------------------
        # Find all individual transactions involving the current user
        # ------------------------------------------------------------

        transactions = self.transactions.find({
            "$or": [
                {
                    "created_by": user_object_id,
                    "individual_user_id": {
                        "$exists": True,
                        "$ne": None,
                    },
                },
                {
                    "individual_user_id": user_object_id,
                },
            ]
        }).sort("created_at", -1)

        # ------------------------------------------------------------
        # Build relationship data
        #
        # Dictionary key = counterpart user ID
        # Value = latest transaction timestamp
        # ------------------------------------------------------------

        relationship_activity = {}

        for transaction in transactions:
            created_by = transaction.get("created_by")
            individual_user_id = transaction.get("individual_user_id")
            created_at = transaction.get("created_at")

            if created_by == user_object_id:
                counterpart_id = individual_user_id

            elif individual_user_id == user_object_id:
                counterpart_id = created_by

            else:
                continue

            if counterpart_id is None:
                continue

            counterpart_id_string = str(counterpart_id)

            # Because transactions are sorted newest first,
            # the first timestamp we encounter for a relationship
            # is its latest activity.
            if counterpart_id_string not in relationship_activity:
                relationship_activity[counterpart_id_string] = created_at

        # ------------------------------------------------------------
        # Build final response
        # ------------------------------------------------------------

        relationships = []

        for counterpart_id, latest_activity in relationship_activity.items():

            counterpart = self.users.find_one({
                "_id": ObjectId(counterpart_id)
            })

            if counterpart is None:
                continue

            balance = self.get_individual_balance(
                user_id=user_id,
                other_user_id=counterpart_id,
            )

            relationships.append({
                "user_id": counterpart_id,
                "username": counterpart.get("username", ""),
                "phoneNumber": counterpart.get("phoneNumber", ""),
                "balance": balance.get("balance", 0.0),
                "last_activity": (
                    latest_activity.isoformat()
                    if latest_activity
                    else None
                ),
            })

        return relationships