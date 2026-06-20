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

-- ---------------------------------------------------------------------
-- 1) GROUP BY + JOIN
--   (Funcionário de Administração) Para cada produto, a quantidade total 
--   adquirida (via Requisita) e a quantidade total distribuída/cadastrada
--   em um determinado mês.
--
-- Eficiência: o filtro de mês usa um intervalo (>= / <) em vez de
--   TO_CHAR(coluna, 'YYYY-MM'), para que seja possível usar o índice na busca.
-- ---------------------------------------------------------------------
SELECT
    p.nome                                  AS produto,
    SUM(req_por_lote.quantidade_requisitada) AS quantidade_total_adquirida,
    SUM(lp.quantidade)                       AS quantidade_total_cadastrada
FROM Produto p
LEFT JOIN Lote_de_Produto lp
    ON lp.produto = p.nome
   AND lp.data_hora_cadastro >= '2024-06-01'
   AND lp.data_hora_cadastro <  '2024-07-01'
LEFT JOIN (
    SELECT
        r.lote,
        SUM(r.porcao_lote) AS quantidade_requisitada
    FROM Requisita r
    JOIN Solicitacao_de_Aquisicao sa
        ON sa.data_hora    = r.data_hora_aquisicao
       AND sa.beneficiario = r.beneficiario
    WHERE sa.data_hora >= '2024-06-01'
      AND sa.data_hora <  '2024-07-01'
    GROUP BY r.lote
) req_por_lote
    ON req_por_lote.lote = lp.id_lote
GROUP BY p.nome
ORDER BY p.nome;
 
 
-- ---------------------------------------------------------------------
-- 2) JOIN de múltiplas tabelas
-- (Funcionário de Administração) Dado um lote de produto, quais
-- beneficiários (somente solicitações aprovadas) o adquiriram:
-- Lote_de_Produto -> Requisita -> Solicitacao_de_Aquisicao -> Beneficiario
--
-- Parâmetro: id do lote -> 'LOTE-0001' (ajuste conforme necessário)
-- ---------------------------------------------------------------------
SELECT DISTINCT
    b.cnpj,
    b.nome,
    b.classificacao
FROM Lote_de_Produto lp
JOIN Requisita r
    ON r.lote = lp.id_lote
JOIN Solicitacao_de_Aquisicao sa
    ON sa.data_hora    = r.data_hora_aquisicao
   AND sa.beneficiario = r.beneficiario
JOIN Beneficiario b
    ON b.cnpj = sa.beneficiario
WHERE lp.id_lote = 'LOTE-0001'
  AND UPPER(sa.validacao) = 'APROVADA';
 
 
-- ---------------------------------------------------------------------
-- 3) DIVISÃO RELACIONAL (obrigatória)
-- Beneficiários que já requisitaram pelo menos uma porção de TODOS os
-- lotes de uma determinada classificação (ex.: 'CONSUMO HUMANO').
--
-- Lógica: não existe lote daquela classificação que o beneficiário
-- NÃO tenha requisitado.
--
-- Parâmetro: classificação -> 'CONSUMO HUMANO' (ajuste conforme necessário)
--
-- Eficiência: comparação direta (=), sem UPPER(), pois classificacao é
-- sempre armazenada em maiúsculas (ver dados.sql e o mapeamento em
-- backend/app.py). UPPER(coluna) impede o uso de idx_lote_produto_classificacao.
-- ---------------------------------------------------------------------
SELECT
    b.cnpj,
    b.nome
FROM Beneficiario b
WHERE NOT EXISTS (
    -- existe algum lote da classificação alvo...
    SELECT 1
    FROM Lote_de_Produto lp
    WHERE lp.classificacao = 'CONSUMO HUMANO'
      AND NOT EXISTS (
          -- ...que o beneficiário b NUNCA requisitou?
          SELECT 1
          FROM Requisita r
          JOIN Solicitacao_de_Aquisicao sa
              ON sa.data_hora    = r.data_hora_aquisicao
             AND sa.beneficiario = r.beneficiario
          WHERE r.lote          = lp.id_lote
            AND sa.beneficiario = b.cnpj
      )
);
 
 
-- ---------------------------------------------------------------------
-- 4) SUBCONSULTA CORRELACIONADA
-- Lotes cujo custo de produção é maior que a média dos custos dos
-- lotes do mesmo produtor.
--
-- Eficiência: subconsulta reexecutada por linha externa — idx_lote_produto_produtor
--   garante Index Scan ao invés de Seq Scan. Custo alto se poucos produtores com
--   muitos lotes cada; aceitável no cenário esperado (muitos produtores, poucos lotes).
--   Se o volume crescer, considerar window function (calcula a média uma vez por grupo).
-- ---------------------------------------------------------------------
SELECT
    lp.id_lote,
    lp.produto,
    lp.produtor,
    lp.custo_producao
FROM Lote_de_Produto lp
WHERE lp.custo_producao > (
    SELECT AVG(lp2.custo_producao)
    FROM Lote_de_Produto lp2
    WHERE lp2.produtor = lp.produtor   -- referência à linha externa: torna a subconsulta correlacionada
)
ORDER BY lp.produtor, lp.custo_producao DESC;
 
 
-- ---------------------------------------------------------------------
-- 5) SUBCONSULTA NÃO CORRELACIONADA
-- Beneficiários que nunca registraram nenhuma solicitação de aquisição.
-- ---------------------------------------------------------------------
SELECT
    b.cnpj,
    b.nome
FROM Beneficiario b
WHERE b.cnpj NOT IN (
    SELECT sa.beneficiario
    FROM Solicitacao_de_Aquisicao sa
);
 
-- Versão equivalente com NOT EXISTS (mais segura contra NULLs):
-- SELECT b.cnpj, b.nome
-- FROM Beneficiario b
-- WHERE NOT EXISTS (
--     SELECT 1
--     FROM Solicitacao_de_Aquisicao sa
--     WHERE sa.beneficiario = b.cnpj
-- );
 
 
-- ---------------------------------------------------------------------
-- 6) JUNÇÃO EXTERNA (LEFT JOIN)
-- Todos os produtores e, se houver, a quantidade total de lotes que já
-- cadastraram, incluindo produtores sem nenhum lote cadastrado.
-- ---------------------------------------------------------------------
SELECT
    pr.cpf,
    pr.nome,
    COUNT(lp.id_lote)              AS qtd_lotes_cadastrados,
    COALESCE(SUM(lp.quantidade), 0) AS quantidade_total_cadastrada
FROM Produtor_Rural pr
LEFT JOIN Lote_de_Produto lp
    ON lp.produtor = pr.cpf
GROUP BY pr.cpf, pr.nome
ORDER BY pr.nome;
 
