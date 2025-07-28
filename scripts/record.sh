#!/usr/bin/env bash
# File: scripts/table_data.sh — Phase 4: Data Manipulation
# Purpose: Insert rows into table with validation
# Author: sayedomarr
# Date: 2025-07-28

UTILS_DIR="$(dirname "$(realpath "$0")")/utils"
source "$UTILS_DIR/common.sh"
echo $UTILS_DIR

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


# Function to update a row in a table
update_table() {
    print_header "Update Table"

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

    local pk_col="${col_names[$pk_index]}"
    local pk_type="${col_types[$pk_index]}"

    # Prompt for the primary key value to update
    local pk_val
    pk_val=$(prompt "Enter $pk_col (Primary Key) to update") || return 1
    pk_val=$(echo "$pk_val" | xargs)

    # Validate primary key value
    if [[ "$pk_type" == "int" && ! "$pk_val" =~ ^-?[0-9]+$ ]]; then
        error "Primary Key must be an integer."
        return 1
    elif [[ "$pk_type" == "string" && "$pk_val" =~ [:] ]]; then
        error "Colons ':' not allowed in string."
        return 1
    fi


    # Search for the line to update
    local old_row

    # Check if the row with the given primary key exists   
    old_row=$(grep -m1 "^$pk_val:" "$data_file")
    if [[ -z "$old_row" ]]; then
        error "No row found with Primary Key '$pk_val'."
        return 1
    fi

    # Split the old row into values
    IFS=':' read -ra old_values <<< "$old_row"
    local new_values=()

    # Print the current values for reference
    print_header "Updating Row [Primary Key: $pk_val]"

    # Loop through each column to get new values
    for i in "${!col_names[@]}"; do
        # Skip the primary key column
        if [[ "$i" -eq "$pk_index" ]]; then
            new_values+=("${old_values[$i]}")
            continue
        fi

        local col="${col_names[$i]}"
        local type="${col_types[$i]}"
        local current_val="${old_values[$i]}"
        local new_val=""
        # Prompt for the new value
        print_header "Column: $col [Type: $type]"
        printf "Current value: '%s'\n" "$current_val"
        while true; do
            # Prompt for the new value

            new_val=$(prompt "New value for $col [$type] (leave empty to keep '$current_val')") || return 1
            new_val=$(echo "$new_val" | xargs)

            if [[ -z "$new_val" ]]; then
                new_val="$current_val"
                break
            fi

            # Validate type
            if [[ "$type" == "int" && ! "$new_val" =~ ^-?[0-9]+$ ]]; then
                error "Expected integer."
                continue
            elif [[ "$type" == "string" && "$new_val" =~ [:] ]]; then
                error "Colons ':' are not allowed."
                continue
            fi

            break
        done
        new_values+=("$new_val")
    done

    # Build updated line and write back
    local updated_row
    updated_row=$(IFS=:; echo "${new_values[*]}")

    grep -v "^$pk_val:" "$data_file" > "$data_file.tmp"
    printf "%s\n" "$updated_row" >> "$data_file.tmp"
    mv "$data_file.tmp" "$data_file"

    success "Row with PK '$pk_val' updated successfully."
}

#delete_from_table: Delete a row from a table
delete_from_table() {
    print_header "Delete From Table"
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

    local pk_col="${col_names[$pk_index]}"
    local pk_type="${col_types[$pk_index]}"

    local pk_val
    pk_val=$(prompt "Enter $pk_col (Primary Key) of row to delete") || return 1
    pk_val=$(echo "$pk_val" | xargs)

    # Validate PK
    if [[ "$pk_type" == "int" && ! "$pk_val" =~ ^-?[0-9]+$ ]]; then
        error "Primary Key must be an integer."
        return 1
    elif [[ "$pk_type" == "string" && "$pk_val" =~ [:] ]]; then
        error "Colons ':' not allowed in string."
        return 1
    fi

    # Check if row exists
    if ! grep -q "^$pk_val:" "$data_file"; then
        error "No row found with Primary Key '$pk_val'."
        return 1
    fi

    # Confirm deletion
    confirm_action "Are you sure you want to delete the row with PK '$pk_val'?" || {
        print_warning "Operation cancelled."
        return
    }

    # Delete row
    grep -v "^$pk_val:" "$data_file" > "$data_file.tmp"
    mv "$data_file.tmp" "$data_file"

    success "Row with Primary Key '$pk_val' deleted successfully."
}

record_main_menu() {
    while true; do
        print_header "Record Management - [$(basename "$CONNECTED_DB")]"
        printf "1) Insert Into Table\n"
        printf "2) Select From Table\n"
        printf "3) Update Table\n"
        printf "4) Delete From Table\n"
        printf "5) Back to Table Menu\n"
        print_line

        local choice
        read -rp "Select an option [1-5]: " choice

        case "$choice" in
            1) insert_into_table ;;
            2) select_from_table ;;
            3) update_table ;;
            4) delete_from_table ;;
            5) break ;;
            *) error "Invalid option. Please choose between 1 and 5." ;;
        esac
    done
}

