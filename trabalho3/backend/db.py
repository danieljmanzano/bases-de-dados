# Importação das bibliotecas
from contextlib import contextmanager
import psycopg2
import psycopg2.extras

# Importação das configurações do banco de dados
from config import DB_CONFIG

# contextmanager é um decorator responsável por modificar a função procedente,
# de forma que função que a chama, a partir da estrutura "with .. as .. :",
# possa manipular a variável que acompanha o yield. Além disso, os comandos
# executados antes do yield são executados antes da execução do código da função
# que o chamou e o finally depois do término da função que o chamou, sendo ideal
# para contextos de inicialização e finalização padronizados, como esse.

# A função get_connection() realiza a conexão do ao banco de dados e envia, 
# para a função que o chamou, a variável conn.
@contextmanager
def get_connection():
    conn = psycopg2.connect(**DB_CONFIG)
    try:
        yield conn
    finally:
        conn.close()

# A função get_cursor() cria um objeto para manipulação de dados e envia,
# para a função que o chamou, a variável cursor. Além disso, a função realiza
# o controle de transação a partir dos métodos .commit() e rollback(), executando
# o método de rollback sempre que houver erro em alguma operação de manipulação
# do banco de dados
@contextmanager
def get_cursor(commit=False):
    with get_connection() as conn:
        cursor = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        try:
            yield cursor
            if commit:
                conn.commit()
        except Exception:
            conn.rollback()
            raise
        finally:
            cursor.close()
