##
## Remote Database Example
##
## This example demonstrates connecting to a remote libSQL database
## (e.g., Turso).
##
## Note: This example requires a valid Turso database URL and auth token.
## Set the TURSO_URL and TURSO_TOKEN environment variables before running.
##

import ../src/libsql
import std/[os, strutils]

proc main() =
  echo "=== Remote Database Example ==="
  echo ""

  # Get credentials from environment
  let url = getEnv("TURSO_URL", "")
  let token = getEnv("TURSO_TOKEN", "")

  if url == "" or token == "":
    echo "Please set TURSO_URL and TURSO_TOKEN environment variables"
    echo ""
    echo "Example:"
    echo "  export TURSO_URL=libsql://your-database.turso.io"
    echo "  export TURSO_TOKEN=your-auth-token"
    return

  echo "1. Connecting to remote database..."
  var config = remoteDbConfig(url, token)
  var db = openDatabase(config)
  echo "   Connected to remote database"

  var conn = db.connect()

  # Create a table
  echo "2. Creating table..."
  try:
    discard conn.exec("""
      CREATE TABLE IF NOT EXISTS remote_test (
        id INTEGER PRIMARY KEY,
        message TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    """)
    echo "   Table created"
  except LibSqlError as e:
    echo "   Note: ", e.msg

  # Insert data
  echo "3. Inserting data..."
  let info = conn.exec(
    "INSERT INTO remote_test (message) VALUES (?)",
    v("Hello from Nim!")
  )
  echo "   Inserted row with id: ", info.lastInsertRowid

  # Query data
  echo "4. Querying data..."
  let rows = conn.query("SELECT * FROM remote_test ORDER BY id DESC LIMIT 5")
  for row in rows:
    echo "   Message: ", row["message"].getString
    echo "   Created at: ", row["created_at"].getString
    echo ""

  # Sync (for embedded replicas)
  echo "5. Syncing with primary..."
  db.sync()
  echo "   Synced"

  # Clean up
  conn.close()
  db.close()

  echo "=== Remote Example completed ==="

when isMainModule:
  main()
