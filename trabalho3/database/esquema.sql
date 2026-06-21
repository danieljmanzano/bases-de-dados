-- Arquivo com o esquema do banco de dados (Parte 3 - item 1)

-- ==============================================================================
-- Convenções do esquema
-- 
--  Chaves estrangeiras (ON DELETE):
--    - RESTRICT: Protege histórico físico, contábil e logístico (ex: Produto, Doacao)
--    - CASCADE: Aplica-se a entidades fracas e tabelas associativas (ex: Solicitacao_de_Aquisicao)
--    - SET NULL: Preserva transações ao desvincular responsáveis (ex: Funcionario)
--
--  Validações (CHECK):
--    - Contatos: Validação de formato de e-mail (LIKE '%@%')
--    - Capacidade/Ocupação: Valores numéricos; ocupação restrita ao limite da capacidade
--    - Datas: Eventos seguintes ocorrem no mesmo instante ou após eventos anteriores
--
--  Entidades fracas / chaves compostas herdadas:
--    - Solicitacao_de_Aquisicao é entidade fraca de Beneficiario: chave = (data_hora, beneficiario).
--    - Lote_de_Entrega e Requisita são, por sua vez, entidades fracas/associativas que
--      herdam essa mesma chave composta (data_hora_aquisicao, beneficiario) como parte
--      da própria chave primária e como FK para Solicitacao_de_Aquisicao.
-- ==============================================================================


-- Limpeza do banco de dados (ordem de exclusão respeitando as FKs)
-- Toda vez que o script é executado, isso garante que o banco de dados esteja limpo para a criação das tabelas
--------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS Lote_Consumo_Humano;
DROP TABLE IF EXISTS Lote_Consumo_Animal;
DROP TABLE IF EXISTS Lote_Compostagem;

DROP TABLE IF EXISTS Centro_Beneficiamento_Distribuicao;
DROP TABLE IF EXISTS Armazem;
DROP TABLE IF EXISTS Centro_Compostagem;

DROP TABLE IF EXISTS Requisita;
DROP TABLE IF EXISTS Lote_de_Entrega;
DROP TABLE IF EXISTS Solicitacao_de_Aquisicao;

DROP TABLE IF EXISTS Doacao;
DROP TABLE IF EXISTS Titular;

DROP TABLE IF EXISTS Lote_de_Produto;
DROP SEQUENCE IF EXISTS seq_lote_id;
DROP TABLE IF EXISTS Transporte;
DROP TABLE IF EXISTS Funcionario;

DROP TABLE IF EXISTS Centro_Logistico;
DROP TABLE IF EXISTS Conta_Bancaria;
DROP TABLE IF EXISTS Filantropo;
DROP TABLE IF EXISTS Beneficiario;
DROP TABLE IF EXISTS Transportadora;
DROP TABLE IF EXISTS Produtor_Rural;
DROP TABLE IF EXISTS Produto;
--------------------------------------------------------------------------------------------

-- Tabelas que não possuem chaves estrangeiras

--------------------------------------------------------------------------------------------

-- Catálogo de produtos agrícolas (ex.: Alface, Milho) que podem compor um Lote_de_Produto.
CREATE TABLE Produto (
    nome   VARCHAR(50)    NOT NULL,
    tipo   VARCHAR(20),

    CONSTRAINT pk_produto 
        PRIMARY KEY (nome),

    CONSTRAINT ck_produto_tipo CHECK (UPPER(tipo) IN (
        'HORTALIÇA',
        'TUBÉRCULO',
        'LEGUMINOSA',
        'FRUTA',
        'CEREAL',
        'GRÃO',
        'ADUBO',
        'RAÇÃO'
    ))
);


