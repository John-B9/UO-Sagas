#!/bin/bash
#
# Lua Standalone Script Generator (Bash Wrapper)
#
# This script provides a convenient bash wrapper around the Python script
# that recursively resolves Lua imports and generates standalone versions.
#
# Usage:
#     ./make_standalone.sh <input_lua_file>
#     ./make_standalone.sh <input_lua_file> <base_dir>
#
# Example:
#     ./make_standalone.sh ../IUIDWand.lua
#     # Creates: ../IUIDWand_STANDALONE.lua

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Use Python script to generate standalone
python3 "$SCRIPT_DIR/make_standalone.py" "$@"
