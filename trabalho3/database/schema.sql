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
   
    CONSTRAINT chk_beneficiario_cnpj_len 
        CHECK (CHAR_LENGTH(cpf_cnpj) IN (11, 14)),
    
    CONSTRAINT chk_beneficiario_cep_len 
        CHECK (CHAR_LENGTH(cep) = 8),
    
    CONSTRAINT chk_beneficiario_nro 
        CHECK (nro > 0),
    
    CONSTRAINT chk_beneficiario_classificacao 
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

    CONSTRAINT chk_filantropo_cnpj_len 
        CHECK (CHAR_LENGTH(cpf_cnpj) IN (11, 14))
);

CREATE TABLE Conta_Bancaria (
    id_conta        INT             NOT NULL,
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

