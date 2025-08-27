cmake_minimum_required(VERSION 3.21)

project(LoGe)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF) # Disable compiler-specific extensions
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(TARGETS
    "esp32"
    "esp32s2"
    "esp32s3"
    "esp32c3"
    "esp32c2"
    "esp32c6"
    "esp32h2"
    "esp32p4")

set(ESP_BUILD OFF)

# Add GoogleTest
if(NOT "${TARGET}" IN_LIST TARGETS)
  message(STATUS "Install GTest")
  # Include GTest
  set(INSTALL_GTEST
      OFF
      CACHE BOOL "" FORCE)
  set(BUILD_GMOCK
      ON
      CACHE BOOL "" FORCE)
  set(BUILD_GTEST
      ON
      CACHE BOOL "" FORCE)
  # cmake-lint: disable=C0103
  set(gtest_force_shared_crt
      ON
      CACHE BOOL "" FORCE)

  add_subdirectory(${CMAKE_SOURCE_DIR}/third_party/googletest)
else()
  set(ESP_BUILD ON)
endif()

# Add AbstractPlatform
add_subdirectory(AbstractPlatform)
add_subdirectory(src)

set(ELF_FILES ${CMAKE_PROJECT_NAME}.elf)
add_executable(${ELF_FILES} main.cpp)

# Link the static libraries to the executable
if(ESP_BUILD)
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
    esp_driver_rmt
    freertos
    esptool_py
    SDKCONFIG
    ${CMAKE_CURRENT_LIST_DIR}/sdkconfig
    BUILD_DIR
    ${CMAKE_BINARY_DIR})

  target_link_libraries(${ELF_FILES} idf::freertos idf::spi_flash led_strip
                        abstract-platform.platform abstract-platform.common)
  # Attach additional targets to the executable file for flashing, linker script
  # generation, partition_table generation, etc.
  idf_build_executable(${ELF_FILES})
else()
  target_link_libraries(
    ${ELF_FILES}
    stub::esp32
    stub::freertos
    stub::spi_flash
    stub::led_strip
    abstract-platform.platform
    abstract-platform.common)
endif()
