add_library(stub-freertos STATIC task.c)
target_include_directories(stub-freertos PUBLIC .)
add_library(stub::freertos ALIAS stub-freertos)
