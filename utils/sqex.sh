#!/bin/bash

set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 [options]

Execute SQL statements from files or stdin.

Options:
  -d <database>   Database name (required)
  -u <username>   MySQL username (default: root)
  -p <password>   MySQL password (required)
  -f <file>       SQL file to execute (single file mode)
  -c <dir>        Directory with SQL/CSV files (batch mode)
  -o              Prompt for custom execution order (with -c)
  -s              Read SQL from stdin
  -v              Verbose output

Examples:
  # Execute single file
  $0 -d lab1 -p mysqlpwd -f script.sql
  
  # Execute from stdin
  cat script.sql | $0 -d lab1 -p mysqlpwd -s
  
  # Batch execute directory (alphabetical)
  $0 -d lab1 -p mysqlpwd -c ./sql_files
  
  # Batch with custom order
  $0 -d lab1 -p mysqlpwd -c ./sql_files -o
  
  # Execute CSV with SQL statements (one per row, quoted)
  $0 -d lab1 -p mysqlpwd -c ./data
EOF
    exit 1
}

if [ "$#" -lt 1 ]; then
    usage
fi

USERNAME="root"
PASSWORD=""
DATABASE=""
SQL_FILE=""
SQL_DIR=""
CUSTOM_ORDER=false
FROM_STDIN=false
VERBOSE=false

while getopts "d:u:p:f:c:osv" opt; do
    case $opt in
        d) DATABASE="$OPTARG" ;;
        u) USERNAME="$OPTARG" ;;
        p) PASSWORD="$OPTARG" ;;
        f) SQL_FILE="$OPTARG" ;;
        c) SQL_DIR="$OPTARG" ;;
        o) CUSTOM_ORDER=true ;;
        s) FROM_STDIN=true ;;
        v) VERBOSE=true ;;
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

# Validate mutually exclusive modes
modes_set=0
[ -n "$SQL_FILE" ] && ((modes_set++))
[ -n "$SQL_DIR" ] && ((modes_set++))
[ "$FROM_STDIN" = true ] && ((modes_set++))

if [ $modes_set -eq 0 ]; then
    echo "Error: Must specify -f, -c, or -s" >&2
    usage
elif [ $modes_set -gt 1 ]; then
    echo "Error: Only one of -f, -c, -s allowed" >&2
    usage
fi

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo "$@" >&2
    fi
}

execute_sql() {
    local sql="$1"
    local description="${2:-}"
    
    if [ -n "$description" ]; then
        echo "  Executing: $description"
    fi
    
    log_verbose "SQL: $sql"
    
    if ! mysql -u"$USERNAME" -p"$PASSWORD" 2>/dev/null "$DATABASE" -e "$sql"; then
        echo "✗ Failed to execute: $sql" >&2
        return 1
    fi
    
    return 0
}

execute_file() {
    local filepath="$1"
    
    if [ ! -f "$filepath" ]; then
        echo "Error: File '$filepath' not found" >&2
        return 1
    fi
    
    local filename=$(basename "$filepath")
    local ext="${filename##*.}"
    
    echo "Executing $filename..."
    
    case "$ext" in
        sql)
            # Direct SQL file
            if ! mysql -u"$USERNAME" -p"$PASSWORD" 2>/dev/null "$DATABASE" < "$filepath"; then
                echo "✗ Failed to execute $filename" >&2
                return 1
            fi
            ;;
        csv)
            # CSV with quoted SQL statements (one per row)
            local line_num=0
            while IFS= read -r line || [ -n "$line" ]; do
                ((line_num++))
                
                # Skip empty lines
                [ -z "$line" ] && continue
                
                # Strip outer quotes and whitespace
                local sql=$(echo "$line" | sed -e 's/^"//' -e 's/"$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
                
                if [ -n "$sql" ]; then
                    log_verbose "Line $line_num: $sql"
                    if ! execute_sql "$sql"; then
                        echo "✗ Failed at line $line_num in $filename" >&2
                        return 1
                    fi
                fi
            done < "$filepath"
            ;;
        *)
            echo "Warning: Unknown extension .$ext, treating as SQL file"
            if ! mysql -u"$USERNAME" -p"$PASSWORD" 2>/dev/null "$DATABASE" < "$filepath"; then
                echo "✗ Failed to execute $filename" >&2
                return 1
            fi
            ;;
    esac
    
    echo "✓ $filename complete"
    return 0
}

