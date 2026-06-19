import os

import psycopg2

from config import DB_CONFIG

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATABASE_DIR = os.path.join(BASE_DIR, "..", "database")


def inicializar_banco():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()

        # Executa o esquema
        with open(os.path.join(DATABASE_DIR, "schema.sql"), "r") as arquivo_esquema:
            cursor.execute(arquivo_esquema.read())
            print("Tabelas criadas com sucesso.")

        # Executa a inserção de dados (opcional)
        with open(os.path.join(DATABASE_DIR, "seed.sql"), "r") as arquivo_dados:
            cursor.execute(arquivo_dados.read())
            print("Dados iniciais inseridos com sucesso.")

        conn.commit()
        cursor.close()
        conn.close()

    except Exception as e:
        print(f"Erro ao configurar o banco: {e}")


if __name__ == "__main__":
    inicializar_banco()
