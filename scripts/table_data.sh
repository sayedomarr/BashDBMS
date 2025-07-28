#!/usr/bin/env bash
# File: scripts/table_data.sh — Phase 4: Data Manipulation
# Purpose: Insert rows into table with validation
# Author: sayedomarr
# Date: 2025-07-28

UTILS_DIR="$(dirname "$(realpath "$0")")/utils"
source "$UTILS_DIR/common.sh"


# insert_into_table: Insert a new row into a table
insert_into_table() {
    
    print_header "Insert Into Table"

    # Check if a database is connected
    if ! is_connected; then
        error "Not connected to any valid database."
        return 1
    fi

    # Prompt for the table name
    local table_name
    table_name=$(prompt "Enter table name") || return 1
    table_name=$(echo "$table_name" | xargs)
    sanitize_input "$table_name" >/dev/null || { error "Invalid table name."; return 1; }

    # Check if the table exists
    if ! check_table_exists "$table_name"; then
        error "Table '$table_name' does not exist."
        return 1
    fi


    # Load the table schema
    load_table_schema "$table_name" || return 1
    local data_file="$CONNECTED_DB/$table_name.table"

    local row_values=()
    
    
    for i in "${!col_names[@]}"; do
        local val=""
        while true; do
            # Prompt for the value
            val=$(prompt "Enter value for ${col_names[$i]} [${col_types[$i]}]") || return 1
            val=$(echo "$val" | xargs)

            # Type validation
            if [[ "${col_types[$i]}" == "int" && ! "$val" =~ ^-?[0-9]+$ ]]; then
                error "Expected integer."
                continue
            elif [[ "${col_types[$i]}" == "string" && "$val" =~ [:] ]]; then
                error "Colons ':' are not allowed in strings."
                continue
            fi

            # Primary Key uniqueness check
            if [[ "$i" -eq "$pk_index" ]]; then
                if grep -q "^$val:" "$data_file"; then
                    error "Primary key '$val' already exists."
                    continue
                fi
            fi
            break
        done
        row_values+=("$val")
    done
    # Write the row to the data file
    printf "%s\n" "$(IFS=:; echo "${row_values[*]}")" >> "$data_file"
    success "Row inserted successfully into '$table_name'."
}


#select_from_table: Select rows from a table
select_from_table() {
    print_header "Select From Table"

    # Check if a database is connected
    if ! is_connected; then
        error "Not connected to any valid database."
        return 1
    fi

    # Prompt for the table name
    local table_name
    table_name=$(prompt "Enter table name") || return 1
    table_name=$(echo "$table_name" | xargs)
    sanitize_input "$table_name" >/dev/null || { error "Invalid table name."; return 1; }

    # Check if the table exists
    if ! check_table_exists "$table_name"; then
        error "Table '$table_name' does not exist."
        return 1
    fi

    # Load the table schema
    load_table_schema "$table_name" || return 1
    local data_file="$CONNECTED_DB/$table_name.table"

    # Check if the data file exists and is not empty
    if [[ ! -s "$data_file" ]]; then
        print_warning "No rows found in table '$table_name'."
        return
    fi

    # Print the table header
    print_line
    printf "|"
    for col in "${col_names[@]}"; do
        printf " %-15s |" "$col"
    done
    printf "\n"
    print_line

    # Read and print each row
    while IFS= read -r row; do
        IFS=':' read -ra fields <<< "$row"
        printf "|"
        for field in "${fields[@]}"; do
            printf " %-15s |" "$field"
        done
        printf "\n"
    done < "$data_file"

    print_line
}