-- Pessoa física que cadastra excedentes agrícolas (Lote_de_Produto) no sistema.
CREATE TABLE Produtor_Rural (
    cpf                     VARCHAR(11)     NOT NULL, -- CPF: produtor rural é pessoa física
    cep                     VARCHAR(8)      NOT NULL,
    nro                     INT             NOT NULL,
    rua                     VARCHAR(100)    NOT NULL,
    complemento             VARCHAR(100),
    contato                 VARCHAR(50)     NOT NULL, -- Email
    nome                    VARCHAR(100)    NOT NULL,
    bool_compostagem        BOOLEAN DEFAULT FALSE,
    bool_consumo_animal     BOOLEAN DEFAULT FALSE,
    bool_consumo_humano     BOOLEAN DEFAULT FALSE,

    CONSTRAINT pk_produtor_rural
        PRIMARY KEY (cpf),

    CONSTRAINT ck_produtor_rural_cpf_len
        CHECK (CHAR_LENGTH(cpf) = 11),

    CONSTRAINT ck_produtor_rural_cep_len 
        CHECK (CHAR_LENGTH(cep) = 8),
    
    CONSTRAINT ck_produtor_rural_nro 
        CHECK (nro > 0), -- Nro de endereço não pode ser negativo

    CONSTRAINT ck_produtor_rural_contato
        CHECK (contato LIKE '%@%') -- Validação básica de formato de e-mail na base de dados. Validações de domínio devem ser feitas na aplicação
);


-- Empresa responsável por executar os Transportes solicitados pela distribuição.
CREATE TABLE Transportadora (
    cnpj                VARCHAR(14)     NOT NULL,
    cep                 VARCHAR(8)      NOT NULL,
    nro                 INT             NOT NULL,
    rua                 VARCHAR(100)    NOT NULL,
    complemento         VARCHAR(100),
    contato             VARCHAR(50),
    bool_caminhao       BOOLEAN DEFAULT FALSE,
    bool_van            BOOLEAN DEFAULT FALSE,
    bool_carro          BOOLEAN DEFAULT FALSE,
    bool_barco          BOOLEAN DEFAULT FALSE,

    CONSTRAINT pk_transportadora 
        PRIMARY KEY (cnpj),

    CONSTRAINT ck_transportadora_cnpj_len 
        CHECK (CHAR_LENGTH(cnpj) = 14),

    CONSTRAINT ck_transportadora_cep_len 
        CHECK (CHAR_LENGTH(cep) = 8),

    CONSTRAINT ck_transportadora_nro 
        CHECK (nro > 0),

    CONSTRAINT ck_transportadora_contato
        CHECK (contato LIKE '%@%') 
);


-- Organização (instituição social, pequeno agricultor ou pecuarista) que pode solicitar
-- lotes correspondentes à sua classificação (ver Solicitacao_de_Aquisicao).
CREATE TABLE Beneficiario (
    cnpj                    VARCHAR(14)     NOT NULL, -- CNPJ: beneficiário é sempre uma organização (instituição, sítio etc.)
    cep                     VARCHAR(8)      NOT NULL,
    nro                     INT             NOT NULL,
    rua                     VARCHAR(100)    NOT NULL,
    complemento             VARCHAR(100),
    contato                 VARCHAR(50)     NOT NULL,
    nome                    VARCHAR(100)    NOT NULL,
    classificacao           VARCHAR(50),
    validacao_elegibilidade VARCHAR(255)    NOT NULL,

    CONSTRAINT pk_beneficiario
        PRIMARY KEY (cnpj),

    CONSTRAINT ck_beneficiario_cnpj_len
        CHECK (CHAR_LENGTH(cnpj) = 14),

    CONSTRAINT ck_beneficiario_cep_len 
        CHECK (CHAR_LENGTH(cep) = 8),
    
    CONSTRAINT ck_beneficiario_nro 
        CHECK (nro > 0),
    
    CONSTRAINT ck_beneficiario_classificacao 
        CHECK (UPPER(classificacao) IN (
            'PEQUENO AGRICULTOR', 
            'PEQUENO PECUARISTA', 
            'INSTITUIÇÃO SOCIAL'
        )),

    CONSTRAINT ck_beneficiario_contato
        CHECK (contato LIKE '%@%'), 

    CONSTRAINT ck_beneficiario_validacao_elegibilidade
        CHECK (UPPER(validacao_elegibilidade) IN (
            'APROVADA',
            'REPROVADA',
            'PENDENTE', -- 'pendente' indica que não começou a ser validado ainda
            'EM ANALISE' -- 'em analise' indica que está no processo de validação
        ))
);


