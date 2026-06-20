# SOS Abobrinha

Sistema de redistribuição de excedentes agrícolas (frontend + API Flask + PostgreSQL).

## Pré-requisitos

- Python 3.10+
- PostgreSQL instalado e rodando (local ou Docker)

## 1. Banco de dados

### Opção A: PostgreSQL local

Crie um usuário e um banco dedicados ao projeto no seu PostgreSQL local (porta padrão 5432):

```bash
sudo -u postgres psql -c "CREATE USER sos_abobrinha WITH PASSWORD 'senha_segura';"
sudo -u postgres psql -c "CREATE DATABASE banco_trabalho OWNER sos_abobrinha;"
```

```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=banco_trabalho
export DB_USER=sos_abobrinha
export DB_PASSWORD=senha_segura
```

### Opção B: Docker

Prefere usar Docker em vez de um Postgres local? Suba um container já com essas credenciais:

```bash
docker run --name sos-abobrinha-db \
  -e POSTGRES_USER=sos_abobrinha \
  -e POSTGRES_PASSWORD=senha_segura \
  -e POSTGRES_DB=banco_trabalho \
  -p 5433:5432 \
  -d postgres:16
```

```bash
export DB_HOST=localhost
export DB_PORT=5433
export DB_NAME=banco_trabalho
export DB_USER=sos_abobrinha
export DB_PASSWORD=senha_segura
```

Usamos a porta **5433** no host para o container, em vez da padrão 5432, porque é comum já existir um PostgreSQL local instalado e escutando em 5432 — mapear o container nessa mesma porta causaria erro de "porta já em uso". Ajuste host/porta/usuário/senha de qualquer uma das opções acima conforme o seu ambiente.

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
