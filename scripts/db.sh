#!/usr/bin/env bash
# File: scripts/db.sh — Phase 2: Database Management
# Purpose: Manage databases in the DBMS
# Author: Sayedomarr
# Date: 2025-07-28
# This script provides functions to create, list, drop, and connect to databases.
# Usage: Source this file in other scripts to use the functions defined here

#path to the root of the databases directory
DB_ROOT="$(dirname "$(realpath "$0")")"/databases

#path to the utils directory
UTILS_DIR="$(dirname "$(realpath "$0")")"/utils

# Source common utility functions
source "$UTILS_DIR/common.sh"


# create_database: Create a new database
create_database() {
    local name
    echo "Create a new database"
    
    # Prompt the user for the database name
    name=$(prompt "Enter Database Name" ) || { error "Invalid input."; return 1; }
    
    # Sanitize the input to ensure it is a valid database name
    name=$(echo "$name" | xargs)  # trim whitespace
    sanitize_input "$name" >/dev/null || { error "Invalid database name."; return 1; }
    
    # Check if the database already exists
    local db_dir="$DB_ROOT/$name"
    if [[ -d "$db_dir" ]]; then
        error "Database '$name' already exists."
        return 1
    fi

    # Create the database directory
    mkdir -p "$db_dir"
    success "Database '$name' created successfully."
}


#list_databases: List all available databases
list_databases() {
    # Check if the databases directory exists
    if [[ ! -d "$DB_ROOT" ]]; then
        error "Databases directory does not exist."
        return 1
    fi
    if ! ls -1 "$DB_ROOT" 2>/dev/null | grep -q .; then
        print_warning "No databases found."
        return 1
    fi

    print_header "Available Databases"
    find "$DB_ROOT" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort
}


# drop_database: Drop an existing database
drop_database() {
    local name
   # Prompt the user for the database name to drop
    name=$(prompt "Enter database name to drop") || { error "Invalid input."; return 1; }

    # Sanitize the input to ensure it is a valid database name
    sanitize_input "$name" >/dev/null || { error "Invalid database name."; return 1; }

    # Check if the database directory exists
    local db_dir="$DB_ROOT/$name"
    if [[ ! -d "$db_dir" ]]; then
        error "Database '$name' does not exist."
        return 1

    # Confirm the deletion with the user
    elif  confirm_action "Are you sure you want to delete '$name'?"; then
    rm -rf "$db_dir"
    success "Database '$name' dropped successfully."
    else
    print_warning "Deletion cancelled."

    fi

}



# connect_to_database: Connect to an existing database
connect_to_database() {
    local name

    
    print_header "Connect To Database"
    name=$(prompt "Enter database name to connect") || { error "Invalid input."; return 1; }
    name=$(echo "$name" | xargs)

    sanitize_input "$name" >/dev/null || { error "Invalid database name."; return 1; }

    # Check if the database directory exists
    local db_dir="$DB_ROOT/$name"
    if [[ ! -d "$db_dir" ]]; then
        error "Database '$name' does not exist."
        return 1
    fi

    # Set the global variable for the connected database
    export CONNECTED_DB="$db_dir"
    success "Connected to database '$name'."

    # Load the table management script
    local table_script="$SCRIPTS_DIR/table.sh"
    if [[ -f "$table_script" ]]; then
        source "$table_script"
        table_main_menu
    else
        error "Table management script not found."
    fi
}



