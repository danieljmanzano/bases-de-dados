-- Arquivo de alimentação inicial da base de dados (Parte 3 - item 2)
-- Contém, no mínimo, 2 tuplas por tabela do esquema (database/esquema.sql),
-- respeitando a ordem de dependência das chaves estrangeiras e todas as
-- restrições de integridade (CHECK, UNIQUE, NOT NULL) definidas no esquema.


-- 1) Produto
-- Catálogo de produtos agrícolas que podem compor um Lote de Produto.
--------------------------------------------------------------------------------------------
INSERT INTO Produto (nome, tipo) VALUES
    ('Alface',  'Hortaliça'),
    ('Batata',  'Tubérculo'),
    ('Cenoura', 'Hortaliça'),
    ('Milho',   'Cereal'),
    ('Soja',    'Grão'),
    ('Tomate',  'Hortaliça');


-- 2) Produtor Rural
-- Os booleanos de tipo de produção refletem os lotes cadastrados mais abaixo
-- (mapeamento do atributo multivalorado "Tipo de Produção", Justificativa 2).
--------------------------------------------------------------------------------------------
INSERT INTO Produtor_Rural
    (cpf, cep, nro, rua, contato, nome, bool_compostagem, bool_consumo_animal, bool_consumo_humano)
VALUES
    ('12345678900', '13560000', 100, 'Rua das Flores',   'produtor1@email.com', 'João da Silva Agropecuária', FALSE, FALSE,  TRUE),
    ('11111111111', '13561000', 200, 'Estrada do Campo', 'produtor2@email.com', 'Maria Oliveira Farming',     FALSE,  TRUE, FALSE),
    ('22222222222', '13562000', 300, 'Rodovia Rural',    'produtor3@email.com', 'Carlos Souza Produções',     TRUE,  FALSE,  FALSE);


-- 3) Transportadora
-- Booleanos de "Tipo de Veículo" representam o atributo multivalorado (Justificativa 1).
--------------------------------------------------------------------------------------------
INSERT INTO Transportadora
    (cnpj, cep, nro, rua, contato, bool_caminhao, bool_van, bool_carro, bool_barco)
VALUES
    ('11222333000144', '13570000', 10, 'Avenida dos Transportes', 'transportadora1@email.com', TRUE,  TRUE,  FALSE, FALSE),
    ('22333444000155', '13571000', 20, 'Rua das Carretas',        'transportadora2@email.com', FALSE, FALSE, TRUE,  TRUE);


-- 4) Beneficiário
-- Uma instituição social (consumo humano), um pequeno pecuarista (consumo animal) e
-- um pequeno agricultor (compostagem), cobrindo as 3 classificações válidas.
--------------------------------------------------------------------------------------------
INSERT INTO Beneficiario (cnpj, cep, nro, rua, contato, nome, classificacao, validacao_elegibilidade) VALUES
    ('11111111000111', '13580000', 1,  'Rua da Esperança',  'beneficiario1@email.com', 'Instituição Social Esperança', 'INSTITUIÇÃO SOCIAL',  'Aprovada'),
    ('22222222000122', '13581000', 2,  'Sítio Recomeço',    'beneficiario2@email.com', 'Sítio Recomeço',                'PEQUENO PECUARISTA',  'Aprovada'),
    ('33333333000133', '13582000', 3,  'Chácara Boa Terra', 'beneficiario3@email.com', 'Chácara Boa Terra',             'PEQUENO AGRICULTOR',  'Aprovada');


-- 5) Filantropo
-- Pessoa física realizando doações financeiras.
--------------------------------------------------------------------------------------------
INSERT INTO Filantropo (cpf, contato, nome) VALUES
    ('33344455566', 'filantropo1@email.com', 'Fernanda Lima'),
    ('44455566011', 'filantropo2@email.com', 'Instituto Verde Doações');


-- 6) Conta Bancária
-- Contas da empresa, usadas para pagar transporte/produtores e receber doações/entregas.
--------------------------------------------------------------------------------------------
INSERT INTO Conta_Bancaria (id_conta, codigo_banco, nro_conta, nro_agencia, tipo) VALUES
    ('CTA-0001', '001', '10000-1', '0001', 'CORRENTE'),
    ('CTA-0002', '237', '20000-2', '0002', 'CORRENTE');