-- Pessoa física que realiza doações financeiras para as contas bancárias da empresa.
CREATE TABLE Filantropo (
    cpf         VARCHAR(11)     NOT NULL, -- CPF: filantropo é pessoa física
    contato     VARCHAR(50),
    nome        VARCHAR(100),

    CONSTRAINT pk_filantropo
        PRIMARY KEY (cpf),

    CONSTRAINT ck_filantropo_cpf_len
        CHECK (CHAR_LENGTH(cpf) = 11),

    CONSTRAINT ck_filantropo_contato
        CHECK (contato LIKE '%@%') 
);


-- Conta da empresa usada para pagar produtores/transporte e receber doações e
-- pagamentos de entregas. Pode ter mais de um titular (ver Titular).
CREATE TABLE Conta_Bancaria (
    id_conta        VARCHAR(15)     NOT NULL,
    codigo_banco    VARCHAR(10)     NOT NULL,
    nro_conta       VARCHAR(20)     NOT NULL,
    nro_agencia     VARCHAR(10)     NOT NULL,
    tipo            VARCHAR(9)      NOT NULL,

    CONSTRAINT pk_conta_bancaria 
        PRIMARY KEY (id_conta),

    CONSTRAINT unq_conta_bancaria 
        UNIQUE (codigo_banco, nro_conta, nro_agencia),

    CONSTRAINT ck_conta_bancaria_tipo
        CHECK (UPPER(tipo) IN (
            'CORRENTE',
            'POUPANCA',
            'PAGAMENTO'
        ))
);


-- Generalização dos locais de armazenamento/processamento de lotes. tipo_produto indica
-- qual especialização abaixo (Centro_Beneficiamento_Distribuicao, Armazem ou
-- Centro_Compostagem) contém os demais atributos deste centro.
CREATE TABLE Centro_Logistico (
    cep             VARCHAR(8)      NOT NULL,
    nro             INT             NOT NULL,
    rua             VARCHAR(100)    NOT NULL,
    tipo_produto    VARCHAR(50)     NOT NULL,

    CONSTRAINT pk_centro_logistico 
        PRIMARY KEY (cep, nro, rua),

    CONSTRAINT ck_centro_logistico_cep_len 
        CHECK (CHAR_LENGTH(cep) = 8),
    
    CONSTRAINT ck_centro_logistico_nro 
        CHECK (nro > 0)
);


-- Especializações de Centro Logístico

-- Recebe e processa lotes 'CONSUMO HUMANO' antes da entrega a instituições sociais.
CREATE TABLE Centro_Beneficiamento_Distribuicao (
    cep             VARCHAR(8)      NOT NULL,
    nro             INT             NOT NULL,
    rua             VARCHAR(100)    NOT NULL,
    complemento     VARCHAR(100),
    contato         VARCHAR(50), 
    capacidade      DECIMAL(10, 2),
    ocupacao        DECIMAL(10, 2),

    CONSTRAINT pk_centro_beneficiamento
        PRIMARY KEY (cep, nro, rua),

    CONSTRAINT ck_centro_beneficiamento_capacidade 
        CHECK (capacidade > 0), -- Capacidade deve ser maior que 0

    CONSTRAINT ck_centro_beneficiamento_ocupacao 
        CHECK (ocupacao >= 0 AND ocupacao <= capacidade), -- Ocupação deve estar entre 0 e capacidade

    CONSTRAINT ck_centro_beneficiamento_contato
        CHECK (contato LIKE '%@%')
);

