# Importação das bibliotecas
import re
from datetime import datetime
from flask import Flask, jsonify, request, send_from_directory
from psycopg2 import errors

from db import get_cursor

FRONTEND_DIR = "../frontend"

app = Flask(__name__, static_folder=FRONTEND_DIR, static_url_path="")

# A função verifca se os digitos são números
def somente_digitos(valor):
    return re.sub(r"\D", "", valor or "")

def data_br_para_iso(valor):
    """Converte 'dd/mm/aaaa' em 'aaaa-mm-dd'. Retorna None se vazio/invalido."""
    if not valor:
        return None
    return datetime.strptime(valor, "%d/%m/%Y").strftime("%Y-%m-%d")

# Definição das classificações do lotes
CLASSIFICACOES_VALIDAS = {
    "Consumo humano": "CONSUMO HUMANO",
    "Consumo animal": "CONSUMO ANIMAL",
    "Compostagem": "COMPOSTAGEM",
}
CLASSIFICACOES_EXIBICAO = {valor: chave for chave, valor in CLASSIFICACOES_VALIDAS.items()}

# A função redireciona para a página inicial
@app.get("/")
def index():
    return send_from_directory(FRONTEND_DIR, "index.html")

# A função retorna a lista de todos os produtos
@app.get("/api/produtos")
def listar_produtos():
    with get_cursor() as cursor:
        cursor.execute("SELECT nome, tipo FROM Produto ORDER BY nome")
        produtos = cursor.fetchall()
    return jsonify(produtos)

# A função realiza uma verificação no CPF informado e retorna as
# informações do produtor, caso exista
@app.get("/api/produtores")
def buscar_produtor():
    cpf = somente_digitos(request.args.get("cpf", ""))
    if not cpf:
        return jsonify({"erro": "Informe o CPF do produtor."}), 400

    with get_cursor() as cursor:
        cursor.execute("SELECT cpf, nome FROM Produtor_Rural WHERE cpf = %s", (cpf,))
        produtor = cursor.fetchone()

    if not produtor:
        return jsonify({"erro": "Produtor não encontrado."}), 404

    return jsonify(produtor)

# A função listar_lotes() realiza uma busca no banco de dados e retorna
# uma lista com todos os lotes da classificação passada como parametro
# da requisição
@app.get("/api/lotes")
def listar_lotes():

    # Verificação da classificação
    classificacao = request.args.get("classificacao", "")
    classificacao_bd = CLASSIFICACOES_VALIDAS.get(classificacao)
    if not classificacao_bd:
        return jsonify({"erro": "Classificação inválida."}), 400

    # Execução da query de busca
    with get_cursor() as cursor:
        cursor.execute(
            """
            SELECT lp.id_lote AS id, lp.produto, lp.classificacao, lp.quantidade,
                   lp.validade, lp.localizacao, pr.nome AS produtor
            FROM Lote_de_Produto lp
            JOIN Produtor_Rural pr ON pr.cpf = lp.produtor
            WHERE lp.classificacao = %s
            ORDER BY lp.data_hora_cadastro DESC
            """,
            (classificacao_bd,),
        )
        lotes = cursor.fetchall()

    # Formatando o nome da classificação e data 
    for lote in lotes:
        lote["classificacao"] = CLASSIFICACOES_EXIBICAO.get(lote["classificacao"], lote["classificacao"])
        if lote["validade"]:
            lote["validade"] = lote["validade"].strftime("%d/%m/%Y")

    return jsonify(lotes)

# A função criar_lotes() faz um verificação dos campos, data, cpf
# e insere um nova tupla na tabela de Lote de Produtos
@app.post("/api/lotes")
def criar_lote():
    dados = request.get_json(silent=True) or {}

    # Verifica campos obrigatórios
    campos_obrigatorios = ["produto", "cpf", "quantidade", "data_colheita", "validade", "localizacao"]
    faltantes = [campo for campo in campos_obrigatorios if not dados.get(campo)]
    if faltantes:
        return jsonify({"erro": f"Campos obrigatórios faltando: {', '.join(faltantes)}"}), 400

    # Formata as datas
    try:
        data_colheita = data_br_para_iso(dados["data_colheita"])
        validade = data_br_para_iso(dados["validade"])
    except ValueError:
        return jsonify({"erro": "Datas devem estar no formato dd/mm/aaaa."}), 400

    # Verifica o CPF
    cpf = somente_digitos(dados["cpf"])

    try:
        with get_cursor(commit=True) as cursor:
            cursor.execute(
                """
                INSERT INTO Lote_de_Produto
                    (id_lote, produto, produtor, quantidade, data_colheita, validade, localizacao, classificacao)
                VALUES
                    ('LOTE-' || LPAD(nextval('seq_lote_id')::text, 4, '0'),
                     %s, %s, %s, %s, %s, %s, %s)
                RETURNING id_lote
                """,
                (
                    dados["produto"],
                    cpf,
                    dados["quantidade"],
                    data_colheita,
                    validade,
                    dados["localizacao"],
                    "CONSUMO HUMANO",
                ),
            )
            novo_lote = cursor.fetchone()
    except errors.ForeignKeyViolation as erro:
        constraint = erro.diag.constraint_name
        if constraint == "fk_lote_produto_produto":
            return jsonify({"erro": "Produto não encontrado."}), 404
        if constraint == "fk_lote_produto_produtor":
            return jsonify({"erro": "Produtor não encontrado."}), 404
        return jsonify({"erro": "Referência inválida."}), 404

    return jsonify({"id_lote": novo_lote["id_lote"]}), 201


if __name__ == "__main__":
    app.run(debug=True)
