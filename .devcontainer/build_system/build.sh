#!/usr/bin/env bash

# Enable debugging
set -euo pipefail

#determine the current script directory
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
#determine the target from the script name
TARGET=$(echo $0 | cut -s -f2 -d- | cut -s -f1 -d.)
echo "TARGET = $TARGET"

${SCRIPT_DIR}/build-impl.sh ${TARGET}