-- 7) Centro Logístico (generalização) - 2 unidades para cada especialização
-- (Centro de Beneficiamento e Distribuição, Armazém e Centro de Compostagem).
--------------------------------------------------------------------------------------------
INSERT INTO Centro_Logistico (cep, nro, rua, tipo_produto) VALUES
    ('13560100', 10, 'Avenida Central',         'CONSUMO HUMANO'),
    ('13560200', 20, 'Rua do Beneficiamento',   'CONSUMO HUMANO'),
    ('13561100', 30, 'Rua dos Armazéns',        'CONSUMO ANIMAL'),
    ('13561200', 40, 'Estrada do Silo',         'CONSUMO ANIMAL'),
    ('13562100', 50, 'Rua da Compostagem',      'COMPOSTAGEM'),
    ('13562200', 60, 'Sítio do Adubo',          'COMPOSTAGEM');


-- 8) Funcionário (generalização) - um funcionário para cada função existente,
-- incluindo o de Finanças, vinculado à conta bancária que gerencia.
--------------------------------------------------------------------------------------------
INSERT INTO Funcionario (cpf, funcao, nome, id_conta) VALUES
    ('10101010101', 'TRIAGEM',         'Ana Beatriz',     NULL),
    ('20202020202', 'DISTRIBUIÇÃO',    'Bruno Costa',     NULL),
    ('30303030303', 'REGULARIZAÇÃO',   'Carla Mendes',    NULL),
    ('40404040404', 'FINANÇAS',        'Diego Ramos',     'CTA-0001'),
    ('50505050505', 'ADMINISTRAÇÃO',   'Elisa Nogueira',  NULL);


-- 9) Transporte
-- 2 transportes de recebimento (produtor -> centro logístico) e 2 de entrega
-- (centro logístico -> beneficiário), todos solicitados pelo funcionário de distribuição.
--------------------------------------------------------------------------------------------
INSERT INTO Transporte
    (placa_veiculo, data_hora_coleta, transportadora, data_entrega, custo, tipo, origem, destino,
     responsavel_distribuicao, conta_pagamento, nota_fiscal_pagamento)
VALUES
    ('ABC1234', '2026-05-01 08:00:00', '11222333000144', '2026-05-01 12:00:00', 150.00, 'RECEBIMENTO',
     'Produtor Rural - João da Silva Agropecuária', 'Centro Logístico - Avenida Central, 10',
     '20202020202', 'CTA-0001', 'NF-T-0001'),

    ('DEF5678', '2026-05-02 09:00:00', '22333444000155', '2026-05-02 14:00:00', 90.00, 'RECEBIMENTO',
     'Produtor Rural - Maria Oliveira Farming', 'Armazém - Rua dos Armazéns, 30',
     '20202020202', 'CTA-0001', 'NF-T-0002'),

    ('GHI9012', '2026-05-03 10:00:00', '11222333000144', '2026-05-03 16:00:00', 60.00, 'ENTREGA',
     'Centro Logístico - Avenida Central, 10', 'Beneficiário - Instituição Social Esperança',
     '20202020202', 'CTA-0002', 'NF-T-0003'),

    ('JKL3456', '2026-05-04 11:00:00', '22333444000155', '2026-05-04 17:00:00', 45.00, 'ENTREGA',
     'Armazém - Rua dos Armazéns, 30', 'Beneficiário - Sítio Recomeço',
     '20202020202', 'CTA-0002', 'NF-T-0004');


-- 10) Lote de Produto
-- 2 lotes para cada classificação (consumo humano, consumo animal, compostagem),
-- triados pelo funcionário de Triagem. Os 2 primeiros já foram coletados (vinculados
-- ao Transporte de recebimento); os demais ainda aguardam transporte (FK nula).
--------------------------------------------------------------------------------------------
INSERT INTO Lote_de_Produto
    (id_lote, produto, data_hora_cadastro, produtor, custo_producao, data_colheita, validade,
     quantidade, classificacao, localizacao, placa_veiculo, data_hora_coleta, conta_bancaria,
     nota_fiscal, responsavel_classificacao)
