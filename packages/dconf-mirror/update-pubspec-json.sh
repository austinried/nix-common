#!/usr/bin/env bash
set -euo pipefail

DIR=$(dirname "$0")

yq eval \
  --output-format=json \
  --prettyPrint \
  "$DIR/pubspec.lock" > "$DIR/pubspec.lock.json"
