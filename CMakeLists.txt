cmake_minimum_required(VERSION 3.16)

project(LoGe)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF) # Disable compiler-specific extensions

set(TARGETS
    "esp32"
    "esp32s2"
    "esp32s3"
    "esp32c3"
    "esp32c2"
    "esp32c6"
    "esp32h2"
    "esp32p4")

if("${TARGET}" IN_LIST TARGETS)
  # Include for ESP-IDF build system functions
  include($ENV{IDF_PATH}/tools/cmake/idf.cmake)
  # Create idf::{target} and idf::freertos static libraries
  idf_build_process(
    "${TARGET}"
    # try and trim the build; additional components will be included as needed
    # based on dependency tree
    #
    # although esptool_py does not generate static library, processing the
    # component is needed for flashing related targets and file generation
    COMPONENTS
    freertos
    esptool_py
    SDKCONFIG
    ${CMAKE_CURRENT_LIST_DIR}/sdkconfig
    BUILD_DIR
    ${CMAKE_BINARY_DIR})
else()
  message(WARNING "Unknown target ${TARGET}, creating stubs for esp32 instead")
  # Create stubs for esp32 and freertos, stub::esp32 and stub::freertos
  add_subdirectory(src/stubs/esp32)
  add_subdirectory(src/stubs/freertos)
  add_subdirectory(src/stubs/spi_flash)
endif()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(ELF_FILES ${CMAKE_PROJECT_NAME}.elf)
add_executable(${ELF_FILES} src/main.cpp)

# Link the static libraries to the executable
if("${TARGET}" IN_LIST TARGETS)
  target_link_libraries(${ELF_FILES} idf::freertos idf::spi_flash)
  # Attach additional targets to the executable file for flashing, linker script
  # generation, partition_table generation, etc.
  idf_build_executable(${ELF_FILES})
else()
  target_link_libraries(${ELF_FILES} stub::esp32 stub::freertos stub::spi_flash)
endif()