-- Recebe e armazena lotes 'CONSUMO ANIMAL' antes da entrega a pequenos pecuaristas.
CREATE TABLE Armazem (
    cep             VARCHAR(8)      NOT NULL,
    nro             INT             NOT NULL,
    rua             VARCHAR(100)    NOT NULL,
    complemento     VARCHAR(100),
    contato         VARCHAR(50),
    capacidade      DECIMAL(10, 2),
    ocupacao        DECIMAL(10, 2),

    CONSTRAINT pk_armazem
        PRIMARY KEY (cep, nro, rua),

    CONSTRAINT ck_armazem_capacidade 
        CHECK (capacidade > 0),  

    CONSTRAINT ck_armazem_ocupacao 
        CHECK (ocupacao >= 0 AND ocupacao <= capacidade),

    CONSTRAINT ck_armazem_contato
        CHECK (contato LIKE '%@%')
);

-- Recebe lotes 'COMPOSTAGEM', processa o adubo resultante e o entrega a pequenos agricultores.
CREATE TABLE Centro_Compostagem (
    cep             VARCHAR(8)      NOT NULL,
    nro             INT             NOT NULL,
    rua             VARCHAR(100)    NOT NULL,
    complemento     VARCHAR(100),
    contato         VARCHAR(50), 
    capacidade      DECIMAL(10, 2),
    ocupacao        DECIMAL(10, 2),

    CONSTRAINT pk_centro_compostagem
        PRIMARY KEY (cep, nro, rua),

    CONSTRAINT ck_centro_compostagem_capacidade 
        CHECK (capacidade > 0),  

    CONSTRAINT ck_centro_compostagem_ocupacao 
        CHECK (ocupacao >= 0 AND ocupacao <= capacidade), 

    CONSTRAINT ck_centro_compostagem_contato
        CHECK (contato LIKE '%@%')
);

--------------------------------------------------------------------------------------------

-- Tabelas com FKs

--------------------------------------------------------------------------------------------

-- Generalização de todo funcionário da empresa. O atributo funcao (critério da
-- especialização) determina o papel exercido: TRIAGEM, DISTRIBUIÇÃO, REGULARIZAÇÃO,
-- FINANÇAS ou ADMINISTRAÇÃO. Apenas funcionários de FINANÇAS preenchem id_conta.
CREATE TABLE Funcionario (
    cpf                     VARCHAR(11)     NOT NULL, 
    funcao                  VARCHAR(50), 
    nome                    VARCHAR(100)    NOT NULL, 
    id_conta                VARCHAR(15),                      

    CONSTRAINT pk_funcionario 
        PRIMARY KEY (cpf),

    CONSTRAINT fk_funcionario_conta -- Para funcionários de finanças, esse campo referencia a conta
        FOREIGN KEY (id_conta) REFERENCES Conta_Bancaria(id_conta)
        ON DELETE SET NULL, -- O funcionário é mantido sem conta caso ela seja removida

    CONSTRAINT ck_funcionario_cpf_len 
        CHECK (CHAR_LENGTH(cpf) = 11)
);


