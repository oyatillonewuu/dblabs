```
  Zero credits to AI except helping in learning some things and debugging nasty connection pooling/cursor consuming.
  AI free.
```

# Project

This project implements simple part of a university LMS system.

**Note:** recommended python version is `3.12`.

# Running

## Setup the environment

```
  cd lms
  python3 -m venv .venv
  pip3 install -r requirements.txt
```

## Setup the database

First, create your database, and then load the schema:

```
  cd db_data
  mysql -u <username> -p <pwd> <db_name> < schema.sql
```

## Setup environment variables

Copy `.env.example` to `.env` and configure the appropriate values.

## Run the app

```
  fastapi dev src
```

# Usage

Navigate to `localhost:800/docs` to try out.
