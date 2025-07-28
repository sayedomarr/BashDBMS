# 📁 Bash Shell Script Database Management System (DBMS)
A modular CLI-based Database Management System implemented in Bash, following clean architecture and best scripting practices.

---

## 🚀 Project Phases

### ✅ Phase 1: Setup & Utilities
- [x] Create the project directory structure:
  - `databases/` — stores all databases as directories
  - `utils/` — shared reusable utility functions
  - `scripts/` — core application logic
  - `tests/` — future test scripts and unit tests
- [x] Implement base utility functions:
  - Input sanitization
  - Prompting
  - Basic validations
  - Console formatting (headers, separators, success/errors)

---

### 📦 Phase 2: Database Management
- [x] `Create Database` — creates a new folder under `databases/`
- [x] `List Databases` — displays all database directories
- [x] `Drop Database` — deletes a database folder recursively
- [x] `Connect To Database` — validates and connects user to a DB for table operations
- [x] Validate names using `sanitize_input`
- [x] Ensure proper error messages for missing, invalid, or duplicate DBs

---

### 📂 Phase 3: Table Management
- [ ] Inside connected DB, provide:
  - `Create Table`
  - `List Tables`
  - `Drop Table`
- [ ] Use schema and metadata (column names, types, primary key)
- [ ] Store table data and structure in flat files

---

### 🧮 Phase 4: Data Manipulation
- [ ] `Insert Into Table`
- [ ] `Select From Table`
- [ ] `Update Table`
- [ ] `Delete From Table`
- [ ] Validate:
  - Data types (e.g. `int`, `string`)
  - Primary key uniqueness
  - Column existence and format

---

### 🛡️ Phase 5: Error Handling & Validation
- [ ] Apply detailed validation for:
  - Names
  - Data types
  - Primary key rules
- [ ] Graceful error handling using:
  - `error()` function
  - Standard error stream
  - Clear validation messages

---

### 🧱 Phase 6: Modularization & Testing
- [ ] Refactor logic into:
  - `scripts/` per module (db.sh, table.sh, record.sh)
  - `main.sh` as launcher
- [ ] Add basic **unit test scripts** under `tests/`
- [ ] Make utilities fully reusable

---

### 💡 Phase 7: Bonus Features (Optional)
- [ ] **SQL-like parser** for common commands
- [ ] **GUI Mode** using:
  - `zenity`
  - `whiptail`
  - `dialog`

---

## 📁 Folder Structure


