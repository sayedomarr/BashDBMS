#! /bin/bash
# File: utils/common.sh
# Purpose: Common reusable functions across BashDBMS
# Author: sayedomarr
# Date: 2025-07-20
# Usage: Source this file in other scripts to use the functions defined here
# Returns: None

# sanitize_input: Sanitize user input 
sanitize_input() {
    local input="$1"
    #check validity of input
    if [[ "$input" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        printf "%s" "$input"
        return 0
    fi
    printf "Invalid name. Only letters, digits, and underscores allowed.\n" >&2
    return 1
}
# prompt: Display a prompt and read user input
# Arguments: A message to display as the prompt
# Returns: User input
prompt() {
    local msg="$1"
    local input
    printf "%s: " "$msg"
    read -r input
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

