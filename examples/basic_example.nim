##
## Basic libSQL Example
##
## This example demonstrates the basic usage of the libSQL Nim binding.
##

import ../src/libsql
import std/[strutils, os]

proc main() =
  echo "=== libSQL Nim Binding Example ==="
  echo ""

  # Create a local database
  echo "1. Creating local database..."
  var config = defaultDbConfig("example.db")
  echo "   Config path: ", config.path
  var db = openDatabase(config)
  echo "   Database opened successfully"

  # Connect to the database
  echo "2. Connecting to database..."
  var conn = db.connect()
  echo "   Connected successfully"

  # Create a table
  echo "3. Creating table..."
  discard conn.exec("""
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE,
      age INTEGER,
      active BOOLEAN DEFAULT TRUE
    )
  """)
  echo "   Table created successfully"

  # Insert data using prepared statements
  echo "4. Inserting data..."
  var info = conn.exec(
    "INSERT INTO users (name, email, age) VALUES (?, ?, ?)",
    v("Alice"),
    v("alice@example.com"),
    v(30)
  )
  echo "   Inserted Alice, last insert rowid: ", info.lastInsertRowid

  info = conn.exec(
    "INSERT INTO users (name, email, age) VALUES (?, ?, ?)",
    v("Bob"),
    v("bob@example.com"),
    v(25)
  )
  echo "   Inserted Bob, last insert rowid: ", info.lastInsertRowid

  info = conn.exec(
    "INSERT INTO users (name, email, age) VALUES (?, ?, ?)",
    v("Charlie"),
    v("charlie@example.com"),
    v(35)
  )
  echo "   Inserted Charlie, last insert rowid: ", info.lastInsertRowid

  # Query data
  echo "5. Querying all users..."
  let allUsers = conn.query("SELECT * FROM users")
  for user in allUsers:
    echo "   User: id=", user["id"].getInt,
         ", name=", user["name"].getString,
         ", email=", user["email"].getString,
         ", age=", user["age"].getInt

  # Query with parameters
  echo "6. Querying users over 28..."
  let olderUsers = conn.query("SELECT * FROM users WHERE age > ?", v(28))
  for user in olderUsers:
    echo "   User: ", user["name"].getString, " (age: ", user["age"].getInt, ")"

  # Transaction example
  echo "7. Transaction example..."
  var tx = conn.beginTransaction()
  try:
    var stmt = tx.prepare("INSERT INTO users (name, email, age) VALUES (?, ?, ?)")
    stmt.bindParam(v("David"))
    stmt.bindParam(v("david@example.com"))
    stmt.bindParam(v(40))
    discard stmt.execute()
    stmt.finalize()
    
    stmt = tx.prepare("UPDATE users SET age = ? WHERE name = ?")
    stmt.bindParam(v(31))
    stmt.bindParam(v("Alice"))
    discard stmt.execute()
    stmt.finalize()
    
    tx.commit()
    echo "   Transaction committed successfully"
  except LibSqlError:
    tx.rollback()
    echo "   Transaction rolled back due to error: ", getCurrentExceptionMsg()

  # Query after transaction
  echo "8. Querying all users after transaction..."
  let finalUsers = conn.query("SELECT * FROM users ORDER BY id")
  for user in finalUsers:
    echo "   User: ", user["name"].getString, ", age: ", user["age"].getInt

  # Using prepared statements directly
  echo "9. Using prepared statements..."
  var stmt = conn.prepare("SELECT * FROM users WHERE name LIKE ?")
  stmt.bindParam(v("A%"))
  var rows = stmt.query()
  for row in rows:
    echo "   Found user starting with 'A': ", row["name"].getString
  rows.close()
  stmt.finalize()

  # Get connection info
  echo "10. Connection info..."
  let connInfo = conn.getInfo()
  echo "    Total changes: ", connInfo.totalChanges

  # Clean up
  echo "11. Cleaning up..."
  conn.close()
  db.close()

  # Remove database file
  removeFile("example.db")
  echo "    Done!"

  echo ""
  echo "=== Example completed successfully ==="

when isMainModule:
  main()
