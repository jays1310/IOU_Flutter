import random
import string
from datetime import datetime

from bson import ObjectId


def generate_random_invite_code(length=6):
    characters = string.ascii_uppercase + string.digits
    return "".join(random.choices(characters, k=length))


class GroupModel:
    def __init__(
        self,
        group_name: str,
        created_by: str,
        members: list = None,
        invite_code: str = None,
        created_at: datetime = None,
        _id: str = None,
    ):
        self.id = _id
        self.group_name = group_name
        self.created_by = created_by
        self.members = members if members else [created_by]
        self.invite_code = invite_code
        self.created_at = created_at or datetime.utcnow()

    def to_dict(self):
        data = {
            "group_name": self.group_name,
            "created_by": ObjectId(self.created_by),
            "members": [ObjectId(member) for member in self.members],
            "invite_code": self.invite_code,
            "created_at": self.created_at,
        }

        if self.id:
            data["_id"] = ObjectId(self.id)

        return data

    @classmethod
    def from_dict(cls, data):
        return cls(
            _id=str(data["_id"]),
            group_name=data["group_name"],
            created_by=str(data["created_by"]),
            members=[str(member) for member in data["members"]],
            invite_code=data.get("invite_code"),
            created_at=data.get("created_at"),
        )

    def to_response(self, member_details=None):
        return {
            "id": self.id,
            "group_name": self.group_name,
            "created_by": self.created_by,
            "members": self.members,
            "member_details": member_details or [],
            "invite_code": self.invite_code,
            "created_at": self.created_at.isoformat(),
        }