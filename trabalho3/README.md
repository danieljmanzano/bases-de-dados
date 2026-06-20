# SOS Abobrinha

**Sistema de redistribuição de excedentes agrícolas** — Trabalho 3 da disciplina de Bases de Dados.

O SOS Abobrinha conecta **produtores rurais** com excedentes agrícolas a **beneficiários** (instituições sociais, pequenos agricultores e pecuaristas), viabilizando a redistribuição de alimentos que seriam desperdiçados. O sistema gerencia o cadastro de lotes de produtos, sua classificação (consumo humano, consumo animal ou compostagem), o transporte logístico e as solicitações de aquisição pelos beneficiários.

---

## Integrantes

| Nome | NUSP |
|------|-----------|
| Beatriz Alves dos Santos | 15588630 |
| Daniel Jorge Manzano | 15446861 |
| Jhonatan Barboza da Silva | 15645049 |
| Kevin Ryoji Nakashima | 15675936 |
| Newton Eduardo Pena Villegas | 15481732 |

## Arquitetura

```
trabalho3/
├── backend/                # API Flask (Python)
│   ├── app.py              # Rotas da API e servidor Flask
│   ├── config.py           # Configuração de conexão ao banco (via variáveis de ambiente)
│   ├── db.py               # Context managers para conexão e cursor PostgreSQL
│   └── setup.db.py         # Script de inicialização: cria tabelas e popula dados
│
├── frontend/               # Interface web (HTML/CSS/JS puro), servida pelo Flask
│   ├── index.html           # Ponto de entrada — SPA com navegação dinâmica
│   ├── css/styles.css       # Estilos da aplicação
│   └── js/
│       ├── app.js           # Núcleo de navegação e estado global
│       └── views/
│           ├── menu.js      # Tela inicial (menu)
│           ├── consulta.js  # Consulta de lotes disponíveis com filtro por classificação
│           └── cadastro/    # Fluxo de cadastro de lote (wizard em 3 passos)
│               ├── passo1.js   # Produtor e produto
│               ├── passo2.js   # Detalhes do lote (quantidade, datas, localização)
│               ├── passo3.js   # Confirmação e envio
│               └── sucesso.js  # Tela de sucesso
│
├── database/               # Scripts SQL
│   ├── esquema.sql          # DDL — criação de tabelas, constraints e índices
│   ├── dados.sql            # DML — dados iniciais de teste (mín. 2 tuplas por tabela)
│   └── consultas.sql        # Consultas exigidas (simples + 6 de média/alta complexidade)
│
├── docs/                   # Documentação
│   └── Relatorio.pdf        # Relatório do grupo
│
├── requirements.txt        # Dependências Python (Flask, psycopg2, SQLAlchemy)
└── .gitignore
```

---

## Funcionalidades

### Frontend (SPA)

| Tela | Descrição |
|------|-----------|
| **Menu** | Ponto de entrada com acesso às duas funcionalidades principais |
| **Cadastrar lote** | Wizard em 3 passos — identifica o produtor (por CPF), seleciona o produto, informa detalhes do lote e confirma o cadastro |
| **Consultar lotes** | Lista lotes disponíveis com filtro por classificação (consumo humano, consumo animal, compostagem) |

### API (Flask)

| Método | Rota | Descrição |
|--------|------|-----------|
| `GET` | `/` | Serve o frontend (`index.html`) |
| `GET` | `/api/produtos` | Lista todos os produtos cadastrados |
| `GET` | `/api/produtores?cpf=<cpf>` | Busca um produtor rural por CPF |
| `GET` | `/api/lotes?classificacao=<class>` | Lista lotes filtrados por classificação |
| `POST` | `/api/lotes` | Cadastra um novo lote de produto |

### Consultas SQL (complexidade média/alta)

O arquivo `database/consultas.sql` contém 6 consultas diversificadas, conforme exigido pelo enunciado:

