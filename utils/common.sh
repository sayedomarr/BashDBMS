#!/usr/bin/env bash
# File: utils/common.sh
# Purpose: Common reusable functions across BashDBMS
# Author: sayedomarr
# Date: 2025-07-20
# Usage: Source this file in other scripts to use the functions defined here
# Returns: None


# sanitize_input: Sanitize user input 
sanitize_input() {
    local input="$1"
    local len=${#input}

    # Check if the input length is within the valid range
    if (( len < 2 || len > 30 )); then
        printf "Invalid name length. Must be between 3 and 20 characters.\n" >&2
        return 1
    fi

        #check validity of input
    if [[ ! "$input" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        printf "Invalid name. Only letters, digits, and underscores allowed.\n" >&2
        return 1
    fi
    printf "%s" "$input"
    return 0
}



# prompt: Display a prompt and read user input
# Arguments: A message to display as the prompt
# Returns: User input
prompt() {
    local msg="$1"
    local input
    read -r -p "$msg: " input
    input=$(echo "$input" | xargs)  # remove leading/trailing spaces
    printf "%s" "$input"
}




#print_line: Print a separator line
print_line() {
    printf "%s\n" "----------------------------------------"
}



# success: Print a success message
success() {
    local msg="$1"
    printf "%s\n" "$msg"
}



# error: Print an error message to stderr
error() {
    local msg="$1"
    printf "Error: %s\n" "$msg" >&2
}



# print_header: Print a header with a title
print_header() {
    printf "\n== %s ==\n" "$1"
}



# print_warning: Print a warning message
print_warning() {
    printf "Warning: %s\n" "$1"
}


# confirm_action: Prompt the user to confirm an action
confirm_action() {
    local msg="$1"
    local input
    while true; do
        printf "%s (y/n): " "$msg"
        read -r input
        case "$input" in
            [yY]) return 0 ;;  # يعني yes
            [nN]) return 1 ;;  # يعني no
            *) printf "Invalid input. Please enter 'y' or 'n' only.\n" ;;
        esac
    done
}



# Check if input is a positive integer (1 or more)
is_positive_integer() {
    local input="$1"

    if [[ "$input" =~ ^[1-9][0-9]*$ ]]; then
        return 0  # valid
    else
        return 1  # invalid
    fi
}

# utils/table_utils.sh
check_table_exists() {
    local tbl="$1"
    [[ -f "$CONNECTED_DB/$tbl.meta" && -f "$CONNECTED_DB/$tbl.table" ]]
}

is_connected() {
    [[ -n "$CONNECTED_DB" && -d "$CONNECTED_DB" ]]
}

load_table_schema() {
    local table_name="$1"
    local meta_file="$CONNECTED_DB/$table_name.meta"

    [[ ! -f "$meta_file" ]] && error "Table '$table_name' does not exist." && return 1

    
    col_names=()
    col_types=()
    pk_index=-1
    local index=0



    # Read the schema and identify the primary key
    while IFS= read -r line; do

        # Split the line into name and type
        name="${line%%:*}"
        # Remove the name part 
        rest="${line#*:}"

        # Extract type 
        type="${rest%%:*}"

        # Remove the type part and check for primary key
        [[ "$rest" == *":pk" ]] && pk_index=$index

        # Add to arrays
        col_names+=("$name")
        col_types+=("$type")
        ((index++))
    done < "$meta_file"

    # Validate primary key presence
    if [[ "$pk_index" -eq -1 ]]; then
        error "No primary key defined in table schema."
        return 1
    fi

}


