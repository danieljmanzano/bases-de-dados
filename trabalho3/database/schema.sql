-- Arquivo com o esquema do banco de dados


-- Tabelas que não possuem chaves estrangeiras
----------------------------------------------
CREATE TABLE Produto (
    nome   VARCHAR(50)    NOT NULL,
    tipo   VARCHAR(50)    NOT NULL,
    CONSTRAINT pk_produto 
        PRIMARY KEY (nome)
);

CREATE TABLE Produtor_Rural (
    cpf_cnpj                VARCHAR(14)     NOT NULL, -- TODO: padronizar para cpf ou cnpj
    cep                     VARCHAR(8)      NOT NULL,
    nro                     INT             NOT NULL,
    rua                     VARCHAR(100)    NOT NULL,
    complemento             VARCHAR(100),
    contato                 VARCHAR(50)     NOT NULL,
    nome                    VARCHAR(100)    NOT NULL,
    bool_compostagem        BOOLEAN DEFAULT FALSE,
    bool_consumo_animal     BOOLEAN DEFAULT FALSE,
    bool_consumo_humano     BOOLEAN DEFAULT FALSE,

    CONSTRAINT pk_produtor_rural 
        PRIMARY KEY (cpf_cnpj),

    CONSTRAINT ck_produtor_rural_cpf_cnpj_len 
        CHECK (CHAR_LENGTH(cpf_cnpj) IN (11, 14)), -- TODO: ajustar depois de padronizar cpf ou cnpj
    
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
    contato             VARCHAR(50) NOT NULL, -- TODO: decidir se é telefone ou email
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
    cpf_cnpj                VARCHAR(14)     NOT NULL, -- TODO: padronizar para cpf ou cnpj
    cep                     VARCHAR(8)      NOT NULL,
    nro                     INT             NOT NULL,
    rua                     VARCHAR(100)    NOT NULL,
    complemento             VARCHAR(100),
    contato                 VARCHAR(50)     NOT NULL,
    nome                    VARCHAR(100)    NOT NULL,
    classificacao           VARCHAR(50)     NOT NULL,
    validacao_elegibilidade VARCHAR(255)    NOT NULL, 

    CONSTRAINT pk_beneficiario 
        PRIMARY KEY (cpf_cnpj),
   
    CONSTRAINT ck_beneficiario_cnpj_len 
        CHECK (CHAR_LENGTH(cpf_cnpj) IN (11, 14)),
    
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
    cpf_cnpj    VARCHAR(14)     NOT NULL, -- TODO: padronizar para cpf ou cnpj
    contato     VARCHAR(50)     NOT NULL,
    nome        VARCHAR(100)    NOT NULL,

    CONSTRAINT pk_filantropo 
        PRIMARY KEY (cpf_cnpj),

    CONSTRAINT ck_filantropo_cnpj_len 
        CHECK (CHAR_LENGTH(cpf_cnpj) IN (11, 14))
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

----------------------------------------------

-- Demais tabelas
----------------------------------------------
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
        FOREIGN KEY (responsavel_distribuicao) REFERENCES Funcionario(cpf),  

    CONSTRAINT fk_transporte_conta 
        FOREIGN KEY (conta_pagamento) REFERENCES Conta_Bancaria(id_conta),

    CONSTRAINT ck_transporte_custo 
        CHECK (custo >= 0),

    CONSTRAINT ck_transporte_tipo 
        CHECK (UPPER(tipo) IN ('RECEBIMENTO', 'ENTREGA'))
);


CREATE TABLE Lote_de_Produto (
    id_lote                     VARCHAR(100)    NOT NULL,
    produto                     VARCHAR(50)     NOT NULL,
    data_hora_cadastro          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    produtor                    VARCHAR(14)     NOT NULL, -- TODO: padronizar para cpf ou cnpj
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
        FOREIGN KEY (produto) REFERENCES Produto(nome),

    CONSTRAINT fk_lote_produto_produtor 
        FOREIGN KEY (produtor) REFERENCES Produtor_Rural(cpf_cnpj),

    CONSTRAINT fk_lote_produto_conta 
        FOREIGN KEY (conta_bancaria) REFERENCES Conta_Bancaria(id_conta),

    CONSTRAINT fk_lote_produto_transporte 
        FOREIGN KEY (placa_veiculo, data_hora_coleta) REFERENCES Transporte(placa_veiculo, data_hora_coleta),

    CONSTRAINT fk_lote_produto_funcionario 
        FOREIGN KEY (responsavel_classificacao) REFERENCES Funcionario(cpf),

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

----------------------------------------------
