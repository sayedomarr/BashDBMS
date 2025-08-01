# BashDBMS

## Overview

**BashDBMS** is a simple Database Management System built using Bash shell scripts.  
It allows users to create, manage, and interact with databases and tables directly from the command line.

## Features

- **Main Menu:**
  - Create Database
  - List Databases
  - Connect to Database
  - Drop Database

- **Table Menu (after connecting):**
  - Create Table (with column types and primary key)
  - List Tables
  - Drop Table

- **Record Menu (per table):**
  - Insert Into Table (with type and PK validation)
  - Select From Table (show all, specific column, by primary key, filter, max, min)
  - Update Table
  - Delete From Table

## How It Works

- Each database is stored as a directory.
- Each table is stored as two files: `.meta` (schema) and `.table` (data).
- All operations are performed via interactive CLI menus.

## Usage

1. **Clone the repository:**
   ```bash
   git clone https://github.com/sayedomarr/BashDBMS.git
   cd BashDBMS
   ```

2. **Run the main script:**
   ```bash
   ./main.sh
   ```

3. **Follow the menu prompts to manage databases and tables.**

## Requirements

- Bash (Linux recommended)
- No external dependencies

## Project Structure

```
BashDBMS/
├── main.sh
├── scripts/
│   ├── db.sh
│   ├── table.sh
│   └── record.sh
├── utils/
│   └── common.sh
├── databases/      # All databases stored here
└── README.md
```

## Notes

- All data is stored locally in the `databases` directory.
- Input validation is enforced for names, types, and primary keys.







Feel free to adjust the README for your project and add more
