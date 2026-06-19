import psycopg2

def inicializar_banco():
    try:
        conn = psycopg2.connect(
            dbname="banco_trabalho",
            user="postgres",
            password="senha_segura",
            host="localhost",
            port="5433"
        )
        cursor = conn.cursor()

        # Executa o esquema
        with open('../sql/schema.sql', 'r') as arquivo_esquema:
            cursor.execute(arquivo_esquema.read())
            print("Tabelas criadas com sucesso.")

        # Executa a inserção de dados (opcional)
        with open('../sql/seed.sql', 'r') as arquivo_dados:
            cursor.execute(arquivo_dados.read())
            print("Dados iniciais inseridos com sucesso.")

        conn.commit()
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"Erro ao configurar o banco: {e}")

if __name__ == "__main__":
    inicializar_banco()