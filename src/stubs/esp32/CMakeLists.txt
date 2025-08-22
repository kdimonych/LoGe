add_library(stub-esp32 STATIC system_api.c cpu_start.c)
target_include_directories(stub-esp32 PUBLIC .)
add_library(stub::esp32 ALIAS stub-esp32)
