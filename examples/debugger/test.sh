#! /usr/bin/env bash

set -eEo pipefail

# Grab the location of this file to use as the base for our paths
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

source "${HERE}/logger.sh"
source "${HERE}/debugger.sh"
source "${HERE}/test/foobar.sh"

# Setup debug information
# shellcheck disable=SC2034
debug_main_file="${HERE}/test.sh"
debug_register_file "${HERE}/test/*.sh"

debug_setup_trap

foobar
