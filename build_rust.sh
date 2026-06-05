#!/bin/bash
# Build vLLM Rust artifacts and install them into the vllm package.
# Usage: ./build_rust.sh [--debug]
#
# By default builds in release mode. Pass --debug for faster compile times
# during development.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
RUST_DIR="$REPO_ROOT/rust"
TARGET_PATH="${VLLM_RS_TARGET_PATH:-$REPO_ROOT/vllm/vllm-rs}"
RUST_EXTENSION_TARGET_DIR="${VLLM_RUST_EXTENSION_TARGET_DIR:-$REPO_ROOT/vllm}"
RUST_EXTENSION_PY_LIMITED_API="${VLLM_RUST_EXTENSION_PY_LIMITED_API:-cp38}"
RUST_EXTENSION_ABI3_FEATURE="pyo3/abi3-py${RUST_EXTENSION_PY_LIMITED_API#cp}"

# Read the required toolchain from rust-toolchain.toml.
TOOLCHAIN=$(grep '^channel' "$REPO_ROOT/rust-toolchain.toml" | sed 's/.*= *"\(.*\)"/\1/')

# Ensure rustup and the required toolchain are available.
if ! command -v rustup &>/dev/null; then
    echo "rustup not found, installing..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none
    source "$HOME/.cargo/env"
fi

if ! rustup run "$TOOLCHAIN" rustc --version &>/dev/null; then
    echo "Installing Rust toolchain: $TOOLCHAIN"
    rustup toolchain install "$TOOLCHAIN"
fi

if [[ "${1:-}" == "--debug" ]]; then
    PROFILE_ARGS=()
    PROFILE_DIR="debug"
else
    PROFILE_ARGS=(--release)
    PROFILE_DIR="release"
fi

cargo +"$TOOLCHAIN" build "${PROFILE_ARGS[@]}" \
    --manifest-path "$RUST_DIR/Cargo.toml" \
    --bin vllm-rs \
    --features native-tls-vendored

mkdir -p "$(dirname "$TARGET_PATH")"
cp "$RUST_DIR/target/$PROFILE_DIR/vllm-rs" "$TARGET_PATH"
echo "Installed vllm-rs to $TARGET_PATH"

cargo +"$TOOLCHAIN" build "${PROFILE_ARGS[@]}" \
    --manifest-path "$RUST_DIR/Cargo.toml" \
    -p vllm-tool-parser-py \
    --features "pyo3/extension-module $RUST_EXTENSION_ABI3_FEATURE"

mkdir -p "$RUST_EXTENSION_TARGET_DIR"
cp "$RUST_DIR/target/$PROFILE_DIR/lib_rust_tool_parser.so" \
    "$RUST_EXTENSION_TARGET_DIR/_rust_tool_parser.abi3.so"
echo "Installed _rust_tool_parser to $RUST_EXTENSION_TARGET_DIR/_rust_tool_parser.abi3.so"
