add_library(stub-spi-flash STATIC flash_ops.c)
target_include_directories(stub-spi-flash PUBLIC .)
add_library(stub::spi_flash ALIAS stub-spi-flash)
target_link_libraries(stub-spi-flash PUBLIC stub-esp32)
