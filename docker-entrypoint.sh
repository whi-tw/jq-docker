#!/usr/bin/env bash
set -euo pipefail


if which ${1:-} &> /dev/null; then
    exec "${@}"
else
    exec /usr/bin/jq "${@:-}"
fi
