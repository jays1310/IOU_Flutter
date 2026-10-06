from datetime import datetime
from bson import ObjectId


class TransactionModel:
    def __init__(
        self,
        group_id: str = None,
        transaction_type: str = "",
        amount: float = 0.0,
        created_by: str = None,
        _id: str = None,
        description: str = "",
        paid_by: str = None,

        # Individual transaction counterpart
        individual_user_id: str = None,

        # Final calculated participant shares
        participants: list = None,

        # equal | exact | percentage
        split_type: str = "equal",

        # Original user input
        split_details: list = None,

        # Settlement fields
        payer: str = None,
        receiver: str = None,

        created_at: datetime = None,
    ):
        self.id = _id

        # Group transaction
        self.group_id = group_id

        # Individual transaction
        self.individual_user_id = individual_user_id

        self.transaction_type = transaction_type

        self.description = description
        self.amount = amount

        self.created_by = created_by

        self.paid_by = paid_by

        # [
        #   {
        #       "user_id": "...",
        #       "share": 250.00
        #   }
        # ]
        self.participants = participants or []

        # equal | exact | percentage
        self.split_type = split_type

        # Equal:
        # [
        #   {
        #       "user_id": "..."
        #   }
        # ]
        #
        # Exact / Percentage:
        # [
        #   {
        #       "user_id": "...",
        #       "value": 50
        #   }
        # ]
        self.split_details = split_details or []

        self.payer = payer
        self.receiver = receiver

        self.created_at = created_at or datetime.utcnow()

    def to_dict(self):
        data = {
            "transaction_type": self.transaction_type,
            "amount": self.amount,
            "created_by": ObjectId(self.created_by),
            "created_at": self.created_at,
        }

        # Add group_id only for group transactions
        if self.group_id:
            data["group_id"] = ObjectId(self.group_id)

        # Add individual_user_id only for individual transactions
        if self.individual_user_id:
            data["individual_user_id"] = ObjectId(
                self.individual_user_id
            )

        if self.description:
            data["description"] = self.description

        if self.paid_by:
            data["paid_by"] = ObjectId(self.paid_by)

        if self.participants:
            participant_list = []

            for participant in self.participants:
                participant_list.append({
                    "user_id": ObjectId(participant["user_id"]),
                    "share": participant["share"],
                })

            data["participants"] = participant_list

        if self.split_type:
            data["split_type"] = self.split_type

        if self.split_details:
            split_detail_list = []

            for detail in self.split_details:
                split_detail = {
                    "user_id": ObjectId(detail["user_id"]),
                }

                # Equal split does not have a user-entered value.
                # Exact and Percentage splits do.
                if "value" in detail:
                    split_detail["value"] = detail["value"]

                split_detail_list.append(split_detail)

            data["split_details"] = split_detail_list

        if self.payer:
            data["payer"] = ObjectId(self.payer)

        if self.receiver:
            data["receiver"] = ObjectId(self.receiver)

        if self.id:
            data["_id"] = ObjectId(self.id)

        return data

    @classmethod
    def from_dict(cls, data):
        participants = []

        for participant in data.get("participants", []):
            participants.append({
                "user_id": str(participant["user_id"]),
                "share": participant["share"],
            })

        split_details = []

        for detail in data.get("split_details", []):
            split_detail = {
                "user_id": str(detail["user_id"]),
            }

            if "value" in detail:
                split_detail["value"] = detail["value"]

            split_details.append(split_detail)

        return cls(
            _id=str(data.get("_id")),
            group_id=(
                str(data["group_id"])
                if data.get("group_id")
                else None
            ),
            individual_user_id=(
                str(data["individual_user_id"])
                if data.get("individual_user_id")
                else None
            ),
            transaction_type=data.get("transaction_type"),
            description=data.get("description", ""),
            amount=data.get("amount"),
            created_by=str(data.get("created_by")),
            paid_by=(
                str(data["paid_by"])
                if data.get("paid_by")
                else None
            ),
            participants=participants,
            split_type=data.get("split_type", "equal"),
            split_details=split_details,
            payer=(
                str(data["payer"])
                if data.get("payer")
                else None
            ),
            receiver=(
                str(data["receiver"])
                if data.get("receiver")
                else None
            ),
            created_at=data.get("created_at"),
        )

    def to_response(self):
        return {
            "id": self.id,
            "group_id": self.group_id,
            "individual_user_id": self.individual_user_id,
            "transaction_type": self.transaction_type,
            "description": self.description,
            "amount": self.amount,
            "created_by": self.created_by,
            "paid_by": self.paid_by,
            "participants": self.participants,
            "split_type": self.split_type,
            "split_details": self.split_details,
            "payer": self.payer,
            "receiver": self.receiver,
            "created_at": (
                self.created_at.isoformat()
                if self.created_at
                else None
            ),
        }