-- Operação de transporte de RECEBIMENTO (produtor -> centro logístico) ou de
-- ENTREGA (centro logístico -> beneficiário). Identificado pela combinação
-- placa do veículo + data/hora de coleta (um veículo pode rodar mais de uma vez,
-- desde que em horários de coleta diferentes).
CREATE TABLE Transporte (
    placa_veiculo               VARCHAR(10)     NOT NULL,
    data_hora_coleta            TIMESTAMP       NOT NULL,
    transportadora              VARCHAR(14)     NOT NULL,
    data_entrega                TIMESTAMP,               
    custo                       DECIMAL(10, 2), 
    tipo                        VARCHAR(11),
    origem                      VARCHAR(255)    NOT NULL,
    destino                     VARCHAR(255)    NOT NULL,
    responsavel_distribuicao    VARCHAR(11), 
    conta_pagamento             VARCHAR(15),              
    nota_fiscal_pagamento       VARCHAR(50),              

    CONSTRAINT pk_transporte 
        PRIMARY KEY (placa_veiculo, data_hora_coleta), 

    CONSTRAINT fk_transporte_transportadora 
        FOREIGN KEY (transportadora) REFERENCES Transportadora(cnpj)
        ON DELETE RESTRICT, -- Protege o histórico logístico
                            -- Deve haver um tratamento específico sobre transportes registrados cuja transportadora tenha sido removida

    CONSTRAINT fk_transporte_funcionario 
        FOREIGN KEY (responsavel_distribuicao) REFERENCES Funcionario(cpf)
        ON DELETE SET NULL, -- A saída/remoção do funcionário desvincula o responsável, mas preserva o registro da operação de frete

    CONSTRAINT fk_transporte_conta 
        FOREIGN KEY (conta_pagamento) REFERENCES Conta_Bancaria(id_conta)
        ON DELETE SET NULL,

    CONSTRAINT ck_transporte_data 
        CHECK (data_entrega >= data_hora_coleta), -- A entrega deve ocorrer após ou no momento da coleta

    CONSTRAINT ck_transporte_custo 
        CHECK (custo >= 0),

    CONSTRAINT ck_transporte_tipo 
        CHECK (UPPER(tipo) IN (
            'RECEBIMENTO', 
            'ENTREGA'
        ))
);


-- Gera o sufixo numérico de id_lote (ex.: 'LOTE-0001'); começa em 7 para não
-- colidir com os lotes LOTE-0001..LOTE-0006 inseridos por database/dados.sql.
CREATE SEQUENCE seq_lote_id START WITH 7;

-- Excedente agrícola cadastrado por um Produtor_Rural a partir de um Produto. Antes da
-- triagem, classificacao/placa_veiculo/data_hora_coleta/etc. ficam nulos; após a
-- classificação pelo funcionário de Triagem, o lote passa a ter uma linha correspondente
-- em uma das especializações abaixo (Lote_Consumo_Humano, Lote_Consumo_Animal ou
-- Lote_Compostagem), conforme a classificacao atribuída.
CREATE TABLE Lote_de_Produto (
    id_lote                     VARCHAR(100)    NOT NULL,
    produto                     VARCHAR(50)     NOT NULL,
    data_hora_cadastro          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    produtor                    VARCHAR(11)     NOT NULL,
    custo_producao              DECIMAL(10, 2),
    data_colheita               DATE,
    validade                    DATE,
    quantidade                  DECIMAL(10, 2), -- Quantidade em kg ou unidades, dependendo do tipo do produto
    classificacao               VARCHAR(50),
    localizacao                 VARCHAR(255), -- GPS
    placa_veiculo               VARCHAR(10),
    data_hora_coleta            TIMESTAMP,
    conta_bancaria              VARCHAR(15),
    nota_fiscal                 VARCHAR(50),
    responsavel_classificacao   VARCHAR(11), 

    CONSTRAINT pk_lote_de_produto 
        PRIMARY KEY (id_lote),

    CONSTRAINT unq_lote_de_produto_secundaria
        UNIQUE (produto, produtor, data_hora_cadastro),

    CONSTRAINT fk_lote_produto_produto 
        FOREIGN KEY (produto) REFERENCES Produto(nome)
        ON DELETE RESTRICT, -- A definição do produto não pode ser apagada se existirem lotes registrados no sistema

    CONSTRAINT fk_lote_produto_produtor 
        FOREIGN KEY (produtor) REFERENCES Produtor_Rural(cpf)
        ON DELETE RESTRICT, -- Impede a remoção do produtor se houver histórico de excedentes fornecidos por ele

    CONSTRAINT fk_lote_produto_conta 
        FOREIGN KEY (conta_bancaria) REFERENCES Conta_Bancaria(id_conta)
        ON DELETE SET NULL, 

    CONSTRAINT fk_lote_produto_transporte 
        FOREIGN KEY (placa_veiculo, data_hora_coleta) REFERENCES Transporte(placa_veiculo, data_hora_coleta)
        ON DELETE SET NULL, 

    CONSTRAINT fk_lote_produto_funcionario 
        FOREIGN KEY (responsavel_classificacao) REFERENCES Funcionario(cpf)
        ON DELETE SET NULL,

    CONSTRAINT ck_lote_produto_quantidade 
        CHECK (quantidade > 0),
    
    CONSTRAINT ck_lote_produto_custo 
        CHECK (custo_producao >= 0),

    CONSTRAINT ck_lote_produto_classificacao
        CHECK (UPPER(classificacao) IN (
            'CONSUMO HUMANO',
            'CONSUMO ANIMAL',
            'COMPOSTAGEM'
        )),

    CONSTRAINT ck_lote_produto_data
        CHECK (data_hora_coleta >= data_hora_cadastro)
);

