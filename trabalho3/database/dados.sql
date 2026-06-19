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
    ('12345678900', '13560000', 100, 'Rua das Flores',   '(16) 99999-0001', 'João da Silva Agropecuária', FALSE, FALSE,  TRUE),
    ('11111111111', '13561000', 200, 'Estrada do Campo', '(16) 99999-0002', 'Maria Oliveira Farming',     FALSE,  TRUE, FALSE),
    ('22222222222', '13562000', 300, 'Rodovia Rural',    '(16) 99999-0003', 'Carlos Souza Produções',     TRUE,  FALSE,  FALSE);


-- 3) Transportadora
-- Booleanos de "Tipo de Veículo" representam o atributo multivalorado (Justificativa 1).
--------------------------------------------------------------------------------------------
INSERT INTO Transportadora
    (cnpj, cep, nro, rua, contato, bool_caminhao, bool_van, bool_carro, bool_barco)
VALUES
    ('11222333000144', '13570000', 10, 'Avenida dos Transportes', '(16) 98888-0001', TRUE,  TRUE,  FALSE, FALSE),
    ('22333444000155', '13571000', 20, 'Rua das Carretas',        '(16) 98888-0002', FALSE, FALSE, TRUE,  TRUE);


-- 4) Beneficiário
-- Uma instituição social (consumo humano), um pequeno pecuarista (consumo animal) e
-- um pequeno agricultor (compostagem), cobrindo as 3 classificações válidas.
--------------------------------------------------------------------------------------------
INSERT INTO Beneficiario (cnpj, cep, nro, rua, contato, nome, classificacao, validacao_elegibilidade) VALUES
    ('11111111000111', '13580000', 1,  'Rua da Esperança',  '(16) 97777-0001', 'Instituição Social Esperança', 'INSTITUIÇÃO SOCIAL',  'Certificado de utilidade pública nº 001/2025'),
    ('22222222000122', '13581000', 2,  'Sítio Recomeço',    '(16) 97777-0002', 'Sítio Recomeço',                'PEQUENO PECUARISTA',  'Declaração de aptidão ao PRONAF nº 045/2025'),
    ('33333333000133', '13582000', 3,  'Chácara Boa Terra', '(16) 97777-0003', 'Chácara Boa Terra',             'PEQUENO AGRICULTOR',  'Declaração de aptidão ao PRONAF nº 078/2025');


-- 5) Filantropo
-- Pessoa física realizando doações financeiras.
--------------------------------------------------------------------------------------------
INSERT INTO Filantropo (cpf, contato, nome) VALUES
    ('33344455566', '(16) 96666-0001', 'Fernanda Lima'),
    ('44455566011', '(16) 96666-0002', 'Instituto Verde Doações');


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
    ('LOTE-0001', 'Alface',  '2026-04-25 07:00:00', '12345678900',    50.00, '2026-04-25', '2026-05-10',
     100.00, 'CONSUMO HUMANO', '-22.0087,-47.8909', 'ABC1234', '2026-05-01 08:00:00', 'CTA-0001', 'NF-L-0001', '10101010101'),

    ('LOTE-0002', 'Tomate',  '2026-04-26 07:30:00', '98765432011', 40.00, '2026-04-26', '2026-05-12',
     80.00,  'CONSUMO HUMANO', '-22.0090,-47.8920', NULL, NULL, NULL, NULL, '10101010101'),

    ('LOTE-0003', 'Milho',   '2026-04-20 08:00:00', '11122233344',    30.00, '2026-04-20', '2026-06-01',
     200.00, 'CONSUMO ANIMAL', '-22.0100,-47.8950', 'DEF5678', '2026-05-02 09:00:00', 'CTA-0001', 'NF-L-0002', '10101010101'),

    ('LOTE-0004', 'Soja',    '2026-04-22 08:15:00', '12345678900',    35.00, '2026-04-22', '2026-06-05',
     150.00, 'CONSUMO ANIMAL', '-22.0080,-47.8900', NULL, NULL, NULL, NULL, '10101010101'),

    ('LOTE-0005', 'Batata',  '2026-04-15 09:00:00', '98765432011', 20.00, '2026-04-15', '2026-05-01',
     120.00, 'COMPOSTAGEM',    '-22.0095,-47.8930', NULL, NULL, NULL, NULL, '10101010101'),

    ('LOTE-0006', 'Cenoura', '2026-04-18 09:30:00', '11122233344',    25.00, '2026-04-18', '2026-05-03',
     90.00,  'COMPOSTAGEM',    '-22.0105,-47.8960', NULL, NULL, NULL, NULL, '10101010101');


