-- Arquivo com o esquema do banco de dados


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
DROP SEQUENCE IF EXISTS seq_lote_id; -- NÃO SEI SE PODE FAZER ISSO (VER LINHA 248)
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
CREATE TABLE Produto (
    nome   VARCHAR(50)    NOT NULL,
    tipo   VARCHAR(50)    NOT NULL,
    CONSTRAINT pk_produto 
        PRIMARY KEY (nome)
);


CREATE TABLE Produtor_Rural (
    cpf                     VARCHAR(11)     NOT NULL, -- somente CPF, produtor rural é pessoa física
    cep                     VARCHAR(8)      NOT NULL,
    nro                     INT             NOT NULL,
    rua                     VARCHAR(100)    NOT NULL,
    complemento             VARCHAR(100),
    contato                 VARCHAR(50)     NOT NULL, -- telefone ou email, dependendo do tipo de contato fornecido
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
        CHECK (nro > 0) -- nro de endereço não pode ser negativo
);


CREATE TABLE Transportadora (
    cnpj                VARCHAR(14) NOT NULL,
    cep                 VARCHAR(8) NOT NULL,
    nro                 INT NOT NULL,
    rua                 VARCHAR(100) NOT NULL,
    complemento         VARCHAR(100),
    contato             VARCHAR(50) NOT NULL,
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
        CHECK (nro > 0)
);


CREATE TABLE Beneficiario (
    cnpj                    VARCHAR(14)     NOT NULL, -- somente CNPJ, beneficiário é sempre uma organização (instituição, sítio, etc.)
    cep                     VARCHAR(8)      NOT NULL,
    nro                     INT             NOT NULL,
    rua                     VARCHAR(100)    NOT NULL,
    complemento             VARCHAR(100),
    contato                 VARCHAR(50)     NOT NULL,
    nome                    VARCHAR(100)    NOT NULL,
    classificacao           VARCHAR(50)     NOT NULL,
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
        ))
);


CREATE TABLE Filantropo (
    cpf         VARCHAR(11)     NOT NULL, -- somente CPF, filantropo é pessoa física
    contato     VARCHAR(50)     NOT NULL,
    nome        VARCHAR(100)    NOT NULL,

    CONSTRAINT pk_filantropo
        PRIMARY KEY (cpf),

    CONSTRAINT ck_filantropo_cpf_len
        CHECK (CHAR_LENGTH(cpf) = 11)
);


CREATE TABLE Conta_Bancaria (
    id_conta        VARCHAR(15)     NOT NULL,
    codigo_banco    VARCHAR(10)     NOT NULL,
    nro_conta       VARCHAR(20)     NOT NULL,
    nro_agencia     VARCHAR(10)     NOT NULL,
    tipo            VARCHAR(50)     NOT NULL,

    CONSTRAINT pk_conta_bancaria 
        PRIMARY KEY (id_conta),

    CONSTRAINT unq_conta_bancaria 
        UNIQUE (codigo_banco, nro_conta, nro_agencia)
);


CREATE TABLE Centro_Logistico (
    cep             VARCHAR(8)      NOT NULL,
    nro             INT             NOT NULL,
    rua             VARCHAR(100)    NOT NULL,
    tipo_produto    VARCHAR(50)     NOT NULL,

    CONSTRAINT pk_centro_logistico 
        PRIMARY KEY (cep, nro, rua),

    CONSTRAINT chk_centro_logistico_cep_len 
        CHECK (CHAR_LENGTH(cep) = 8),
    
    CONSTRAINT chk_centro_logistico_nro 
        CHECK (nro > 0)
);

--------------------------------------------------------------------------------------------


