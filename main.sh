#!/usr/bin/env bash
# Author: sayedomarr
# Date: 2025-07-18
# Purpose: main script with a droplist menu to help user manage database and do all DBMS functions
# Usage: ./main.sh
# Arguments: userinput from 1 to 5
# Returns: None
# Notes: This script is the main entry point for the DBMS. It provides a menu-driv
# en interface for the user to interact with the database.
# The menu options are:
# 1. Create Database
# 2. List Databases
# 3. Connect To Databases
# 4. Drop Database
#

ROOT_DIR="$(dirname "$(realpath "$0")")"
SCRIPTS_DIR="$ROOT_DIR/scripts"
UTILS_DIR="$ROOT_DIR/utils"

source "$UTILS_DIR/common.sh"
source "$SCRIPTS_DIR/db.sh"
#bash "$ROOT_DIR/init.sh"



main() {
    while true; do
        print_header "Database Management"
        printf "1) Create Database\n2) List Databases\n3) Drop Database\n4) Connect To Database\n5) Exit\n"
        print_line

        local choice
        read -rp "Select an option [1-5]: " choice
        if [[ ! "$choice" =~ ^[1-5]$ ]]; then
            error "Invalid input. Please enter a number between 1 and 5."
            continue
        fi
        case "$choice" in
            1) create_database ;;
            2) list_databases ;;
            3) drop_database ;;
            4) connect_to_database ;;
            5) success "Goodbye!"; break ;;
            *) error "Invalid option." ;;
        esac

        print_line
    done
}


main "$@"
