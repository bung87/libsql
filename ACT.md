# Local GitHub Actions Testing with `act`

## Installation

### macOS
```bash
brew install act
```

### Linux
```bash
curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
```

### Docker Image (for local testing)
```bash
docker pull ghcr.io/catthehacker/ubuntu:act-latest
```

## Usage

### Basic - Run default workflow
```bash
cd /Users/bung/nim-works/libsql
act
```

### Run specific job
```bash
act -j test
```

### Dry run (see what would be executed)
```bash
act -n
```

### Verbose output
```bash
act -v
```

### Use specific image
```bash
act -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest
```

## Our Workflow

To test the libSQL binding workflow locally:

```bash
# Full workflow test (requires Docker)
act -j test

# With specific image (recommended for compatibility)
act -P ubuntu-latest=ghcr.io/catthehacker/ubuntu:act-latest -j test
```

## Notes

- Local testing may not have all GitHub-hosted runner features
- Some actions (like caching) may behave differently
- The libSQL C library will be built from source in the container
- Tests run in isolation from your host system

## Alternative: Manual Testing

Since `act` requires Docker, you can also test locally with:

```bash
# Install libSQL C library locally
# (follow steps in .github/workflows/test.yml)

# Run tests directly
nimble test

# Run examples
nimble example
```