-- Índices de apoio às consultas de database/consultas.sql: filtro por
-- classificação (consulta 3, divisão relacional), filtro por mês de
-- cadastro (consulta 1, GROUP BY) e junção/correlação por produtor
-- (consultas 4 e 6).
CREATE INDEX idx_lote_produto_classificacao ON Lote_de_Produto (classificacao);
CREATE INDEX idx_lote_produto_data_cadastro ON Lote_de_Produto (data_hora_cadastro);
CREATE INDEX idx_lote_produto_produtor ON Lote_de_Produto (produtor);


-- Pedido de aquisição de um ou mais Lote_de_Produto feito por um Beneficiario.
-- Entidade fraca de Beneficiario: a chave (data_hora, beneficiario) identifica o
-- beneficiário que fez o pedido e o instante em que foi feito.
CREATE TABLE Solicitacao_de_Aquisicao (
    data_hora                   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    beneficiario                VARCHAR(14)     NOT NULL,
    declaracao_finalidade       VARCHAR(255),
    validacao                   VARCHAR(50),
    custo_parcial               DECIMAL(10, 2),
    responsavel_regularizacao   VARCHAR(11),

    CONSTRAINT pk_solicitacao_aquisicao 
        PRIMARY KEY (data_hora, beneficiario),

    CONSTRAINT fk_solicitacao_beneficiario 
        FOREIGN KEY (beneficiario) REFERENCES Beneficiario(cnpj)
        ON DELETE CASCADE, -- Por ser uma entidade fraca de beneficiário, deve ser apagada caso o beneficiário seja removido

    CONSTRAINT fk_solicitacao_funcionario 
        FOREIGN KEY (responsavel_regularizacao) REFERENCES Funcionario(cpf) 
        ON DELETE SET NULL,

    CONSTRAINT ck_solicitacao_custo 
        CHECK (custo_parcial >= 0),

    CONSTRAINT ck_solicitacao_validacao
        CHECK (UPPER(validacao) IN (
            'APROVADA',
            'REPROVADA',
            'PENDENTE',
            'EM ANALISE'
        ))
);


