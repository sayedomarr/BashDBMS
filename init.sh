#!/usr/bin/env bash
# Author: sayedomarr
# Date: 2025-07-18
# Purpose: Initialize the project structure for the DBMS
# Usage: ./init.sh
# Arguments: None
# Returns: None
# Notes: This script sets up the necessary directories and files for the DBMS project.
# It creates the base directory and subdirectories for utilities, scripts, tests, databases, and logs.
#========== GLOBAL VARIABLES ==========
UTILS_DIR="utils"
SCRIPTS_DIR="scripts"
TESTS_DIR="tests"
DATA_DIR="databases"
LOGS_DIR="logs"

create_project_structure() {
    echo "Creating project structure..."
    mkdir -p "$UTILS_DIR" "$SCRIPTS_DIR" "$TESTS_DIR" "$DATA_DIR" "$LOGS_DIR"
    echo "Project structure created successfully."
}

create_project_structure