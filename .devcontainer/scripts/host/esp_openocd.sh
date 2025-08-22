#!/usr/bin/env bash

# Determine if port is held by a process and return PID of holder process
get_port_holder_pid()
{
    local pid=$(lsof -ti :6666)
    echo $pid
}

# Kill process holding port
kill_port_holder()
{
    local pid=$1
    if [ -n "$pid" ]; then
        # Determine if process is owned by current user
        local owner=$(ps -o user= -p "$pid")
        if [ "$owner" != "$USER" ]; then
            # if not, use sudo to kill the process
            sudo kill -9 $pid
        else
            # if owned by current user, kill without sudo
            kill -9 $pid
        fi
    fi
}

release_port()
{
  local port=$1
  local pid=$(get_port_holder_pid $port)

  if [ -n "$pid" ]; then
      # Obtain process info
      local process_info=$(ps -p $pid -o user,pid,comm,args)
      echo "[WARNING] The port $port is held by process $pid: ($process_info)"
      echo "[WARNING] Kill the process..."
      kill_port_holder $pid

      if [ -n "$(get_port_holder_pid $port)" ]; then
          echo "[ERROR] Failed to release port $port, please check manually."
          exit 1
      else
          echo "[INFO] Port $port has been released successfully."
      fi
  else
      echo "[INFO] No process is holding port $port."
  fi
}

# Check if IDF_PATH is specified
if [ -n "${IDF_PATH}" ]; then
    echo "[INFO] IDF_PATH is set to: ${IDF_PATH}"
else
    echo "[ERROR] IDF_PATH is not set."
    echo "[ERROR] Please, set the IDF_PATH environment variable to point to your ESP-IDF installation."
    exit 1
fi

if command -v idf.py >/dev/null 2>&1; then
    echo "[INFO] ESP-IDF is active in this shell."
else
    echo "[INFO] ESP-IDF is NOT active in this shell. Activate..."
    # Source the ESP_IDF environment
    if [ -f "${IDF_PATH}/export.sh" ]; then
        # Source the ESP-IDF environment
        source "${IDF_PATH}/export.sh"
    else
        echo "[ERROR] ESP-IDF environment file not found at ${IDF_PATH}/export.sh"
        echo "[ERROR] Please, set the IDF_PATH environment variable to point to correct ESP-IDF installation."
        exit 1
    fi
fi

release_port 3333
release_port 4444
release_port 6666

openocd "$@"