-- Junção de todos os lotes requisitados (Requisita) em uma mesma Solicitacao_de_Aquisicao
-- aprovada, formando o pacote físico que será transportado até o beneficiário.
-- Entidade fraca de Solicitacao_de_Aquisicao (herda sua chave composta).
CREATE TABLE Lote_de_Entrega (
    data_hora_aquisicao     TIMESTAMP       NOT NULL,
    beneficiario            VARCHAR(14)     NOT NULL,
    custo_total             DECIMAL(10, 2),
    tamanho_total           DECIMAL(10, 2),
    status_entrega          VARCHAR(50),
    conta_pagamento         VARCHAR(15),
    nota_fiscal             VARCHAR(50),
    placa_veiculo           VARCHAR(10),
    data_hora_coleta        TIMESTAMP,

    CONSTRAINT pk_lote_de_entrega 
        PRIMARY KEY (data_hora_aquisicao, beneficiario),

    CONSTRAINT unq_lote_entrega
        UNIQUE (placa_veiculo, data_hora_coleta),

    CONSTRAINT fk_lote_entrega_solicitacao 
        FOREIGN KEY (data_hora_aquisicao, beneficiario) REFERENCES Solicitacao_de_Aquisicao(data_hora, beneficiario) 
        ON DELETE CASCADE, -- Por ser uma entidade fraca de solicitação, deve ser apagada caso a solicitação seja removida

    CONSTRAINT fk_lote_entrega_conta 
        FOREIGN KEY (conta_pagamento) REFERENCES Conta_Bancaria(id_conta) 
        ON DELETE SET NULL,

    CONSTRAINT fk_lote_entrega_transporte 
        FOREIGN KEY (placa_veiculo, data_hora_coleta) REFERENCES Transporte(placa_veiculo, data_hora_coleta) 
        ON DELETE SET NULL,

    CONSTRAINT ck_lote_entrega_custo 
        CHECK (custo_total >= 0),

    CONSTRAINT ck_lote_entrega_tamanho 
        CHECK (tamanho_total > 0),

    CONSTRAINT ck_lote_entrega_status 
        CHECK (UPPER(status_entrega) IN (
            'PENDENTE', 
            'EM ROTA', 
            'ENTREGUE', 
            'CANCELADA'
        )),

    CONSTRAINT ck_lote_entrega_data 
        CHECK (data_hora_coleta >= data_hora_aquisicao)
);


-- Tabela associativa N:N entre Lote_de_Produto e Solicitacao_de_Aquisicao: registra
-- quanto (porcao_lote) de um lote específico foi requisitado em uma solicitação.
-- Uma solicitação pode requisitar porções de múltiplos lotes, desde que da mesma
-- classificação (regra garantida pela aplicação, não pelo esquema).
CREATE TABLE Requisita (
    data_hora_aquisicao     TIMESTAMP       NOT NULL,
    beneficiario            VARCHAR(14)     NOT NULL,
    lote                    VARCHAR(100)    NOT NULL,
    porcao_lote             DECIMAL(10, 2)  NOT NULL, -- Quantidade requisitada em kg ou unidades

    CONSTRAINT pk_requisita 
        PRIMARY KEY (data_hora_aquisicao, beneficiario, lote),

    CONSTRAINT fk_requisita_solicitacao 
        FOREIGN KEY (data_hora_aquisicao, beneficiario) REFERENCES Solicitacao_de_Aquisicao(data_hora, beneficiario) 
        ON DELETE CASCADE, -- Deve ser apagada caso a solicitação seja removida

    CONSTRAINT fk_requisita_lote 
        FOREIGN KEY (lote) REFERENCES Lote_de_Produto(id_lote) 
        ON DELETE RESTRICT, -- Impede a exclusão de um lote físico que já faz parte de um pedido/transação ativa ou finalizada

    CONSTRAINT ck_requisita_porcao
        CHECK (porcao_lote > 0)
);

-- 'lote' é apenas a 3ª coluna da chave composta acima, então buscas por
-- lote isolado (consultas 1, 2 e 3) não se beneficiariam do índice da PK.
CREATE INDEX idx_requisita_lote ON Requisita (lote);


-- Atributo multivalorado de Conta_Bancaria: uma conta pode ter mais de um titular.
CREATE TABLE Titular (
    id_conta                VARCHAR(15)     NOT NULL,
    nome_titular            VARCHAR(100)    NOT NULL,

    CONSTRAINT pk_titular 
        PRIMARY KEY (id_conta, nome_titular),

    CONSTRAINT fk_titular_conta 
        FOREIGN KEY (id_conta) REFERENCES Conta_Bancaria(id_conta) 
        ON DELETE CASCADE -- Por ser uma tabela de atributo multivalorado, deve ser apagada caso a conta seja removida
);


