from pymongo import MongoClient
from config import Config


class MongoDB:
    _client = None
    _database = None

    @classmethod
    def connect(cls):
        if cls._client is None:
            cls._client = MongoClient(Config.MONGO_URI)
            cls._database = cls._client[Config.DATABASE_NAME]
            users = cls._database["users"]

            users.create_index(
                "email",
                unique=True,
            )

            users.create_index(
                "phoneNumber",
                unique=True,
            )

            print("✅ Connected to MongoDB Atlas")

    @classmethod
    def get_database(cls):
        if cls._database is None:
            cls.connect()

        return cls._database