VALUES
    ('LOTE-0001', 'Alface',  '2026-04-25 07:00:00', '12345678900', 50.00, '2026-04-25', '2026-05-10',
     100.00, 'CONSUMO HUMANO', '-22.0087,-47.8909', 'ABC1234', '2026-05-01 08:00:00', 'CTA-0001', 'NF-L-0001', '10101010101'),

    ('LOTE-0002', 'Tomate',  '2026-04-26 07:30:00', '12345678900', 40.00, '2026-04-26', '2026-05-12',
     80.00,  'CONSUMO HUMANO', '-22.0090,-47.8920', NULL, NULL, NULL, NULL, '10101010101'),

    ('LOTE-0003', 'Milho',   '2026-04-20 08:00:00', '11111111111', 30.00, '2026-04-20', '2026-06-01',
     200.00, 'CONSUMO ANIMAL', '-22.0100,-47.8950', 'DEF5678', '2026-05-02 09:00:00', 'CTA-0001', 'NF-L-0002', '10101010101'),

    ('LOTE-0004', 'Soja',    '2026-04-22 08:15:00', '11111111111', 35.00, '2026-04-22', '2026-06-05',
     150.00, 'CONSUMO ANIMAL', '-22.0080,-47.8900', NULL, NULL, NULL, NULL, '10101010101'),

    ('LOTE-0005', 'Batata',  '2026-04-15 09:00:00', '22222222222', 20.00, '2026-04-15', '2026-05-01',
     120.00, 'COMPOSTAGEM',    '-22.0095,-47.8930', NULL, NULL, NULL, NULL, '10101010101'),

    ('LOTE-0006', 'Cenoura', '2026-04-18 09:30:00', '22222222222', 25.00, '2026-04-18', '2026-05-03',
     90.00,  'COMPOSTAGEM',    '-22.0105,-47.8960', NULL, NULL, NULL, NULL, '10101010101');


-- 11) Centro de Beneficiamento e Distribuição (especialização de Centro Logístico)
--------------------------------------------------------------------------------------------
INSERT INTO Centro_Beneficiamento_Distribuicao (cep, nro, rua, complemento, contato, capacidade, ocupacao) VALUES
    ('13560100', 10, 'Avenida Central',       NULL,        'centro_beneficiamento1@email.com', 5000.00, 1200.00),
    ('13560200', 20, 'Rua do Beneficiamento', 'Galpão 2',  'centro_beneficiamento2@email.com', 4000.00, 800.00);


-- 12) Armazém (especialização de Centro Logístico)
--------------------------------------------------------------------------------------------
INSERT INTO Armazem (cep, nro, rua, complemento, contato, capacidade, ocupacao) VALUES
    ('13561100', 30, 'Rua dos Armazéns', NULL,     'armazem1@email.com', 8000.00, 3000.00),
    ('13561200', 40, 'Estrada do Silo',  'Silo B', 'armazem2@email.com', 6000.00, 1500.00);


-- 13) Centro de Compostagem (especialização de Centro Logístico)
--------------------------------------------------------------------------------------------
INSERT INTO Centro_Compostagem (cep, nro, rua, complemento, contato, capacidade, ocupacao) VALUES
    ('13562100', 50, 'Rua da Compostagem', NULL, 'centro_compostagem1@email.com', 3000.00, 500.00),
    ('13562200', 60, 'Sítio do Adubo',     NULL, 'centro_compostagem2@email.com', 2500.00, 300.00);


-- 14) Lote Consumo Humano (especialização de Lote de Produto)
--------------------------------------------------------------------------------------------
INSERT INTO Lote_Consumo_Humano (lote, cep, nro, rua) VALUES
    ('LOTE-0001', '13560100', 10, 'Avenida Central'),
    ('LOTE-0002', '13560200', 20, 'Rua do Beneficiamento');


-- 15) Lote Consumo Animal (especialização de Lote de Produto)
--------------------------------------------------------------------------------------------
INSERT INTO Lote_Consumo_Animal (lote, cep, nro, rua) VALUES
    ('LOTE-0003', '13561100', 30, 'Rua dos Armazéns'),
    ('LOTE-0004', '13561200', 40, 'Estrada do Silo');


-- 16) Lote Compostagem (especialização de Lote de Produto)
--------------------------------------------------------------------------------------------
INSERT INTO Lote_Compostagem (lote, cep, nro, rua) VALUES
    ('LOTE-0005', '13562100', 50, 'Rua da Compostagem'),
    ('LOTE-0006', '13562200', 60, 'Sítio do Adubo');


-- 17) Solicitação de Aquisição (entidade fraca de Beneficiário)
-- custo_parcial é a soma do custo de produção dos lotes requisitados (ver Requisita).
--------------------------------------------------------------------------------------------
INSERT INTO Solicitacao_de_Aquisicao
    (data_hora, beneficiario, declaracao_finalidade, validacao, custo_parcial, responsavel_regularizacao)
VALUES
    ('2026-05-01 10:00:00', '11111111000111',
     'Distribuição de alimentos para famílias atendidas pela instituição', 'APROVADA', 90.00, '30303030303'),

    ('2026-05-02 11:00:00', '22222222000122',
     'Alimentação de gado leiteiro mantido no sítio', 'APROVADA', 32.50, '30303030303');