get_execution_order() {
    local dir="$1"
    
    shopt -s nullglob
    local files=("$dir"/*.{sql,csv})
    
    if [ ${#files[@]} -eq 0 ]; then
        echo "Error: No SQL/CSV files found in $dir" >&2
        return 1
    fi
    
    echo ""
    echo "Available files:"
    local i=1
    declare -g -A file_map
    for file in "${files[@]}"; do
        local filename=$(basename "$file")
        echo "  $i. $filename"
        file_map[$i]="$filename"
        ((i++))
    done
    
    echo ""
    echo "Enter execution order (space-separated numbers):"
    read -r order_input
    
    declare -g -a ordered_files=()
    for num in $order_input; do
        if [ -n "${file_map[$num]:-}" ]; then
            ordered_files+=("${file_map[$num]}")
        else
            echo "Warning: Invalid number $num, skipping" >&2
        fi
    done
    
    if [ ${#ordered_files[@]} -eq 0 ]; then
        echo "Error: No valid files selected" >&2
        return 1
    fi
    
    echo ""
    echo "Execution order:"
    for i in "${!ordered_files[@]}"; do
        echo "  $((i+1)). ${ordered_files[$i]}"
    done
    echo ""
}

# Single file mode
if [ -n "$SQL_FILE" ]; then
    execute_file "$SQL_FILE"
    echo "Done."
    exit 0
fi

# Stdin mode
if [ "$FROM_STDIN" = true ]; then
    echo "Reading SQL from stdin..."
    
    local temp_file=$(mktemp)
    trap "rm -f $temp_file" EXIT
    
    cat > "$temp_file"
    
    if ! mysql -u"$USERNAME" -p"$PASSWORD" 2>/dev/null "$DATABASE" < "$temp_file"; then
        echo "✗ Failed to execute stdin content" >&2
        exit 1
    fi
    
    echo "✓ Stdin execution complete"
    echo "Done."
    exit 0
fi

# Directory batch mode
if [ -n "$SQL_DIR" ]; then
    SQL_DIR=$(realpath "$SQL_DIR")
    
    if [ ! -d "$SQL_DIR" ]; then
        echo "Error: Directory '$SQL_DIR' not found" >&2
        exit 1
    fi
    
    declare -a files_to_execute=()
    
    if [ "$CUSTOM_ORDER" = true ]; then
        if ! get_execution_order "$SQL_DIR"; then
            echo "Error: Failed to get execution order" >&2
            exit 1
        fi
        files_to_execute=("${ordered_files[@]}")
    else
        shopt -s nullglob
        local all_files=("$SQL_DIR"/*.sql "$SQL_DIR"/*.csv)
        
        if [ ${#all_files[@]} -eq 0 ]; then
            echo "Warning: No SQL/CSV files found in $SQL_DIR"
            exit 0
        fi
        
        # Sort alphabetically
        IFS=$'\n' sorted=($(sort <<<"${all_files[*]}"))
        unset IFS
        
        for file in "${sorted[@]}"; do
            files_to_execute+=("$(basename "$file")")
        done
    fi
    
    echo "Executing ${#files_to_execute[@]} file(s)..."
    echo ""
    
    for filename in "${files_to_execute[@]}"; do
        filepath="$SQL_DIR/$filename"
        
        if [ ! -f "$filepath" ]; then
            echo "Warning: $filename not found, skipping"
            continue
        fi
        
        if ! execute_file "$filepath"; then
            exit 1
        fi
        echo ""
    done
    
    echo "Done."
    exit 0
fi

# Should never reach here
echo "Error: No execution mode specified" >&2
exit 1
