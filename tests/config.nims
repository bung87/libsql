switch("path", "$projectDir/../src")

when defined(linux):
  # Use system library path on Linux
  switch("passL", "-L/usr/local/lib -lliblibsql")
  switch("passL", "-Wl,-rpath,/usr/local/lib")
elif defined(macosx):
  # macOS: use home directory
  let home = getEnv("HOME")
  switch("passL", home & "/.local/lib/liblibsql.dylib")
  switch("passL", "-Wl,-rpath," & home & "/.local/lib")