-- Tabelas com FKs
--------------------------------------------------------------------------------------------
CREATE TABLE Funcionario (
    cpf                     VARCHAR(11)     NOT NULL, 
    funcao                  VARCHAR(50)     NOT NULL, 
    nome                    VARCHAR(100)    NOT NULL, 
    id_conta                VARCHAR(15),                      

    CONSTRAINT pk_funcionario 
        PRIMARY KEY (cpf),

    CONSTRAINT fk_funcionario_conta -- para funcionários de finanças, esse campo referencia a conta
        FOREIGN KEY (id_conta) REFERENCES Conta_Bancaria(id_conta)
        ON DELETE SET NULL, -- o funcionário é mantido sem conta

    CONSTRAINT chk_funcionario_cpf_len 
        CHECK (CHAR_LENGTH(cpf) = 11),

    CONSTRAINT chk_funcionario_funcao -- definição da especialização do funcionário
        CHECK (UPPER(funcao) IN (
            'TRIAGEM', 
            'DISTRIBUIÇÃO', 
            'REGULARIZAÇÃO', 
            'FINANÇAS', 
            'ADMINISTRAÇÃO'
        )) 
);


CREATE TABLE Transporte (
    placa_veiculo               VARCHAR(10)     NOT NULL,
    data_hora_coleta            TIMESTAMP       NOT NULL,
    transportadora              VARCHAR(14)     NOT NULL,
    data_entrega                TIMESTAMP,               
    custo                       DECIMAL(10, 2)  NOT NULL, 
    tipo                        VARCHAR(20),
    origem                      VARCHAR(255)    NOT NULL,
    destino                     VARCHAR(255)    NOT NULL,
    responsavel_distribuicao    VARCHAR(11), 
    conta_pagamento             VARCHAR(15),              
    nota_fiscal_pagamento       VARCHAR(50),              

    CONSTRAINT pk_transporte 
        PRIMARY KEY (placa_veiculo, data_hora_coleta), 

    CONSTRAINT fk_transporte_transportadora 
        FOREIGN KEY (transportadora) REFERENCES Transportadora(cnpj)
        ON DELETE RESTRICT, -- mantém o histórico de transportes mesmo que a transportadora seja removida

    CONSTRAINT fk_transporte_funcionario 
        FOREIGN KEY (responsavel_distribuicao) REFERENCES Funcionario(cpf)
        ON DELETE SET NULL,

    CONSTRAINT fk_transporte_conta 
        FOREIGN KEY (conta_pagamento) REFERENCES Conta_Bancaria(id_conta)
        ON DELETE SET NULL,

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

CREATE TABLE Lote_de_Produto (
    id_lote                     VARCHAR(100)    NOT NULL,
    produto                     VARCHAR(50)     NOT NULL,
    data_hora_cadastro          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    produtor                    VARCHAR(11)     NOT NULL,
    custo_producao              DECIMAL(10, 2),
    data_colheita               DATE,
    validade                    DATE,
    quantidade                  DECIMAL(10, 2)  NOT NULL, -- quantidade em kg ou unidades, dependendo do tipo do produto
    classificacao               VARCHAR(50),
    localizacao                 VARCHAR(255), -- isso seria como um gps sobre o lote
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
        ON DELETE RESTRICT, -- mantém o histórico de lotes mesmo que o produto seja removido

    CONSTRAINT fk_lote_produto_produtor 
        FOREIGN KEY (produtor) REFERENCES Produtor_Rural(cpf)
        ON DELETE RESTRICT, -- mantém o histórico de lotes mesmo que o produtor seja removido

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
        ))
);


CREATE TABLE Solicitacao_de_Aquisicao (
    data_hora                   TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    beneficiario                VARCHAR(14)     NOT NULL,
    declaracao_finalidade       VARCHAR(255)    NOT NULL,
    validacao                   VARCHAR(50),
    custo_parcial               DECIMAL(10, 2),
    responsavel_regularizacao   VARCHAR(11),

    CONSTRAINT pk_solicitacao_aquisicao 
        PRIMARY KEY (data_hora, beneficiario),

    CONSTRAINT fk_solicitacao_beneficiario 
        FOREIGN KEY (beneficiario) REFERENCES Beneficiario(cnpj)
        ON DELETE CASCADE, -- por ser uma entidade fraca de beneficiário, deve ser apagada caso o beneficiário seja removido

    CONSTRAINT fk_solicitacao_funcionario 
        FOREIGN KEY (responsavel_regularizacao) REFERENCES Funcionario(cpf) 
        ON DELETE SET NULL,

    CONSTRAINT ck_solicitacao_custo 
        CHECK (custo_parcial >= 0)
);


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

    CONSTRAINT fk_lote_entrega_solicitacao 
        FOREIGN KEY (data_hora_aquisicao, beneficiario) REFERENCES Solicitacao_de_Aquisicao(data_hora, beneficiario) 
        ON DELETE CASCADE, -- por ser uma entidade fraca de solicitação, deve ser apagada caso a solicitação seja removida

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
        ))
);