-- 18) Lote de Entrega (entidade fraca de Solicitação de Aquisição)
-- Cada lote de entrega está vinculado ao transporte de entrega correspondente (1:1).
--------------------------------------------------------------------------------------------
INSERT INTO Lote_de_Entrega
    (data_hora_aquisicao, beneficiario, custo_total, tamanho_total, status_entrega,
     conta_pagamento, nota_fiscal, placa_veiculo, data_hora_coleta)
VALUES
    ('2026-05-01 10:00:00', '11111111000111', 150.00, 100.00, 'ENTREGUE',
     'CTA-0002', 'NF-E-0001', 'GHI9012', '2026-05-03 10:00:00'),

    ('2026-05-02 11:00:00', '22222222000122', 120.00, 150.00, 'EM ROTA',
     'CTA-0002', 'NF-E-0002', 'JKL3456', '2026-05-04 11:00:00');


-- 19) Requisita (relacionamento N:N entre Solicitação de Aquisição e Lote de Produto)
--------------------------------------------------------------------------------------------
INSERT INTO Requisita (data_hora_aquisicao, beneficiario, lote, porcao_lote) VALUES
    ('2026-05-01 10:00:00', '11111111000111', 'LOTE-0001', 100.00),
    ('2026-05-01 10:00:00', '11111111000111', 'LOTE-0002', 80.00),
    ('2026-05-02 11:00:00', '22222222000122', 'LOTE-0003', 100.00),
    ('2026-05-02 11:00:00', '22222222000122', 'LOTE-0004', 75.00);


-- 20) Titular (atributo multivalorado de Conta Bancária)
--------------------------------------------------------------------------------------------
INSERT INTO Titular (id_conta, nome_titular) VALUES
    ('CTA-0001', 'SOS Abobrinha Ltda'),
    ('CTA-0001', 'Diego Ramos'),
    ('CTA-0002', 'SOS Abobrinha Ltda');


-- 21) Doação (agregação entre Conta Bancária e Filantropo)
--------------------------------------------------------------------------------------------
INSERT INTO Doacao (nota_fiscal, id_conta, filantropo) VALUES
    ('NF-D-0001', 'CTA-0001', '33344455566'),
    ('NF-D-0002', 'CTA-0002', '44455566011');

--DADOS DE TESTE PARA AS 6 CONSULTAS (consultas.sql)

-- Produtores novos, exclusivos destes testes.
INSERT INTO Produtor_Rural (cpf, cep, nro, rua, contato, nome)
VALUES ('44444444444', '44444444', 44, 'Rua Nova A', 'joaop@teste.com', 'João Pereira (Teste)');
INSERT INTO Produtor_Rural (cpf, cep, nro, rua, contato, nome)
VALUES ('55555555555', '55555555', 55, 'Rua Nova B', 'mariaf@teste.com', 'Maria Fontoura (Teste)');
INSERT INTO Produtor_Rural (cpf, cep, nro, rua, contato, nome)
VALUES ('66666666666', '66666666', 66, 'Rua Nova C', 'pedrol@teste.com', 'Pedro Lima (Teste)');

-- Beneficiários novos, exclusivos destes testes.
INSERT INTO Beneficiario (cnpj, cep, nro, rua, contato, nome, classificacao, validacao_elegibilidade)
VALUES ('77777777000177', '70000000', 1, 'Rua das Flores (Teste)', 'inst1@teste.com', 'Instituto Esperança (Teste)', 'INSTITUIÇÃO SOCIAL', 'Aprovada');
INSERT INTO Beneficiario (cnpj, cep, nro, rua, contato, nome, classificacao, validacao_elegibilidade)
VALUES ('88888888000188', '80000000', 2, 'Rua dos Lírios (Teste)', 'sitio2@teste.com', 'Sítio Bom Plantio (Teste)', 'PEQUENO AGRICULTOR', 'Aprovada');
INSERT INTO Beneficiario (cnpj, cep, nro, rua, contato, nome, classificacao, validacao_elegibilidade)
VALUES ('99999999000199', '90000000', 3, 'Rua das Acácias (Teste)', 'fazenda3@teste.com', 'Fazenda Dois Irmãos (Teste)', 'PEQUENO PECUARISTA', 'Aprovada');
INSERT INTO Beneficiario (cnpj, cep, nro, rua, contato, nome, classificacao, validacao_elegibilidade)
VALUES ('10101010000110', '11100000', 4, 'Rua dos Ipês (Teste)', 'assoc4@teste.com', 'Associação Mãos Unidas (Teste)', 'INSTITUIÇÃO SOCIAL', 'Aprovada');
INSERT INTO Beneficiario (cnpj, cep, nro, rua, contato, nome, classificacao, validacao_elegibilidade)
VALUES ('12121212000112', '12200000', 5, 'Rua das Palmeiras (Teste)', 'coop5@teste.com', 'Cooperativa Vida Nova (Teste)', 'INSTITUIÇÃO SOCIAL', 'Aprovada');
INSERT INTO Beneficiario (cnpj, cep, nro, rua, contato, nome, classificacao, validacao_elegibilidade)
VALUES ('13131313000113', '13300000', 6, 'Rua dos Cedros (Teste)', 'lar6@teste.com', 'Lar dos Idosos Pôr do Sol (Teste)', 'INSTITUIÇÃO SOCIAL', 'Aprovada');


