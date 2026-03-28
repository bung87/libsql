# libSQL Nim Binding

[![Test](https://github.com/bung87/libsql/actions/workflows/test.yml/badge.svg)](https://github.com/bung87/libsql/actions/workflows/test.yml)
[![Nim](https://img.shields.io/badge/nim-%3E%3D2.0.0-orange.svg)](https://nim-lang.org)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

A Nim binding for [libSQL](https://github.com/tursodatabase/libsql) - an open source, open contribution fork of SQLite.

This library provides both low-level FFI bindings and a high-level, idiomatic Nim API for working with libSQL databases.

## Features

- **Local SQLite databases**: Work with local `.db` files
- **In-memory databases**: Fast, ephemeral databases for testing
- **Remote databases**: Connect to Turso or other libSQL servers
- **Transactions**: ACID transactions with automatic rollback on errors
- **Prepared statements**: Efficient parameterized queries
- **Type-safe values**: Nim-native type system for database values
- **Iterator support**: Iterate over query results naturally

## Installation

### Prerequisites

1. Install the libSQL C library:

```bash
# macOS (using Homebrew)
brew install libsql

# Linux - build from source
git clone https://github.com/tursodatabase/libsql-c.git
cd libsql-c
cargo build --release
# Copy the resulting library to your system library path
```

2. Add this package to your Nim project:

```bash
nimble install libsql
```

Or add to your `.nimble` file:

```nim
requires "libsql >= 0.1.0"
```

## Quick Start

```nim
import libsql

# Open a local database
var db = openDatabase(defaultDbConfig("mydb.db"))
var conn = db.connect()

# Create a table
conn.exec("""
  CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT
  )
""")

# Insert data with parameters
discard conn.exec(
  "INSERT INTO users (name, email) VALUES (?, ?)",
  v("Alice"),
  v("alice@example.com")
)

# Query data
let users = conn.query("SELECT * FROM users")
for user in users:
  echo "User: ", user["name"].getString
  echo "Email: ", user["email"].getString

# Clean up
conn.close()
db.close()
```

## API Overview

### Database Types

| Type | Description |
|------|-------------|
| `Database` | Database handle |
| `Connection` | Connection to a database |
| `Transaction` | ACID transaction |
| `Statement` | Prepared SQL statement |
| `Row` | A single result row |
| `Rows` | Collection of result rows |
| `Value` | Typed database value |

### Opening Databases

```nim
# Local database
var db = openDatabase(defaultDbConfig("path/to/db.db"))

# In-memory database
var db = openDatabase(memoryDbConfig())

# Remote database (Turso)
var db = openDatabase(remoteDbConfig(
  "libsql://your-db.turso.io",
  "your-auth-token"
))
```

### Executing Queries

```nim
# Simple execution
conn.exec("CREATE TABLE test (id INTEGER)")

# With parameters
discard conn.exec("INSERT INTO test VALUES (?)", v(42))

# Get execution info
let info = conn.exec("INSERT INTO test VALUES (?)", v(123))
echo "Rows changed: ", info.rowsChanged
echo "Last insert ID: ", info.lastInsertRowid
```

### Querying Data

```nim
# Get all rows
let rows = conn.query("SELECT * FROM users WHERE age > ?", v(18))
for row in rows:
  echo row["name"].getString

# Get first row only
let user = conn.getRow("SELECT * FROM users WHERE id = ?", v(1))
if user.isSome:
  echo user.get["name"].getString
```

### Transactions

```nim
var tx = conn.beginTransaction()
try:
  var stmt = tx.prepare("INSERT INTO accounts (balance) VALUES (?)")
  stmt.bindParam(v(100))
  discard stmt.execute()
  stmt.finalize()
  
  stmt = tx.prepare("UPDATE accounts SET balance = balance - ? WHERE id = ?")
  stmt.bindParam(v(50))
  stmt.bindParam(v(1))
  discard stmt.execute()
  stmt.finalize()
  
  tx.commit()
except LibSqlError:
  tx.rollback()
  raise
```

### Prepared Statements

```nim
var stmt = conn.prepare("INSERT INTO users (name) VALUES (?)")

for name in ["Alice", "Bob", "Charlie"]:
  stmt.reset()
  stmt.bindParam(v(name))
  discard stmt.execute()

stmt.finalize()
```

### Working with Values

```nim
# Create values
let intVal = v(42)           # Integer
let floatVal = v(3.14)       # Float
let strVal = v("hello")      # String
let blobVal = v(@[byte(0x01), byte(0x02)])  # Blob
let nullVal = nullVal()      # NULL

# Access values
let age = row["age"].getInt
let price = row["price"].getFloat
let name = row["name"].getString
let data = row["data"].getBlob

# Check for NULL
if row["optional"].isNull:
  echo "Value is NULL"
```

## Examples

See the `examples/` directory for complete examples:

- `basic_example.nim` - Basic CRUD operations
- `memory_db_example.nim` - In-memory database usage
- `remote_db_example.nim` - Connecting to remote Turso databases

Run examples:

```bash
nimble example
```

## Running Tests

```bash
nimble test
```

## Error Handling

All database operations raise `LibSqlError` on failure:

```nim
try:
  conn.exec("INVALID SQL")
except LibSqlError as e:
  echo "Database error: ", e.msg
```

## License

MIT License - See LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## Resources

- [libSQL GitHub](https://github.com/tursodatabase/libsql)
- [Turso Documentation](https://docs.turso.tech/)
- [libSQL C Bindings](https://github.com/tursodatabase/libsql-c)
