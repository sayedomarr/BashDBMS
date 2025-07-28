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
    printf "%s (y/n): " "$msg"
    read -r input
    [[ "$input" == "y" || "$input" == "Y" ]]
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


