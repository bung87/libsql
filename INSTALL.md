# libSQL Nim Binding - Installation Guide

## Prerequisites

This Nim binding requires the libSQL C library (`liblibsql.so` on Linux, `liblibsql.dylib` on macOS, or `liblibsql.dll` on Windows).

## Installing libSQL C Library

### Option 1: Build from Source (Recommended)

1. Clone the libSQL C bindings repository:

```bash
git clone https://github.com/tursodatabase/libsql-c.git
cd libsql-c
```

2. Build the library (requires Rust toolchain):

```bash
cargo build --release
```

3. Install the library:

**Linux:**
```bash
sudo cp target/release/liblibsql.so /usr/local/lib/
sudo cp libsql.h /usr/local/include/
sudo ldconfig
```

**macOS:**
```bash
cp target/release/liblibsql.dylib /usr/local/lib/
cp libsql.h /usr/local/include/
```

**Windows:**
Copy `target\release\liblibsql.dll` to your system PATH or executable directory.

### Option 2: Using Homebrew (macOS/Linux)

If a Homebrew formula is available:

```bash
brew install libsql
```

### Option 3: Pre-built Binaries

Download pre-built binaries from the [libsql-c releases page](https://github.com/tursodatabase/libsql-c/releases) if available.

## Installing the Nim Binding

### Using Nimble (Local)

```bash
cd libsql
nimble install
```

### Using Nimble (From Git)

```bash
nimble install https://github.com/yourusername/libsql-nim
```

### Manual Installation

Copy the `src/libsql.nim` file to your project or Nim path.

## Verifying Installation

1. Run the examples:

```bash
nimble example
nimble example_memory
```

2. Run the tests:

```bash
nimble test
```

## Troubleshooting

### Library Not Found

If you get "could not load: liblibsql.so" error:

**Linux:**
```bash
export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
```

**macOS:**
```bash
export DYLD_LIBRARY_PATH=/usr/local/lib:$DYLD_LIBRARY_PATH
```

**Windows:**
Add the directory containing `liblibsql.dll` to your PATH environment variable.

### Linking Errors

If you see linking errors, you may need to specify the library path:

```bash
nim c --passL:"-L/path/to/libsql/lib" your_program.nim
```

Or on macOS/Linux with custom install location:

```bash
nim c --passL:"-L/opt/homebrew/lib" --passL:"-lliblibsql" your_program.nim
```

### Runtime Library Path

To set the runtime library search path (Linux/macOS):

```bash
nim c --passL:"-Wl,-rpath,/usr/local/lib" your_program.nim
```

## Platform-Specific Notes

### macOS

If you installed liblibsql.dylib to a non-standard location, you may need to:

1. Sign the library (if using a custom build):
```bash
codesign -s - /usr/local/lib/liblibsql.dylib
```

2. Or disable library validation for your executable (development only):
```bash
codesign -s - --force --options runtime --entitlements entitlements.plist your_executable
```

### Linux

Ensure the library is in your system's library cache:

```bash
echo "/usr/local/lib" | sudo tee /etc/ld.so.conf.d/libsql.conf
sudo ldconfig
```

### Windows

Place `liblibsql.dll` in the same directory as your executable, or in a directory listed in your PATH.

## Development Setup

For development, you may want to set up a local environment:

```bash
# Clone the repository
git clone https://github.com/yourusername/libsql-nim.git
cd libsql-nim

# Link for local development
nimble develop

# Run tests
nimble test

# Run examples
nimble example
```

## Getting Help

- libSQL Documentation: https://docs.turso.tech/
- libSQL C Bindings: https://github.com/tursodatabase/libsql-c
- Nim Documentation: https://nim-lang.org/documentation.html
- Report issues: https://github.com/yourusername/libsql-nim/issues
