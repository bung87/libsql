# Package
version       = "0.1.0"
author        = "Nim libSQL Contributors"
description   = "Nim binding for libSQL - an open source, open contribution fork of SQLite"
license       = "MIT"
srcDir        = "src"

# Dependencies
requires "nim >= 2.0.0"

# Install files
installDirs   = @["src"]
installFiles  = @[]

# Helper variable for library path
let libPath = getEnv("HOME") & "/.local/lib"

# Tasks
task example, "Run basic example":
  exec "nim c --passL:" & libPath & "/liblibsql.dylib --passL:-Wl,-rpath," & libPath & " -r examples/basic_example.nim"

task example_memory, "Run memory db example":
  exec "nim c --passL:" & libPath & "/liblibsql.dylib --passL:-Wl,-rpath," & libPath & " -r examples/memory_db_example.nim"

task example_remote, "Run remote db example":
  exec "nim c --passL:" & libPath & "/liblibsql.dylib --passL:-Wl,-rpath," & libPath & " -r examples/remote_db_example.nim"
