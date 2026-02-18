# Copilot Instructions

## Repository Overview

This is a Data Engineering Zoomcamp (DTC) learning repository. NYC yellow and green taxi trip data flows through the following stages:

**Ingest → PostgreSQL/GCS (pipeline/) → Kestra orchestration → dbt transforms → star-schema marts**

Each top-level module is a self-contained mini-project:
- `pipeline/` – Module 01: Python ingestion of NYC taxi CSV data into PostgreSQL
- `terraform/` – GCP infrastructure (GCS bucket, BigQuery) via Terraform
- `kestra/` – Workflow orchestration; flows defined as numbered YAML files in `kestra/flows/`
- `dbt/taxi_rides_ny/` – Data transformation following staging → intermediate → marts layers
- `homework/` – Module homework exercises

## Python Projects (pipeline/, kestra/, dbt/)

All Python modules use **`uv`** for dependency management. Never use `pip install` directly.

```zsh
uv sync               # install dependencies
uv run <script>       # run a script
uv add <package>      # add a dependency
uv add --dev <package> # add a dev dependency
```

Each module has its own `pyproject.toml` and `.python-version`. Run commands from within the module directory.

## Pipeline (pipeline/)

Run the ingestion script:
```zsh
uv run python ingest_data.py \
  --pg-user=root --pg-pass=root \
  --pg-host=localhost --pg-port=5432 \
  --pg-db=ny_taxi --target-table=yellow_taxi_trips \
  --year=2021 --month=1
```

Start local services (PostgreSQL + pgAdmin):
```zsh
docker compose up -d
# pgAdmin at http://localhost:8085 (admin@admin.com / root)
# PostgreSQL at localhost:5432 (root/root, db: ny_taxi)
```

Build the ingestion Docker image:
```zsh
docker build -t taxi_ingest:v001 .
```

## Kestra (kestra/)

Start the full Kestra stack (includes its own PostgreSQL backend):
```zsh
docker compose up -d
# Kestra UI at http://localhost:8080 (admin@kestra.io / Admin1234)
```

Flows are numbered sequentially in `kestra/flows/` — higher numbers build on earlier ones. The `kestra-wd/` directory is Kestra's local working directory (mounted via Docker).

## Terraform (terraform/)

```shell
gcloud auth application-default login
terraform init
terraform plan -var="project=<your-gcp-project-id>"
terraform apply -var="project=<your-gcp-project-id>"
terraform destroy   # always destroy after use to avoid costs
```

GCP service account key is at `terraform/keys/` (gitignored). Project ID: `tough-processor-312510`.

## dbt (dbt/taxi_rides_ny/)

### Local DuckDB Setup (first time)

Full details in `dbt/local_setup.md`. Quick summary:

```zsh
# 1. Install dependencies (from dbt/)
uv sync

# 2. Configure dbt profile — copy the template and place it at ~/.dbt/profiles.yml
cp taxi_rides_ny/profiles.yml.example ~/.dbt/profiles.yml
# Or use the profile in-project: add --profiles-dir . to all dbt commands

# 3. Ingest raw data into DuckDB (from dbt/taxi_rides_ny/ — downloads ~5GB, takes several minutes)
uv run python ingest_data.py

# 4. Verify connection
uv run dbt debug
```

The ingestion script downloads yellow + green taxi data (2019–2020), converts to Parquet, and loads into `prod.yellow_tripdata` / `prod.green_tripdata` in `taxi_rides_ny.duckdb`. Data files and the `.duckdb` file are gitignored.

### dbt Commands

```zsh
uv run dbt deps              # install packages (dbt_utils, codegen)
uv run dbt run               # run all models
uv run dbt run --select staging              # run a single layer
uv run dbt run --select stg_yellow_tripdata  # run a single model
uv run dbt test                              # run all tests
uv run dbt test --select stg_yellow_tripdata # test a single model
uv run dbt source freshness                  # check source data freshness
```

### dbt Architecture

Models follow a strict three-layer pattern, each with a different materialization:

| Layer | Path | Materialization | Purpose |
|-------|------|----------------|---------|
| Staging | `models/staging/` | view | Rename/cast raw columns; one model per source table |
| Intermediate | `models/intermediate/` | table | Business logic; `int_trips_unioned` merges yellow + green |
| Marts | `models/marts/` | table (fct_trips: incremental) | Star schema: `fct_trips`, `dim_zones`, `dim_vendors` |

### Key dbt Conventions

- **Multi-target sources**: `sources.yml` uses Jinja conditionals — BigQuery uses `GCP_PROJECT_ID` env var + `nytaxi` schema; DuckDB and PostgreSQL both use `taxi_rides_ny` database + `prod` schema (the `else` branch covers both).
- **Dev sampling**: Staging models apply a date filter (`pickup_datetime >= '2019-01-01' AND < '2019-02-01'`) when `target.name == 'dev'`.
- **Null filtering**: All staging models filter `where vendorid is not null`.
- **Cross-db macros**: Use `dbt.datediff()` (not raw SQL date functions) to stay portable across PostgreSQL and BigQuery. See `macros/get_trip_duration_minutes.sql`.
- **Incremental model**: `fct_trips` uses `unique_key='trip_id'` and `on_schema_change='fail'`; new rows are selected via `where pickup_datetime > max(pickup_datetime)`.
- **Standardized column names**: Staging renames source-specific fields (e.g., `tpep_pickup_datetime` / `lpep_pickup_datetime` → `pickup_datetime`) so intermediate/mart models can treat yellow and green trips uniformly.

## Pre-commit Hooks

```zsh
pre-commit install    # set up hooks
pre-commit run --all-files
```

Active hooks: `check-added-large-files` (max 51 MB) and `detect-private-key`. Keep GCP keys out of commits.