-- (1) GROUP BY + JOIN | deveria entrar no total de "quantidade cadastrada" de Tomate em 2024-06
INSERT INTO Lote_de_Produto (id_lote, produto, data_hora_cadastro, produtor, quantidade, classificacao)
VALUES ('LOTE-1001', 'Tomate', '2024-06-05 09:00:00', '44444444444', 100, 'CONSUMO HUMANO');

-- (1) GROUP BY + JOIN | NÃO deveria entrar no total de 2024-06 (cadastrado em 2024-07)
INSERT INTO Lote_de_Produto (id_lote, produto, data_hora_cadastro, produtor, quantidade, classificacao)
VALUES ('LOTE-1002', 'Tomate', '2024-07-01 09:00:00', '55555555555', 50, 'CONSUMO HUMANO');

-- (1) GROUP BY + JOIN | deveria entrar no total de "quantidade adquirida" de Tomate em 2024-06
INSERT INTO Solicitacao_de_Aquisicao (data_hora, beneficiario, declaracao_finalidade, validacao)
VALUES ('2024-06-10 10:00:00', '77777777000177', 'Distribuição mensal', 'APROVADA');
INSERT INTO Requisita (data_hora_aquisicao, beneficiario, lote, porcao_lote)
VALUES ('2024-06-10 10:00:00', '77777777000177', 'LOTE-1001', 30);


-- (2) JOIN de múltiplas tabelas | lote de referência da consulta
INSERT INTO Lote_de_Produto (id_lote, produto, data_hora_cadastro, produtor, quantidade, classificacao)
VALUES ('LOTE-2001', 'Milho', '2024-06-01 08:00:00', '44444444444', 200, 'CONSUMO ANIMAL');

-- (2) JOIN de múltiplas tabelas | deveria retornar (solicitação APROVADA)
INSERT INTO Solicitacao_de_Aquisicao (data_hora, beneficiario, declaracao_finalidade, validacao)
VALUES ('2024-06-12 11:00:00', '77777777000177', 'Distribuição para instituição', 'APROVADA');
INSERT INTO Requisita (data_hora_aquisicao, beneficiario, lote, porcao_lote)
VALUES ('2024-06-12 11:00:00', '77777777000177', 'LOTE-2001', 50);

-- (2) JOIN de múltiplas tabelas | NÃO deveria retornar (solicitação ainda PENDENTE)
INSERT INTO Solicitacao_de_Aquisicao (data_hora, beneficiario, declaracao_finalidade, validacao)
VALUES ('2024-06-13 11:00:00', '88888888000188', 'Distribuição para produtor', 'PENDENTE');
INSERT INTO Requisita (data_hora_aquisicao, beneficiario, lote, porcao_lote)
VALUES ('2024-06-13 11:00:00', '88888888000188', 'LOTE-2001', 40);


-- (3) DIVISÃO RELACIONAL | segundo lote de classificação 'CONSUMO HUMANO' (junto com LOTE-1001)
INSERT INTO Lote_de_Produto (id_lote, produto, data_hora_cadastro, produtor, quantidade, classificacao)
VALUES ('LOTE-3002', 'Milho', '2024-06-02 08:00:00', '55555555555', 80, 'CONSUMO HUMANO');

