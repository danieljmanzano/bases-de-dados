# Dados mockados — remover inteiramente na integração com o banco.
# Substituir cada estrutura pela query SQL indicada no TODO correspondente.

PRODUTORES = {
    "123.456.789-00":       "João da Silva Agropecuária",
    "98.765.432/0001-10":   "Maria Oliveira Farming",
    "111.222.333-44":       "Carlos Souza Produções",
}
# TODO (integração banco):
#   SELECT nome FROM produtor_rural WHERE cpf_cnpj = %s

PRODUTOS = ["Alface", "Batata", "Cenoura", "Milho", "Soja", "Tomate"]
# TODO (integração banco):
#   SELECT nome FROM produto ORDER BY nome

LOTES = [
    {
        "id": 42, "produto": "Batata",
        "produtor": "João da Silva Agropecuária",
        "quantidade": 500, "validade": "20/06/2026",
        "localizacao": "CBD São Carlos",
        "classificacao": "Consumo humano"
    },
    {
        "id": 57, "produto": "Cenoura",
        "produtor": "Maria Oliveira Farming",
        "quantidade": 300, "validade": "18/06/2026",
        "localizacao": "CBD São Carlos",
        "classificacao": "Consumo humano"
    },
    {
        "id": 63, "produto": "Milho",
        "produtor": "Carlos Souza Produções",
        "quantidade": 800, "validade": "25/06/2026",
        "localizacao": "Armazém Central",
        "classificacao": "Consumo animal"
    },
    {
        "id": 71, "produto": "Soja",
        "produtor": "João da Silva Agropecuária",
        "quantidade": 1200, "validade": "30/06/2026",
        "localizacao": "Centro de Compostagem",
        "classificacao": "Compostagem"
    },
]
# TODO (integração banco):
#   SELECT lp.id_lote, p.nome AS produto, pr.nome AS produtor,
#          lp.quantidade, lp.validade, lp.localizacao_atual
#   FROM lote_de_produto lp
#   JOIN produto p ON p.nome = lp.produto
#   JOIN produtor_rural pr ON pr.cpf_cnpj = lp.cpf_cnpj_produtor
#   WHERE lp.classificacao = %s
#   ORDER BY lp.validade ASC

PROXIMO_ID = 100
# TODO (integração banco): ID gerado pelo RETURNING id_lote no INSERT