-- 11) Centro de Beneficiamento e Distribuição (especialização de Centro Logístico)
--------------------------------------------------------------------------------------------
INSERT INTO Centro_Beneficiamento_Distribuicao (cep, nro, rua, complemento, contato, capacidade, ocupacao) VALUES
    ('13560100', 10, 'Avenida Central',       NULL,        '(16) 3333-0001', 5000.00, 1200.00),
    ('13560200', 20, 'Rua do Beneficiamento', 'Galpão 2',  '(16) 3333-0002', 4000.00, 800.00);


-- 12) Armazém (especialização de Centro Logístico)
--------------------------------------------------------------------------------------------
INSERT INTO Armazem (cep, nro, rua, complemento, contato, capacidade, ocupacao) VALUES
    ('13561100', 30, 'Rua dos Armazéns', NULL,     '(16) 3333-0003', 8000.00, 3000.00),
    ('13561200', 40, 'Estrada do Silo',  'Silo B', '(16) 3333-0004', 6000.00, 1500.00);


-- 13) Centro de Compostagem (especialização de Centro Logístico)
--------------------------------------------------------------------------------------------
INSERT INTO Centro_Compostagem (cep, nro, rua, complemento, contato, capacidade, ocupacao) VALUES
    ('13562100', 50, 'Rua da Compostagem', NULL, '(16) 3333-0005', 3000.00, 500.00),
    ('13562200', 60, 'Sítio do Adubo',     NULL, '(16) 3333-0006', 2500.00, 300.00);


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
    ('2026-05-05 10:00:00', '11111111000111',
     'Distribuição de alimentos para famílias atendidas pela instituição', 'APROVADA', 90.00, '30303030303'),

    ('2026-05-06 11:00:00', '22222222000122',
     'Alimentação de gado leiteiro mantido no sítio', 'APROVADA', 32.50, '30303030303');


-- 18) Lote de Entrega (entidade fraca de Solicitação de Aquisição)
-- Cada lote de entrega está vinculado ao transporte de entrega correspondente (1:1).
--------------------------------------------------------------------------------------------
INSERT INTO Lote_de_Entrega
    (data_hora_aquisicao, beneficiario, custo_total, tamanho_total, status_entrega,
     conta_pagamento, nota_fiscal, placa_veiculo, data_hora_coleta)
VALUES
    ('2026-05-05 10:00:00', '11111111000111', 150.00, 100.00, 'ENTREGUE',
     'CTA-0002', 'NF-E-0001', 'GHI9012', '2026-05-03 10:00:00'),

    ('2026-05-06 11:00:00', '22222222000122', 120.00, 150.00, 'EM ROTA',
     'CTA-0002', 'NF-E-0002', 'JKL3456', '2026-05-04 11:00:00');


-- 19) Requisita (relacionamento N:N entre Solicitação de Aquisição e Lote de Produto)
--------------------------------------------------------------------------------------------
INSERT INTO Requisita (data_hora_aquisicao, beneficiario, lote, porcao_lote) VALUES
    ('2026-05-05 10:00:00', '11111111000111', 'LOTE-0001', 100.00),
    ('2026-05-05 10:00:00', '11111111000111', 'LOTE-0002', 80.00),
    ('2026-05-06 11:00:00', '22222222000122', 'LOTE-0003', 100.00),
    ('2026-05-06 11:00:00', '22222222000122', 'LOTE-0004', 75.00);


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
