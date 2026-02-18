# Local Setup Guide

This guide walks you through setting up a local analytics engineering environment using DuckDB and dbt.

- dbt Core
- DuckDB

> [!NOTE]
> This guide will explain how to do the setup manually. If you want an additional challenge, try to run this setup using Docker Compose or a Python virtual environment.

**Important:** All dbt commands must be run from inside the `taxi_rides_ny/` directory.

The setup steps below will guide you through:

- Installing the necessary tools
- Configuring your connection to DuckDB
- Loading the NYC taxi data
- Verifying everything works

## Step 1: Install DuckDB

DuckDB is a fast, in-process SQL database that works great for local analytics workloads. To install DuckDB, follow the instruction on the [official site](https://duckdb.org/docs/installation/) for your specific operating system.

> [!TIP]
> You can install DuckDB in two ways. You can install the CLI or install the client API for your favorite programming language (in the case of Python, you can use `pip install duckdb`). I personally prefer installing the CLI, but either way is fine.

## Step 2: Install dbt

This project uses `uv` for dependency management (consistent with the rest of the repo):

```zsh
cd dbt/
uv add dbt-duckdb
```

This installs:
- **dbt-core**: The core dbt framework
- **dbt-duckdb**: The DuckDB adapter for dbt

## Step 3: Configure dbt Profile

Since this repository already contains a dbt project (`taxi_rides_ny/`), you don't need to run `dbt init`. Instead, you need to configure your dbt profile to connect to DuckDB.

### Create or Update `~/.dbt/profiles.yml`

The dbt profile tells dbt how to connect to your database. Create or update the file `~/.dbt/profiles.yml` with the following content:

```yaml
taxi_rides_ny:
  target: dev
  outputs:
    # DuckDB Development profile
    dev:
      type: duckdb
      path: taxi_rides_ny.duckdb
      schema: dev
      threads: 1
      extensions:
        - parquet
      settings:
        memory_limit: '2GB'
        preserve_insertion_order: false

    # DuckDB Production profile
    prod:
      type: duckdb
      path: taxi_rides_ny.duckdb
      schema: prod
      threads: 1
      extensions:
        - parquet
      settings:
        memory_limit: '2GB'
        preserve_insertion_order: false

# Troubleshooting:
# - If you have less than 4GB RAM, try setting memory_limit to '1GB'
# - If you have 16GB+ RAM, you can increase to '4GB' for faster builds
# - Expected build time: 5-10 minutes on most systems
```

> [!TIP]
> A ready-to-copy template is also available at `taxi_rides_ny/profiles.yml.example` in this repository.

Alternatively, if you want to keep the profile inside the project directory, you can run dbt commands with the `--profiles-dir .` flag from inside `taxi_rides_ny/`:

```zsh
dbt run --profiles-dir .
```

## Step 4: Download and Ingest Data

Now that your dbt profile is configured, let's load the taxi data into DuckDB. Navigate to the dbt project directory and run the ingestion script:

```zsh
cd taxi_rides_ny/
uv run python ingest_data.py
```

This script:
- Downloads yellow and green taxi data from 2019–2020
- Converts CSV.gz files to Parquet (then removes the originals to save space)
- Creates the `prod` schema in DuckDB
- Loads raw data into `prod.yellow_tripdata` and `prod.green_tripdata`

The download may take several minutes depending on your internet connection.

## Step 5: Test the dbt Connection

Verify dbt can connect to your DuckDB database:

```zsh
cd taxi_rides_ny/
uv run dbt debug
```

## Step 6: Install dbt Power User Extension (VS Code Users)

If you're using Visual Studio Code, install the **dbt Power User** extension to enhance your dbt development experience.

### What is dbt Power User?

dbt Power User is a VS Code extension that provides:

- SQL syntax highlighting and formatting for dbt models
- Inline column-level lineage visualization
- Auto-completion for dbt models, sources, and macros
- Interactive documentation preview
- Model compilation and execution directly from the editor

### Why Not Use the Official dbt Extension?

dbt Labs released an official VS Code extension called *dbt Extension powered by the new dbt Fusion engine*. However, this extension requires dbt Fusion and **does not support dbt Core**. Since we're using dbt Core with DuckDB for local development, we need the community-maintained **dbt Power User by AltimateAI** extension instead. This extension:

- Works seamlessly with dbt Core (not just dbt Cloud)
- Supports all dbt adapters, including DuckDB
- Is actively maintained and open source
- Provides a rich feature set for local development

### Installation

1. Open VS Code
2. Go to Extensions (`Ctrl+Shift+X` / `Cmd+Shift+X`)
3. Search for **"dbt Power User"**
4. Install **dbt Power User** by AltimateAI (not the dbt Labs version)

Alternatively, install it from the [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=innoverio.vscode-dbt-power-user).

> [!NOTE]
> At this point, your local dbt environment is fully configured and ready to use. The next steps (running models, tests, and building documentation) will be covered in the tutorial videos.

## Additional Resources

- [DuckDB Documentation](https://duckdb.org/docs/)
- [dbt Documentation](https://docs.getdbt.com/)
- [dbt-duckdb Adapter](https://github.com/duckdb/dbt-duckdb)
- [NYC Taxi Data Dictionary](https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf)
