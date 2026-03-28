##
## In-Memory Database Example
##
## This example demonstrates using an in-memory libSQL database.
##

import ../src/libsql

proc main() =
  echo "=== In-Memory Database Example ==="
  echo ""

  # Create an in-memory database
  echo "1. Creating in-memory database..."
  var config = memoryDbConfig()
  var db = openDatabase(config)
  echo "   In-memory database created"

  var conn = db.connect()
  echo "   Connected to in-memory database"

  # Create tables and insert data
  echo "2. Creating tables..."
  discard conn.exec("""
    CREATE TABLE products (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      price REAL NOT NULL
    )
  """)

  echo "3. Inserting products..."
  discard conn.exec("INSERT INTO products VALUES (?, ?, ?)", v(1), v("Laptop"), v(999.99))
  discard conn.exec("INSERT INTO products VALUES (?, ?, ?)", v(2), v("Mouse"), v(29.99))
  discard conn.exec("INSERT INTO products VALUES (?, ?, ?)", v(3), v("Keyboard"), v(79.99))

  echo "4. Querying products..."
  let products = conn.query("SELECT * FROM products")
  var totalValue = 0.0
  for product in products:
    let name = product["name"].getString
    let price = product["price"].getFloat
    echo "   ", name, ": $", price
    totalValue += price

  echo ""
  echo "   Total products value: $", totalValue

  # Clean up
  conn.close()
  db.close()

  echo ""
  echo "=== In-memory data is automatically discarded ==="

when isMainModule:
  main()
