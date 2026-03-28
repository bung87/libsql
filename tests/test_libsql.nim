import ../src/libsql
import std/[unittest, options]

suite "libSQL Basic Tests":
  var db: Database
  var conn: Connection

  setup:
    db = openDatabase(memoryDbConfig())
    conn = db.connect()

  teardown:
    conn.close()
    db.close()

  test "database creation":
    check db.handle.inner != nil

  test "table creation":
    discard conn.exec("CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)")

  test "insert and select":
    discard conn.exec("CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER)")
    var info = conn.exec("INSERT INTO test (name, value) VALUES (?, ?)", v("hello"), v(42))
    check info.rowsChanged == 1

    let rows = conn.query("SELECT * FROM test")
    check rows.len == 1
    check rows[0]["name"].getString == "hello"
    check rows[0]["value"].getInt == 42

  test "prepared statement":
    discard conn.exec("CREATE TABLE test (id INTEGER PRIMARY KEY, data TEXT)")

    var stmt = conn.prepare("INSERT INTO test (data) VALUES (?)")
    stmt.bindParam(v("first"))
    discard stmt.execute()

    stmt.reset()
    stmt.bindParam(v("second"))
    discard stmt.execute()
    stmt.finalize()

    let rows = conn.query("SELECT COUNT(*) as cnt FROM test")
    check rows[0]["cnt"].getInt == 2

  test "transaction commit":
    discard conn.exec("CREATE TABLE test (id INTEGER PRIMARY KEY, val TEXT)")

    var tx = conn.beginTransaction()
    var stmt = tx.prepare("INSERT INTO test (val) VALUES (?)")
    stmt.bindParam(v("committed"))
    discard stmt.execute()
    stmt.finalize()
    tx.commit()

    let rows = conn.query("SELECT * FROM test")
    check rows.len == 1
    check rows[0]["val"].getString == "committed"

  test "transaction rollback":
    discard conn.exec("CREATE TABLE test (id INTEGER PRIMARY KEY, val TEXT)")

    var tx = conn.beginTransaction()
    var stmt = tx.prepare("INSERT INTO test (val) VALUES (?)")
    stmt.bindParam(v("rolled back"))
    discard stmt.execute()
    stmt.finalize()
    tx.rollback()

    let rows = conn.query("SELECT * FROM test")
    check rows.len == 0

  test "value types":
    discard conn.exec("CREATE TABLE test (i INTEGER, r REAL, t TEXT, b BLOB)")

    let blobData = @[byte(0x01), byte(0x02), byte(0x03)]
    discard conn.exec(
      "INSERT INTO test VALUES (?, ?, ?, ?)",
      v(123),
      v(3.14),
      v("text"),
      v(blobData)
    )

    let rows = conn.query("SELECT * FROM test")
    check rows[0]["i"].getInt == 123
    check rows[0]["r"].getFloat == 3.14
    check rows[0]["t"].getString == "text"
    check rows[0]["b"].getBlob == blobData

  test "null values":
    discard conn.exec("CREATE TABLE test (id INTEGER PRIMARY KEY, maybe TEXT)")
    discard conn.exec("INSERT INTO test (maybe) VALUES (?)", nullVal())

    let rows = conn.query("SELECT * FROM test")
    check rows[0]["maybe"].isNull

  test "query one":
    discard conn.exec("CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)")
    discard conn.exec("INSERT INTO test (name) VALUES (?)", v("first"))
    discard conn.exec("INSERT INTO test (name) VALUES (?)", v("second"))

    let row = conn.getRow("SELECT * FROM test WHERE name = ?", v("first"))
    check row.isSome
    check row.get["name"].getString == "first"

    let noneRow = conn.getRow("SELECT * FROM test WHERE name = ?", v("nonexistent"))
    check noneRow.isNone

  test "column access by index":
    discard conn.exec("CREATE TABLE test (a TEXT, b TEXT, c TEXT)")
    discard conn.exec("INSERT INTO test VALUES (?, ?, ?)", v("x"), v("y"), v("z"))

    let rows = conn.query("SELECT * FROM test")
    check rows[0][0].getString == "x"
    check rows[0][1].getString == "y"
    check rows[0][2].getString == "z"

  test "row get with default":
    discard conn.exec("CREATE TABLE test (a TEXT)")
    discard conn.exec("INSERT INTO test VALUES (?)", v("value"))

    let rows = conn.query("SELECT * FROM test")
    check rows[0].get("a", v("default")).getString == "value"
    check rows[0].get("nonexistent", v("default")).getString == "default"

  test "multiple rows iteration":
    discard conn.exec("CREATE TABLE test (id INTEGER PRIMARY KEY, val INTEGER)")
    for i in 1..5:
      discard conn.exec("INSERT INTO test (val) VALUES (?)", v(i))

    let rows = conn.query("SELECT * FROM test ORDER BY val")
    check rows.len == 5
    for i, row in rows:
      check row["val"].getInt == int64(i + 1)

  test "connection info":
    discard conn.exec("CREATE TABLE test (id INTEGER PRIMARY KEY)")
    discard conn.exec("INSERT INTO test DEFAULT VALUES")

    let info = conn.getInfo()
    check info.totalChanges >= 1

suite "libSQL Value Tests":
  test "integer value":
    let v = v(42)
    check v.kind == vkInteger
    check v.getInt == 42

  test "float value":
    let v = v(3.14)
    check v.kind == vkReal
    check v.getFloat == 3.14

  test "text value":
    let v = v("hello")
    check v.kind == vkText
    check v.getString == "hello"

  test "blob value":
    let blob = @[byte(0x01), byte(0x02)]
    let v = v(blob)
    check v.kind == vkBlob
    check v.getBlob == blob

  test "null value":
    let v = nullVal()
    check v.kind == vkNull
    check v.isNull

  test "value to string":
    check $v(42) == "42"
    check $v("test") == "test"
    check $nullVal() == "NULL"
