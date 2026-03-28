switch("path", "$projectDir/../src")

when defined(linux):
  switch("passL", "/usr/local/lib/liblibsql.so")
  switch("passL", "-Wl,-rpath,/usr/local/lib")
elif defined(macosx):
  let home = getEnv("HOME")
  switch("passL", home & "/.local/lib/liblibsql.dylib")
  switch("passL", "-Wl,-rpath," & home & "/.local/lib")