-- (3) DIVISÃO RELACIONAL | deveria retornar (requisitou TODOS os lotes 'CONSUMO HUMANO'
-- existentes no banco — a consulta considera o universo completo da classificação, não
-- só os lotes criados para este teste, então é preciso cobrir também LOTE-0001, LOTE-0002
-- (do seed original) e LOTE-1002 (do teste 1). A cobertura de LOTE-4001/LOTE-4002 (criados
-- só no teste 4, mais abaixo) é completada depois que esses lotes existem.
INSERT INTO Solicitacao_de_Aquisicao (data_hora, beneficiario, declaracao_finalidade, validacao)
VALUES ('2024-06-14 09:00:00', '99999999000199', 'Aquisição completa', 'APROVADA');
INSERT INTO Requisita (data_hora_aquisicao, beneficiario, lote, porcao_lote)
VALUES
    ('2024-06-14 09:00:00', '99999999000199', 'LOTE-1001', 10),
    ('2024-06-14 09:00:00', '99999999000199', 'LOTE-3002', 15),
    ('2024-06-14 09:00:00', '99999999000199', 'LOTE-0001', 1),
    ('2024-06-14 09:00:00', '99999999000199', 'LOTE-0002', 1),
    ('2024-06-14 09:00:00', '99999999000199', 'LOTE-1002', 1);

-- (3) DIVISÃO RELACIONAL | NÃO deveria retornar (requisitou só LOTE-1001, faltando LOTE-3002)
INSERT INTO Solicitacao_de_Aquisicao (data_hora, beneficiario, declaracao_finalidade, validacao)
VALUES ('2024-06-15 09:00:00', '10101010000110', 'Aquisição parcial', 'APROVADA');
INSERT INTO Requisita (data_hora_aquisicao, beneficiario, lote, porcao_lote)
VALUES ('2024-06-15 09:00:00', '10101010000110', 'LOTE-1001', 5);


-- (4) SUBCONSULTA CORRELACIONADA | deveria retornar (custo 300 > média do produtor 44444444444, que é 200)
INSERT INTO Lote_de_Produto (id_lote, produto, data_hora_cadastro, produtor, custo_producao, quantidade, classificacao)
VALUES ('LOTE-4002', 'Tomate', '2024-06-21 10:00:00', '44444444444', 300.00, 10, 'CONSUMO HUMANO');

-- (4) SUBCONSULTA CORRELACIONADA | NÃO deveria retornar (custo 100 < média do produtor 44444444444, que é 200)
INSERT INTO Lote_de_Produto (id_lote, produto, data_hora_cadastro, produtor, custo_producao, quantidade, classificacao)
VALUES ('LOTE-4001', 'Tomate', '2024-06-20 10:00:00', '44444444444', 100.00, 10, 'CONSUMO HUMANO');

-- (3) DIVISÃO RELACIONAL | completa a cobertura de 99999999000199 sobre os lotes 'CONSUMO
-- HUMANO' LOTE-4001 e LOTE-4002, que só existem a partir deste ponto do arquivo.
INSERT INTO Requisita (data_hora_aquisicao, beneficiario, lote, porcao_lote)
VALUES
    ('2024-06-14 09:00:00', '99999999000199', 'LOTE-4001', 1),
    ('2024-06-14 09:00:00', '99999999000199', 'LOTE-4002', 1);


-- (5) SUBCONSULTA NÃO CORRELACIONADA | deveria retornar (Beneficiario 12121212000112 nunca fez nenhuma Solicitacao_de_Aquisicao)
-- (nenhuma inserção adicional necessária: ausência de Solicitacao_de_Aquisicao é o próprio caso de teste)

-- (5) SUBCONSULTA NÃO CORRELACIONADA | NÃO deveria retornar (Beneficiario 13131313000113 já possui uma Solicitacao_de_Aquisicao)
INSERT INTO Solicitacao_de_Aquisicao (data_hora, beneficiario, declaracao_finalidade, validacao)
VALUES ('2024-06-16 09:00:00', '13131313000113', 'Solicitação de teste', 'APROVADA');


-- (6) JUNÇÃO EXTERNA (LEFT JOIN) | deveria retornar com soma de quantidades > 0 (produtor 44444444444 possui lotes cadastrados acima)
-- (nenhuma inserção adicional necessária: os lotes de '44444444444' inseridos acima já cobrem este caso)

-- (6) JUNÇÃO EXTERNA (LEFT JOIN) | deveria retornar mesmo SEM nenhum lote, com quantidade total = 0 (produtor 66666666666 não tem nenhum Lote_de_Produto)
-- (nenhuma inserção adicional necessária: a ausência de Lote_de_Produto para '66666666666' é o próprio caso de teste;
--  é o caso que uma junção interna (INNER JOIN), incorretamente, NÃO retornaria)