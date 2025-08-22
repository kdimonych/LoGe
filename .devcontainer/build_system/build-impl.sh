#!/usr/bin/env bash

set -euo pipefail
PARAM=""

# Retrieve the target from the current filename, if no target specified,
# the variable will be empty
TARGET=$1
if [[ -n $TARGET ]]
then
    # Target is not null, specify the build parameters
    echo "Building for target: $TARGET"
    PARAM="-DCMAKE_TOOLCHAIN_FILE=$IDF_PATH/tools/cmake/toolchain-${TARGET}.cmake -DTARGET=${TARGET} -GNinja"
fi

BUILD_DIR=build_gcc_$TARGET

rm -rf $BUILD_DIR && mkdir $BUILD_DIR && cd $BUILD_DIR
cmake .. $PARAM
cmake --build .
