#!/bin/bash
BUILD_DIR=$1

# If second argument provided
if [ -n "$2" ]; then
  # force using its value
  HOST_WORKSPACE_PATH=$2
fi

# Check environment variable HOST_WORKSPACE_PATH
if [ -z "${HOST_WORKSPACE_PATH}" ]; then
  # if not set require the second argument
  HOST_WORKSPACE_PATH=$2
fi

show_help(){
  echo "Usage: $0 <BUILD_DIR> [<HOST_WORKSPACE_PATH>]"
  echo "     <BUILD_DIR>         The build directory"
  echo " optionals:"
  echo "     <HOST_WORKSPACE_PATH>  The build directory relative to the host file system."
  echo "                            This value will be used to substitute the for openocd commands."
  echo " environment variables:"
  echo "     HOST_WORKSPACE_PATH    The build directory relative to the host file system."
  echo "                            This value will be used to substitute the for openocd commands "
  echo "                            only if second argument <HOST_WORKSPACE_PATH> is not provided."
}

# If help requested
if [ "$1" == "--help" ]; then
  show_help
  exit 0
fi

# If no BUILD_DIR is specified, show error and help page
if [ -z "${BUILD_DIR}" ]; then
  echo "Error: BUILD_DIR is not specified."
  show_help
  exit 1
fi

# If no HOST_WORKSPACE_PATH is specified, show error and help page
if [ -z "${HOST_WORKSPACE_PATH}" ]; then
  echo "Error: HOST_WORKSPACE_PATH is not specified."
  show_help
  exit 1
fi

#determine the current script directory
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

PROJECT_PATH=${SCRIPT_DIR}/../../..
PROJECT_PATH="/$(realpath --relative-to="/" "${PROJECT_PATH}")"

echo "PROJECT_PATH=${PROJECT_PATH}"
echo "BUILD_DIR=${BUILD_DIR}"

# Determine the build directory path relative to workspace path
BUILD_DIR_WORKSPACE=$(realpath --relative-to="${PROJECT_PATH}" "${BUILD_DIR}")
echo "BUILD_DIR_WORKSPACE=${BUILD_DIR_WORKSPACE}"

FLASH_CMD_LIST=$(${SCRIPT_DIR}/flash_list.py ${BUILD_DIR}/flasher_args.json)

# Generate the program_esp commands
CMDS=""
while IFS=: read -r addr file; do
    CMDS+="program_esp ${HOST_WORKSPACE_PATH}/${BUILD_DIR_WORKSPACE}/${file} ${addr} verify"$'\n'
done <<< "$FLASH_CMD_LIST"

# Add reset commands
CMDS="reset halt"$'\n'"${CMDS}reset run"$'\n'"exit"$'\n'
echo "CMDS=${CMDS}"

# Send commands to telnet
${SCRIPT_DIR}/telnet_exec.exp host.docker.internal 4444 "$CMDS"
