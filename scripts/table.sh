#!/usr/bin/env bash
# File: scripts/table.sh — Phase 3: Table Management
# Purpose: Manage tables within a database in the DBMS
# Author: sayedomarr
# Date: 2025-07-28
# This script provides functions to create, list and drop tables.



#path to the utils directory
UTILS_DIR="$(dirname "$(realpath "$0")")"/utils

# Source common utility functions
source "$UTILS_DIR/common.sh"




create_table() {

    # Check if a database is connected
    if [[ -z "$CONNECTED_DB" || ! -d "$CONNECTED_DB" ]]; then
        error "Not connected to any valid database."
        return 1
    fi
    
    # Prompt the user for the table name
    local table_name
    table_name=$(prompt "Enter table name") || { error "Input failed."; return 1; }
    table_name=$(echo "$table_name" | xargs)

    # Sanitize the input to ensure it is a valid table name
    sanitize_input "$table_name" >/dev/null || { error "Invalid table name."; return 1; }

   # Check for reserved patterns in the table name
    if [[ "$table_name" =~ \. ]] || [[ "$table_name" =~ ^(if|then|else|do|done|while)$ ]]; then
        error "Table name contains reserved patterns."
        return 1
    fi

    # Check if the table already exists
    local meta_file="$CONNECTED_DB/$table_name.meta"
    local data_file="$CONNECTED_DB/$table_name.table"

    if [[ -e "$meta_file" || -e "$data_file" ]]; then
        error "Table '$table_name' already exists."
        return 1
    fi

    # Prompt for the number of columns and their definitions
    local col_count
    col_count=$(prompt "Enter number of columns") || return 1
    col_count=$(echo "$col_count" | xargs)

    if ! is_positive_integer "$col_count"; then
        error "Column count must be a positive integer."
        return 1
    fi    

    # Initialize an array to hold the schema
    local schema=()

    # Flag to check if a Primary Key is defined
    local pk_defined=false

    # Associative array to track column names
    local -A col_names_seen=()

    # Loop to define each column
    print_header "Define Table Schema for '$table_name'"
    printf "You will define %d columns.\n" "$col_count"
    print_line
    for ((i=1; i<=col_count; i++)); do
        echo
        print_header "Define column #$i"

        local col_name col_type is_pk flag=""
        col_name=$(prompt "Column name") || return 1
        col_name=$(echo "$col_name" | xargs)
        sanitize_input "$col_name" >/dev/null || { error "Invalid column name."; return 1; }

        # Check if the column name is already defined   
        if [[ ${col_names_seen[$col_name]} ]]; then
            error "Column '$col_name' already defined."
            return 1
        fi

        # Check for reserved words in the column name
        if [[ "$col_name" =~ ^(select|from|int|string)$ ]]; then
            error "Column name '$col_name' is a reserved word."
            return 1
        fi

        # Add the column name to the associative array
        # This prevents duplicate column names in the same table
        col_names_seen[$col_name]=1

        col_type=$(prompt "Column type (int/string)") || return 1
        col_type=$(echo "$col_type" | tr '[:upper:]' '[:lower:]')
        
        # Validate the column type
        if [[ "$col_type" != "int" && "$col_type" != "string" ]]; then
            error "Invalid type. Only 'int' or 'string' allowed."
            return 1
        fi

        # Check if the column is a Primary Key
        is_pk=$(prompt "Is this column the Primary Key? (y/n)") || return 1
        if [[ "$is_pk" == "y" || "$is_pk" == "Y" ]]; then
            if $pk_defined; then
                error "Primary Key already defined."
                return 1
            fi
            pk_defined=true
            flag=":pk"
        fi

        # Add the column definition to the schema
        schema+=("$col_name:$col_type$flag")
    done

    # Check if a Primary Key was defined
    if ! $pk_defined; then
        error "You must define one Primary Key column."
        return 1
    fi

    # Try writing schema
    # Create the metadata file and data file
    if ! printf "%s\n" "${schema[@]}" > "$meta_file"; then
        error "Failed to write schema to '$meta_file'"
        return 1
    fi

    if ! touch "$data_file"; then
        error "Failed to create data file '$data_file'"
        return 1
    fi
    # Success message
    success "Table '$table_name' created successfully."
    print_header "Final Table Schema:"
    printf "%s\n" "${schema[@]}"
}

table_main_menu() {
    while true; do
        print_header "Table Management - [$(basename "$CONNECTED_DB")]"
        printf "1) Create Table\n2) List Tables\n3) Drop Table\n4) Back to Main Menu\n"
        print_line

        local choice
        read -rp "Select an option [1-4]: " choice

        case "$choice" in
            1) create_table ;;
            2) list_tables ;;
            3) drop_table ;;
            4) break ;; 
            *) error "Invalid option." ;;
        esac
    done
}