1. **GROUP BY + JOIN** — Quantidade total adquirida e cadastrada por produto em um determinado mês
2. **JOIN de múltiplas tabelas** — Beneficiários que adquiriram um lote específico (somente solicitações aprovadas)
3. **Divisão relacional** _(obrigatória)_ — Beneficiários que requisitaram todos os lotes de uma determinada classificação
4. **Subconsulta correlacionada** — Lotes cujo custo de produção supera a média do respectivo produtor
5. **Subconsulta não correlacionada** — Beneficiários que nunca registraram solicitações
6. **Junção externa (LEFT JOIN)** — Todos os produtores com a quantidade total de lotes cadastrados (incluindo produtores sem lotes)

---

## Pré-requisitos

- **Python 3.10+**
- **PostgreSQL 14+** (instalação local ou via Docker)

---

## Passo a passo para execução

### 1. Banco de dados

Escolha **uma** das opções abaixo:

#### Opção A — PostgreSQL local

Crie o usuário e o banco dedicados ao projeto:

```bash
sudo -u postgres psql -c "CREATE USER sos_abobrinha WITH PASSWORD 'senha_segura';"
sudo -u postgres psql -c "CREATE DATABASE banco_trabalho OWNER sos_abobrinha;"
```

#### Opção B — Docker

Suba um container PostgreSQL já configurado:

```bash
docker run --name sos-abobrinha-db \
  -e POSTGRES_USER=sos_abobrinha \
  -e POSTGRES_PASSWORD=senha_segura \
  -e POSTGRES_DB=banco_trabalho \
  -p 5432:5432 \
  -d postgres:16
```

### 2. Variáveis de ambiente

Exporte as variáveis de conexão (**ajuste conforme o seu ambiente** — host, porta, usuário e senha):

```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=banco_trabalho
export DB_USER=sos_abobrinha
export DB_PASSWORD=senha_segura
```

> **Nota:** se as variáveis não forem exportadas, o backend usará os valores padrão definidos em `backend/config.py` (`host=localhost`, `port=5433`, `user=postgres`, `password=senha_segura`, `dbname=banco_trabalho`). Verifique se os padrões correspondem ao seu ambiente ou exporte os valores corretos.

### 3. Ambiente Python

Na raiz do projeto (`trabalho3/`):

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 4. Criar tabelas e popular dados de teste

```bash
cd backend
python setup.db.py
```

Esse script executa `database/esquema.sql` (DDL) e `database/dados.sql` (dados iniciais) no banco configurado.

### 5. Rodar a aplicação

Ainda dentro do diretório `backend/`:

```bash
python app.py
```

Acesse o sistema em **[http://localhost:5000](http://localhost:5000)**.

> O Flask serve automaticamente os arquivos do frontend (HTML, CSS e JS) como conteúdo estático.

---

## Stack tecnológica

| Camada | Tecnologia |
|--------|------------|
| **Backend** | Python 3 · Flask 3.0.3 |
| **Banco de dados** | PostgreSQL 14+ · psycopg2 |
| **Frontend** | HTML5 · CSS3 (vanilla) · JavaScript (vanilla) |

---

## Modelo de dados (resumo)

O esquema completo está em `database/esquema.sql`. As principais entidades são:

- **Produto** — catálogo de produtos agrícolas (Hortaliça, Tubérculo, Leguminosa, Fruta, Cereal, Grão, Adubo, Ração)
- **Produtor_Rural** — produtores cadastrados (pessoa física, identificados por CPF)
- **Lote_de_Produto** — lotes de excedentes agrícolas, classificados em _Consumo Humano_, _Consumo Animal_ ou _Compostagem_
- **Beneficiário** — organizações que podem solicitar lotes (Instituição Social, Pequeno Agricultor, Pequeno Pecuarista)
- **Solicitação de Aquisição / Requisita** — pedidos de aquisição de lotes por beneficiários
- **Transporte / Transportadora** — logística de recebimento e entrega
- **Centro Logístico** (e especializações: Centro de Beneficiamento, Armazém, Centro de Compostagem)
- **Funcionário** — responsáveis por triagem, distribuição, regularização, finanças e administração
- **Filantropo / Doação / Conta Bancária** — gestão financeira e doações
