-- Arquivo com as inserções

INSERT INTO Produto (nome, tipo) VALUES
    ('Alface',  'Hortaliça'),
    ('Batata',  'Tubérculo'),
    ('Cenoura', 'Hortaliça'),
    ('Milho',   'Cereal'),
    ('Soja',    'Grão'),
    ('Tomate',  'Hortaliça');

INSERT INTO Produtor_Rural (cpf_cnpj, cep, nro, rua, contato, nome) VALUES
    ('12345678900',     '13560000', 100, 'Rua das Flores',    '(16) 99999-0001', 'João da Silva Agropecuária'),
    ('98765432000110',  '13561000', 200, 'Estrada do Campo',  '(16) 99999-0002', 'Maria Oliveira Farming'),
    ('11122233344',     '13562000', 300, 'Rodovia Rural',     '(16) 99999-0003', 'Carlos Souza Produções');
