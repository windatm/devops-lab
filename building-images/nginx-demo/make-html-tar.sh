#!/bin/bash
# Script to create html.tar.gz from files/html/ directory
# This ensures the tar contains index.html at root level (not nested in html/ subdirectory)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HTML_DIR="${SCRIPT_DIR}/files/html"
TARBALL="${SCRIPT_DIR}/files/html.tar.gz"

if [ ! -d "${HTML_DIR}" ]; then
    echo "Error: ${HTML_DIR} does not exist"
    exit 1
fi

cd "${HTML_DIR}"

# Create tar.gz with files at root level (no html/ prefix)
# -C changes to the directory, so files are added without the directory name
tar -czf "${TARBALL}" index.html

echo "Created ${TARBALL}"
echo "Verifying contents:"
tar -tzf "${TARBALL}"

