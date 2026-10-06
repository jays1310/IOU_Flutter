from flask import Flask
from utils.password_helper import bcrypt
from routes.auth_routes import auth_bp
from database.mongo import MongoDB
from flask import jsonify, request
from middleware.jwt_auth import jwt_required
from routes.group_routes import group_bp
from routes.contacts_routes import contacts_bp
from routes.transaction_routes import transaction_bp

app = Flask(__name__)
bcrypt.init_app(app)
app.register_blueprint(auth_bp, url_prefix="/api/auth")
app.register_blueprint(group_bp, url_prefix="/api/groups")
app.register_blueprint(contacts_bp, url_prefix="/api/contacts")
app.register_blueprint(
    transaction_bp,
    url_prefix="/api/transactions",
)
MongoDB.connect()


@app.route("/")
def home():
    return {
        "message": "IOU Backend is running!"
    }


@app.route("/api/profile", methods=["GET"])
@jwt_required
def profile():
    return jsonify({
        "message": "Protected route accessed successfully.",
        "user": request.user
    })


if __name__ == "__main__":
    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True,
    )