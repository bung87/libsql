#!/bin/bash
# Local test script - simulates CI workflow

set -e

echo "=== Local libSQL Test ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if liblibsql is installed
if [ ! -f "$HOME/.local/lib/liblibsql.dylib" ] && [ ! -f "/usr/local/lib/liblibsql.so" ]; then
    echo -e "${RED}libSQL C library not found!${NC}"
    echo "Please build and install it first:"
    echo "  git clone https://github.com/tursodatabase/libsql-c.git /tmp/libsql-c"
    echo "  cd /tmp/libsql-c && cargo build --release"
    echo "  cp target/release/liblibsql.so ~/.local/lib/  # Linux"
    echo "  cp target/release/liblibsql.dylib ~/.local/lib/  # macOS"
    exit 1
fi

echo "1. Running tests..."
nimble test

echo ""
echo "2. Building examples..."
nimble example

echo ""
echo -e "${GREEN}All tests passed!${NC}"
