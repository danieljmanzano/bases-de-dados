import psycopg2

try:
    conn = psycopg2.connect(
        dbname="banco_trabalho",
        user="postgres",
        password="senha_segura",
        host="localhost",
        port="5433"
    )
    print("Conexão com o banco de dados estabelecida com sucesso!")
    conn.close()
except Exception as e:
    print(f"Erro ao conectar: {e}")