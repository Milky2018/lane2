#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

timeout_cmd=()
if command -v timeout >/dev/null 2>&1; then
  timeout_cmd=(timeout 15s)
elif command -v gtimeout >/dev/null 2>&1; then
  timeout_cmd=(gtimeout 15s)
else
  echo "warning: timeout/gtimeout not found; running smoke checks without timeout" >&2
fi

run_lane() {
  local file="$1"
  local entry="$2"
  "${timeout_cmd[@]}" moon run lane-tools/lane -- run "$file" --entry "$entry" --stdlib lane-std
}

expect_exact() {
  local file="$1"
  local entry="$2"
  local expected="$3"
  local output
  output="$(run_lane "$file" "$entry" 2>&1)"
  if [[ "$output" != "$expected" ]]; then
    echo "unexpected output for $file --entry $entry" >&2
    echo "expected: $expected" >&2
    echo "actual: $output" >&2
    exit 1
  fi
}

expect_contains() {
  local file="$1"
  local entry="$2"
  local expected="$3"
  local output
  output="$(run_lane "$file" "$entry" 2>&1)"
  if [[ "$output" != *"$expected"* ]]; then
    echo "missing output fragment for $file --entry $entry" >&2
    echo "expected fragment: $expected" >&2
    echo "actual: $output" >&2
    exit 1
  fi
}

expect_failure_contains() {
  local file="$1"
  local entry="$2"
  local expected="$3"
  local output
  if output="$(run_lane "$file" "$entry" 2>&1)"; then
    echo "expected lane run to fail for $file --entry $entry" >&2
    echo "actual success output: $output" >&2
    exit 1
  fi
  if [[ "$output" != *"$expected"* ]]; then
    echo "missing failure output fragment for $file --entry $entry" >&2
    echo "expected fragment: $expected" >&2
    echo "actual: $output" >&2
    exit 1
  fi
}

expect_exact \
  "spec/examples/valid/01_top_level_forward_function_value.lane" \
  "answer" \
  "42 : Int"

expect_exact \
  "spec/examples/valid/05_top_level_contextual_offer.lane" \
  "chosen" \
  "1 : Int"

expect_contains \
  "spec/examples/valid/02_struct_enum_match.lane" \
  "origin" \
  " : type#"

expect_contains \
  "spec/examples/valid/02_struct_enum_match.lane" \
  "chosen" \
  "type#"

expect_contains \
  "spec/examples/valid/10_nominal_types.lane" \
  "user_id" \
  " : type#"

expect_exact \
  "spec/examples/valid/11_function_types.lane" \
  "id_int" \
  "<function> : (Int) -> Int"

expect_contains \
  "spec/examples/valid/08_struct_forwarding.lane" \
  "meter_equal_ops" \
  "<function>"

expect_contains \
  "spec/examples/valid/07_builtin_expected_type.lane" \
  "host_value" \
  "external_value"

expect_contains \
  "spec/examples/valid/07_builtin_expected_type.lane" \
  "host_value" \
  " : Int"
