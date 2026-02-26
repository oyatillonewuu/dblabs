#!/bin/bash

set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 <mode> [options]

Modes:
  create-db    Create/recreate database from schema
  import-csv   Import CSV files into existing database
  exec-sql     Execute SQL statements from CSV files (one statement per row)
  setup        Create database and import CSV files
  cleanup      Drop database

Options:
  -d <database>   Database name (required)
  -u <username>   MySQL username (default: root)
  -p <password>   MySQL password (required)
  -s <schema>     Path to schema.sql (required for create-db/setup)
  -c <csv_dir>    Path to CSV directory (required for import-csv/exec-sql/setup)
  -o              Prompt for custom load/execution order

Examples:
  $0 setup -d lab1 -p mysqlpwd -s schema.sql -c ./data
  $0 exec-sql -d lab1 -p mysqlpwd -c ./sql_data -o
  $0 import-csv -d lab1 -p mysqlpwd -c ./data -o
  $0 cleanup -d lab1 -p mysqlpwd
EOF
    exit 1
}

if [ "$#" -lt 1 ]; then
    usage
fi

MODE="$1"
shift

USERNAME="root"
PASSWORD=""
DATABASE=""
SCHEMA=""
CSV_DIR=""
CUSTOM_ORDER=false

while getopts "d:u:p:s:c:o" opt; do
    case $opt in
        d) DATABASE="$OPTARG" ;;
        u) USERNAME="$OPTARG" ;;
        p) PASSWORD="$OPTARG" ;;
        s) SCHEMA="$OPTARG" ;;
        c) CSV_DIR="$OPTARG" ;;
        o) CUSTOM_ORDER=true ;;
        *) usage ;;
    esac
done

if [ -z "$DATABASE" ] || [ -z "$PASSWORD" ]; then
    echo "Error: -d and -p are required" >&2
    usage
fi

if ! command -v mysql &> /dev/null; then
    echo "Error: mysql client not found" >&2
    exit 1
fi

create_database() {
    if [ -z "$SCHEMA" ]; then
        echo "Error: -s required for create-db mode" >&2
        exit 1
    fi
    
    if [ ! -f "$SCHEMA" ]; then
        echo "Error: Schema file '$SCHEMA' not found" >&2
        exit 1
    fi
    
    echo "Dropping database '$DATABASE' if exists..."
    mysql -u"$USERNAME" -p"$PASSWORD" 2>/dev/null -e "DROP DATABASE IF EXISTS \`$DATABASE\`;"
    
    echo "Creating database '$DATABASE'..."
    mysql -u"$USERNAME" -p"$PASSWORD" 2>/dev/null -e "CREATE DATABASE \`$DATABASE\`;"
    
    echo "Loading schema from $SCHEMA..."
    mysql -u"$USERNAME" -p"$PASSWORD" 2>/dev/null "$DATABASE" < "$SCHEMA"
    
    echo "✓ Database created"
}

