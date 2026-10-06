from bson import ObjectId


class UserModel:
    def __init__(
        self,
        username: str,
        phone_number: str,
        email: str,
        password: str,
        _id: str = None,
    ):
        self.id = _id
        self.username = username
        self.phone_number = phone_number
        self.email = email
        self.password = password

    def to_dict(self):
        data = {
            "username": self.username,
            "phoneNumber": self.phone_number,
            "email": self.email,
            "password": self.password,
        }

        if self.id:
            data["_id"] = ObjectId(self.id)

        return data

    @classmethod
    def from_dict(cls, data):
        return cls(
            _id=str(data.get("_id")),
            username=data.get("username"),
            phone_number=data.get("phoneNumber"),
            email=data.get("email"),
            password=data.get("password"),
        )