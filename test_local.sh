#!/bin/bash
# Local test script - works on both Linux and macOS

set -e

echo "=== Local libSQL Test ==="

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    LIB_PATH="/usr/local/lib/liblibsql.so"
    NIMBLE_ARGS=""
elif [[ "$OSTYPE" == "darwin"* ]]; then
    LIB_PATH="$HOME/.local/lib/liblibsql.dylib"
    NIMBLE_ARGS="--passL:$HOME/.local/lib/liblibsql.dylib --passL:-Wl,-rpath,$HOME/.local/lib"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Check if liblibsql is installed
if [ ! -f "$LIB_PATH" ]; then
    echo -e "${RED}libSQL C library not found at $LIB_PATH${NC}"
    echo "Please build and install it first:"
    echo "  git clone https://github.com/tursodatabase/libsql-c.git /tmp/libsql-c"
    echo "  cd /tmp/libsql-c && cargo build --release"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "  sudo cp target/release/liblibsql.so /usr/local/lib/"
        echo "  sudo cp libsql.h /usr/local/include/"
        echo "  sudo ldconfig"
    else
        echo "  cp target/release/liblibsql.dylib ~/.local/lib/"
    fi
    exit 1
fi

echo "Found libSQL at: $LIB_PATH"
echo ""

# Setup library path for runtime
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
else
    export DYLD_LIBRARY_PATH=$HOME/.local/lib:$DYLD_LIBRARY_PATH
fi

echo "1. Running tests..."
if [ -n "$NIMBLE_ARGS" ]; then
    nimble test -- $NIMBLE_ARGS
else
    nimble test
fi

echo ""
echo "2. Building examples..."
if [ -n "$NIMBLE_ARGS" ]; then
    nim c $NIMBLE_ARGS -r examples/basic_example.nim
    nim c $NIMBLE_ARGS -r examples/memory_db_example.nim
else
    nimble example
fi

echo ""
echo -e "${GREEN}All tests passed!${NC}"