get_custom_order() {
    local csv_dir="$1"
    
    shopt -s nullglob
    local csv_files=("$csv_dir"/*.csv)
    
    if [ ${#csv_files[@]} -eq 0 ]; then
        echo "Error: No CSV files found in $csv_dir" >&2
        return 1
    fi
    
    local tables=()
    for csv in "${csv_files[@]}"; do
        tables+=("$(basename "$csv" .csv)")
    done
    
    local db_tables
    db_tables=$(mysql -u"$USERNAME" -p"$PASSWORD" 2>/dev/null "$DATABASE" -sN -e "SHOW TABLES;")
    
    if [ -z "$db_tables" ]; then
        echo "Error: No tables found in database" >&2
        return 1
    fi
    
    echo ""
    echo "Available tables with CSV files:"
    local i=1
    declare -g -A table_map
    for table in "${tables[@]}"; do
        if echo "$db_tables" | grep -q "^${table}$"; then
            echo "  $i. $table"
            table_map[$i]="$table"
            ((i++))
        fi
    done
    
    echo ""
    echo "Enter load order (space-separated numbers):"
    read -r order_input
    
    declare -g -a ordered_tables=()
    for num in $order_input; do
        if [ -n "${table_map[$num]:-}" ]; then
            ordered_tables+=("${table_map[$num]}")
        else
            echo "Warning: Invalid number $num, skipping" >&2
        fi
    done
    
    if [ ${#ordered_tables[@]} -eq 0 ]; then
        echo "Error: No valid tables selected" >&2
        return 1
    fi
    
    echo ""
    echo "Load order:"
    for i in "${!ordered_tables[@]}"; do
        echo "  $((i+1)). ${ordered_tables[$i]}"
    done
    echo ""
}

get_sql_custom_order() {
    local csv_dir="$1"
    
    shopt -s nullglob
    local csv_files=("$csv_dir"/*.csv)
    
    if [ ${#csv_files[@]} -eq 0 ]; then
        echo "Error: No CSV files found in $csv_dir" >&2
        return 1
    fi
    
    echo ""
    echo "Available SQL CSV files:"
    local i=1
    declare -g -A sql_file_map
    for csv in "${csv_files[@]}"; do
        local filename=$(basename "$csv")
        echo "  $i. $filename"
        sql_file_map[$i]="$filename"
        ((i++))
    done
    
    echo ""
    echo "Enter execution order (space-separated numbers):"
    read -r order_input
    
    declare -g -a ordered_sql_files=()
    for num in $order_input; do
        if [ -n "${sql_file_map[$num]:-}" ]; then
            ordered_sql_files+=("${sql_file_map[$num]}")
        else
            echo "Warning: Invalid number $num, skipping" >&2
        fi
    done
    
    if [ ${#ordered_sql_files[@]} -eq 0 ]; then
        echo "Error: No valid files selected" >&2
        return 1
    fi
    
    echo ""
    echo "Execution order:"
    for i in "${!ordered_sql_files[@]}"; do
        echo "  $((i+1)). ${ordered_sql_files[$i]}"
    done
    echo ""
}

import_csvs() {
    if [ -z "$CSV_DIR" ]; then
        echo "Error: -c required for import-csv mode" >&2
        exit 1
    fi
    
    CSV_DIR=$(realpath "$CSV_DIR")
    
    if [ ! -d "$CSV_DIR" ]; then
        echo "Error: Directory '$CSV_DIR' not found" >&2
        exit 1
    fi
    
    declare -a tables_to_load=()
    
    if [ "$CUSTOM_ORDER" = true ]; then
        if ! get_custom_order "$CSV_DIR"; then
            echo "Error: Failed to get custom order" >&2
            exit 1
        fi
        tables_to_load=("${ordered_tables[@]}")
    else
        shopt -s nullglob
        local csv_files=("$CSV_DIR"/*.csv)
        
        if [ ${#csv_files[@]} -eq 0 ]; then
            echo "Warning: No CSV files found in $CSV_DIR"
            return
        fi
        
        for csv_file in "${csv_files[@]}"; do
            tables_to_load+=("$(basename "$csv_file" .csv)")
        done
    fi
    
    echo "Importing ${#tables_to_load[@]} CSV files..."
    
    for table_name in "${tables_to_load[@]}"; do
        csv_file="$CSV_DIR/${table_name}.csv"
        
        if [ ! -f "$csv_file" ]; then
            echo "Warning: ${table_name}.csv not found, skipping"
            continue
        fi
        
        abs_path=$(realpath "$csv_file")
        
        echo "  Loading $(basename "$csv_file") → $table_name"
        
        if ! mysql -u"$USERNAME" -p"$PASSWORD" 2>/dev/null "$DATABASE" --local-infile=1 <<EOF
LOAD DATA LOCAL INFILE '$abs_path'
INTO TABLE \`$table_name\`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
EOF
        then
            echo "✗ Failed to load $table_name" >&2
            exit 1
        fi
    done
    
    echo "✓ CSV import complete"
}

exec_sql_csv() {
    if [ -z "$CSV_DIR" ]; then
        echo "Error: -c required for exec-sql mode" >&2
        exit 1
    fi
    
    CSV_DIR=$(realpath "$CSV_DIR")
    
    if [ ! -d "$CSV_DIR" ]; then
        echo "Error: Directory '$CSV_DIR' not found" >&2
        exit 1
    fi
    
    declare -a files_to_execute=()
    
    if [ "$CUSTOM_ORDER" = true ]; then
        if ! get_sql_custom_order "$CSV_DIR"; then
            echo "Error: Failed to get custom order" >&2
            exit 1
        fi
        files_to_execute=("${ordered_sql_files[@]}")
    else
        shopt -s nullglob
        local csv_files=("$CSV_DIR"/*.csv)
        
        if [ ${#csv_files[@]} -eq 0 ]; then
            echo "Warning: No CSV files found in $CSV_DIR"
            return
        fi
        
        for csv_file in "${csv_files[@]}"; do
            files_to_execute+=("$(basename "$csv_file")")
        done
    fi
    
    echo "Executing SQL from ${#files_to_execute[@]} CSV files..."
    
    for filename in "${files_to_execute[@]}"; do
        csv_file="$CSV_DIR/$filename"
        
        if [ ! -f "$csv_file" ]; then
            echo "Warning: $filename not found, skipping"
            continue
        fi
        
        echo "  Executing $filename"
        
        # Read CSV, strip outer quotes only, execute each statement
        while IFS= read -r line || [ -n "$line" ]; do
            # Remove leading quote, trailing quote, and any whitespace
            sql=$(echo "$line" | sed -e 's/^"//' -e 's/"$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            
            if [ -n "$sql" ]; then
                if ! mysql -u"$USERNAME" -p"$PASSWORD" 2>/dev/null "$DATABASE" -e "$sql"; then
                    echo "✗ Failed to execute: $sql" >&2
                    exit 1
                fi
            fi
        done < "$csv_file"
    done
    
    echo "✓ SQL execution complete"
}

cleanup_database() {
    echo "Dropping database '$DATABASE'..."
    mysql -u"$USERNAME" -p"$PASSWORD" 2>/dev/null -e "DROP DATABASE IF EXISTS \`$DATABASE\`;"
    echo "✓ Database dropped"
}

case "$MODE" in
    create-db)
        create_database
        ;;
    import-csv)
        import_csvs
        ;;
    exec-sql)
        exec_sql_csv
        ;;
    setup)
        create_database
        import_csvs
        ;;
    cleanup)
        cleanup_database
        ;;
    *)
        echo "Error: Invalid mode '$MODE'" >&2
        usage
        ;;
esac

echo "Done."
