```
  Zero credits: to AI.
  AI free.
```

# Project
This project implements simple part of a university LMS system.

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
