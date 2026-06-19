# SOS Abobrinha

Sistema de redistribuição de excedentes agrícolas (frontend + API Flask + PostgreSQL).

## Pré-requisitos

- Python 3.10+
- PostgreSQL instalado e rodando (local ou Docker)

## 1. Banco de dados

Crie um usuário e um banco dedicados ao projeto no seu PostgreSQL local:

```bash
sudo -u postgres psql -c "CREATE USER sos_abobrinha WITH PASSWORD 'senha_segura';"
sudo -u postgres psql -c "CREATE DATABASE banco_trabalho OWNER sos_abobrinha;"
```

Depois, exporte as variáveis de ambiente apontando para o seu Postgres (ajuste host/porta/usuário/senha conforme o seu ambiente):

```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=banco_trabalho
export DB_USER=sos_abobrinha
export DB_PASSWORD=senha_segura
```

Prefere usar Docker em vez de um Postgres local? Suba um container já com essas credenciais:

```bash
docker run --name sos-abobrinha-db \
  -e POSTGRES_USER=sos_abobrinha \
  -e POSTGRES_PASSWORD=senha_segura \
  -e POSTGRES_DB=banco_trabalho \
  -p 5432:5432 \
  -d postgres:16
```

## 2. Ambiente Python

```bash
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## 3. Criar tabelas e popular dados de teste

```bash
cd backend
python setup.db.py
```

## 4. Rodar a aplicação

```bash
python app.py
```

Acesse em [http://localhost:5000](http://localhost:5000).

## Estrutura

- `frontend/` — interface web (HTML/CSS/JS), servida pelo próprio Flask
- `backend/` — API Flask (`app.py`), conexão com o banco (`db.py`, `config.py`) e setup do schema (`setup.db.py`)
- `database/` — `esquema.sql` (tabelas), `dados.sql` (dados de teste), `consultas.sql`
