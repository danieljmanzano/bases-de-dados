import os

DB_CONFIG = {
    "dbname": os.environ.get("DB_NAME", "banco_trabalho"),
    "user": os.environ.get("DB_USER", "postgres"),
    "password": os.environ.get("DB_PASSWORD", "senha_segura"),
    "host": os.environ.get("DB_HOST", "localhost"),
    "port": os.environ.get("DB_PORT", "5433"),
}
