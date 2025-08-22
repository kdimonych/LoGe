#!/usr/bin/env python3

import json
import sys

flash_file_path = sys.argv[1]

with open(flash_file_path) as f:
    data = json.load(f)

# Get the flash_files dictionary and sort by address (as int)
flash_files = data.get("flash_files", {})
sorted_items = sorted(flash_files.items(), key=lambda x: int(x[0], 16))

# Print as space-separated address:filename pairs, suitable for bash
for addr, fname in sorted_items:
    print(f"{addr}:{fname}")
