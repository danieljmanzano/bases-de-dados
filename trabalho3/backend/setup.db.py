# Importação das bibliotecas
import os
import psycopg2

# Importação das configurações do banco de dados
from config import DB_CONFIG

# Definindo o caminho do arquivo atual
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATABASE_DIR = os.path.join(BASE_DIR, "..", "database")

# A função inicializa_banco() cria todas as tabelas definidas no arquivo
# esquema.sql e as popula com os dados contidos no arquivo dados.sql.

# Nesse caso, por se tratar de uma transação com mais de uma operação de
# acesso ao banco de dados (Todas as operações CREATE e INSERT), foi necessário
# realizar um simples controle de transação, com o intuito de manter a consistência
# dos dados, mesmo após a ocorrência de erros relativos ao banco de dados.

# Para entender melhor o controle feito, é importante ter ciência de três principais métodos:
#
# O .execute(), por se tratar de um operação do tipo DDL (CREATE TABLE), inicia a transação.
# O .commit() grava as modificações feitas até o momento no banco de dados.
# O .rollback() retorna para o estado anterior, caso qualquer um dos comandos SQL falhe.
#
# Sabendo disso, primeiro a transação é iniciada com o .execute() correspondente a criação das
# tabelas, e termina no .commit(). Caso algum dos comandos resulte em algum erro antes de chegar
# no commit(), o rollback() é executado e nenhuma das alterações feitas até o momento é aplicada.
def inicializar_banco():
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()

        # Executa o esquema
        with open(os.path.join(DATABASE_DIR, "esquema.sql"), "r") as arquivo_esquema:
            cursor.execute(arquivo_esquema.read())

        # Executa a inserção de dados (opcional)
        with open(os.path.join(DATABASE_DIR, "dados.sql"), "r") as arquivo_dados:
            cursor.execute(arquivo_dados.read())

        print("Tabelas criadas com sucesso.")
        print("Dados iniciais inseridos com sucesso.")

        conn.commit()

    except Exception as e:
        conn.rollback()
        print(f"Erro ao configurar o banco: {e}")

    finally:
        cursor.close()
        conn.close()


if __name__ == "__main__":
    inicializar_banco()