CREATE TABLE Requisita (
    data_hora_aquisicao     TIMESTAMP       NOT NULL,
    beneficiario            VARCHAR(14)     NOT NULL,
    lote                    VARCHAR(100)    NOT NULL,
    porcao_lote             DECIMAL(10, 2)  NOT NULL, -- quantidade requisitada em kg ou unidades

    CONSTRAINT pk_requisita 
        PRIMARY KEY (data_hora_aquisicao, beneficiario, lote),

    CONSTRAINT fk_requisita_solicitacao 
        FOREIGN KEY (data_hora_aquisicao, beneficiario) REFERENCES Solicitacao_de_Aquisicao(data_hora, beneficiario) 
        ON DELETE CASCADE, -- deve ser apagada caso a solicitação seja removida

    CONSTRAINT fk_requisita_lote 
        FOREIGN KEY (lote) REFERENCES Lote_de_Produto(id_lote) 
        ON DELETE RESTRICT,

    CONSTRAINT ck_requisita_porcao 
        CHECK (porcao_lote > 0)
);


CREATE TABLE Titular (
    id_conta                VARCHAR(15)     NOT NULL,
    nome_titular            VARCHAR(100)    NOT NULL,

    CONSTRAINT pk_titular 
        PRIMARY KEY (id_conta, nome_titular),

    CONSTRAINT fk_titular_conta 
        FOREIGN KEY (id_conta) REFERENCES Conta_Bancaria(id_conta) 
        ON DELETE CASCADE -- por ser uma tabela de atributo multivalorado, deve ser apagada caso a conta seja removida
);


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


-- Especializações de Centro Logístico
--------------------------------------------------------------------------------------------
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

    CONSTRAINT fk_centro_beneficiamento_logistico
        FOREIGN KEY (cep, nro, rua) REFERENCES Centro_Logistico(cep, nro, rua)
        ON DELETE CASCADE -- por ser uma tabela de especialização, deve ser apagada caso o centro logístico seja removido
                          -- o mesmo vale para as demais tabelas de especialização de centro logístico
);

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

    CONSTRAINT fk_armazem_logistico
        FOREIGN KEY (cep, nro, rua) REFERENCES Centro_Logistico(cep, nro, rua)
        ON DELETE CASCADE
);

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

    CONSTRAINT fk_centro_compostagem_logistico
        FOREIGN KEY (cep, nro, rua) REFERENCES Centro_Logistico(cep, nro, rua)
        ON DELETE CASCADE
);
--------------------------------------------------------------------------------------------


-- Especializações de Lote de Produto
--------------------------------------------------------------------------------------------
CREATE TABLE Lote_Consumo_Humano (
    lote            VARCHAR(100)    NOT NULL,
    cep             VARCHAR(8),
    nro             INT,
    rua             VARCHAR(100),

    CONSTRAINT pk_lote_consumo_humano
        PRIMARY KEY (lote),

    CONSTRAINT fk_lote_consumo_humano_lote
        FOREIGN KEY (lote) REFERENCES Lote_de_Produto(id_lote)
        ON DELETE CASCADE, -- por ser uma tabela de especialização, deve ser apagada caso o lote de produto seja removido
                           -- o mesmo vale para as demais tabelas de especialização de lote de produto

    CONSTRAINT fk_lote_consumo_humano_centro
        FOREIGN KEY (cep, nro, rua) REFERENCES Centro_Beneficiamento_Distribuicao(cep, nro, rua)
        ON DELETE SET NULL
);

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
--------------------------------------------------------------------------------------------