-- Agregação que registra cada doação financeira de um Filantropo para uma Conta_Bancaria
-- da empresa; a chave própria (nota_fiscal) permite múltiplas doações do mesmo par.
CREATE TABLE Doacao (
    nota_fiscal             VARCHAR(50)     NOT NULL,
    id_conta                VARCHAR(15)     NOT NULL,
    filantropo              VARCHAR(11)     NOT NULL,

    CONSTRAINT pk_doacao 
        PRIMARY KEY (nota_fiscal),

    CONSTRAINT fk_doacao_conta 
        FOREIGN KEY (id_conta) REFERENCES Conta_Bancaria(id_conta) 
        ON DELETE RESTRICT,

    CONSTRAINT fk_doacao_filantropo 
        FOREIGN KEY (filantropo) REFERENCES Filantropo(cpf)
        ON DELETE RESTRICT
);

--------------------------------------------------------------------------------------------

-- Especializações de Lote de Produto

--------------------------------------------------------------------------------------------

-- Especialização de Lote_de_Produto para lotes classificados 'CONSUMO HUMANO'.
-- cep/nro/rua referenciam o Centro_Beneficiamento_Distribuicao onde está armazenado
-- (nulo até o lote ser efetivamente recebido por um centro).
CREATE TABLE Lote_Consumo_Humano (
    lote            VARCHAR(100)    NOT NULL,
    cep             VARCHAR(8),
    nro             INT,
    rua             VARCHAR(100),

    CONSTRAINT pk_lote_consumo_humano
        PRIMARY KEY (lote),

    CONSTRAINT fk_lote_consumo_humano_lote
        FOREIGN KEY (lote) REFERENCES Lote_de_Produto(id_lote)
        ON DELETE CASCADE, -- Por ser uma tabela de especialização, deve ser apagada caso o lote de produto seja removido
                           -- O mesmo vale para as demais tabelas de especialização de lote de produto

    CONSTRAINT fk_lote_consumo_humano_centro
        FOREIGN KEY (cep, nro, rua) REFERENCES Centro_Beneficiamento_Distribuicao(cep, nro, rua)
        ON DELETE SET NULL
);

-- Especialização de Lote_de_Produto para lotes classificados 'CONSUMO ANIMAL'.
-- cep/nro/rua referenciam o Armazem onde está armazenado (nulo até o recebimento).
CREATE TABLE Lote_Consumo_Animal (
    lote            VARCHAR(100)    NOT NULL,
    cep             VARCHAR(8),
    nro             INT,
    rua             VARCHAR(100),

    CONSTRAINT pk_lote_consumo_animal
        PRIMARY KEY (lote),

    CONSTRAINT fk_lote_consumo_animal_lote
        FOREIGN KEY (lote) REFERENCES Lote_de_Produto(id_lote)
        ON DELETE CASCADE,

    CONSTRAINT fk_lote_consumo_animal_armazem
        FOREIGN KEY (cep, nro, rua) REFERENCES Armazem(cep, nro, rua)
        ON DELETE SET NULL
);

-- Especialização de Lote_de_Produto para lotes classificados 'COMPOSTAGEM'.
-- cep/nro/rua referenciam o Centro_Compostagem onde está armazenado (nulo até o recebimento).
CREATE TABLE Lote_Compostagem (
    lote            VARCHAR(100)    NOT NULL,
    cep             VARCHAR(8),
    nro             INT,
    rua             VARCHAR(100),

    CONSTRAINT pk_lote_compostagem
        PRIMARY KEY (lote),

    CONSTRAINT fk_lote_compostagem_lote
        FOREIGN KEY (lote) REFERENCES Lote_de_Produto(id_lote)
        ON DELETE CASCADE,

    CONSTRAINT fk_lote_compostagem_centro
        FOREIGN KEY (cep, nro, rua) REFERENCES Centro_Compostagem(cep, nro, rua)
        ON DELETE SET NULL
);
