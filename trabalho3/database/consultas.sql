-- Arquivo com as consultas do sistema (Parte 3 - item 3)
--
-- Seção 1: consultas SIMPLES, necessárias para o funcionamento básico do
-- protótipo (telas de cadastro e consulta do frontend).
--
-- Seção 2: checklist das consultas de complexidade MÉDIA/ALTA exigidas pelo
-- enunciado (mínimo de 5, diversificadas, com 1 de divisão relacional
-- obrigatória). 

-- ============================================================
-- 1) Consultas simples
-- ============================================================

-- 1.1) Lista os produtos cadastrados, usada para popular o <select> de
-- produto na tela de cadastro de lote (passo 1).
-- Implementada em: backend/app.py -> GET /api/produtos
SELECT nome, tipo
FROM Produto
ORDER BY nome;


-- 1.2) Busca um produtor pelo CPF, usada para validar o produtor antes de
-- avançar do passo 1 para o passo 2 do cadastro de lote.
-- Implementada em: backend/app.py -> GET /api/produtores?cpf=<cpf>
SELECT cpf, nome
FROM Produtor_Rural
WHERE cpf = '12345678900';


-- 1.3) Lista os lotes de produto de uma classificação, com o nome do
-- produtor de origem. É a funcionalidade de "consulta com entrada de dados
-- do usuário como parâmetro" exigida no item 4.b da Parte 3.
-- Implementada em: backend/app.py -> GET /api/lotes?classificacao=<classificacao>
SELECT lp.id_lote AS id, lp.produto, lp.classificacao, lp.quantidade,
       lp.validade, lp.localizacao, pr.nome AS produtor
FROM Lote_de_Produto lp
JOIN Produtor_Rural pr ON pr.cpf = lp.produtor
WHERE lp.classificacao = 'CONSUMO HUMANO'
ORDER BY lp.data_hora_cadastro DESC;


-- ============================================================
-- 2) Consultas médias/altas
-- ============================================================
-- O enunciado (item 3 da Parte 3) exige no mínimo 5 consultas de
-- complexidade média/alta, diversificadas (junções internas e externas,
-- agrupamentos, subconsultas correlacionadas e não correlacionadas, etc.),
-- sendo 1 delas OBRIGATORIAMENTE com DIVISÃO RELACIONAL. Cada uma deve ser
-- documentada e justificada no relatório.
--
-- Sugestões com base nas funcionalidades já descritas no relatório (seção 2.2):
--
-- [ ] GROUP BY + JOIN — (Funcionário de Administração) Para cada produto,
--     a quantidade total adquirida (via Requisita) e a quantidade total
--     distribuída/cadastrada em um determinado mês.
--
-- [ ] JOIN de múltiplas tabelas — (Funcionário de Administração) Dado um
--     lote de produto, quais beneficiários (solicitações aprovadas) o
--     adquiriram (Lote_de_Produto -> Requisita -> Solicitacao_de_Aquisicao
--     -> Beneficiario).
--
-- [ ] DIVISÃO RELACIONAL (obrigatória) — por exemplo: beneficiários que já
--     requisitaram pelo menos uma porção de TODOS os lotes de uma
--     determinada classificação; ou produtores que tiveram lotes entregues
--     a TODOS os beneficiários cadastrados de uma classificação.
--
-- [ ] Subconsulta CORRELACIONADA — por exemplo: lotes cujo custo de
--     produção é maior que a média dos custos dos lotes do mesmo produtor.
--
-- [ ] Subconsulta NÃO CORRELACIONADA — por exemplo: beneficiários que
--     nunca registraram nenhuma solicitação de aquisição (NOT IN / NOT
--     EXISTS sobre Solicitacao_de_Aquisicao).
--
-- [ ] JUNÇÃO EXTERNA (LEFT/RIGHT JOIN) — por exemplo: todos os produtores
--     e, se houver, a quantidade total de lotes que já cadastraram,
--     incluindo produtores sem nenhum lote cadastrado.
