cmake_minimum_required(VERSION 3.13)

project(stub-led_strip C)

set(HEADER_LIST led_strip/led_strip.h)
set(SOURCE_LIST)

# Add library cpp files
add_library(stub-led_strip INTERFACE)

# Associate the sources with the library
target_sources(stub-led_strip INTERFACE ${SOURCE_LIST} ${HEADER_LIST})

# Add include directory
target_include_directories(stub-led_strip INTERFACE ${CMAKE_CURRENT_LIST_DIR})

add_library(stub::led_strip ALIAS stub-led_strip)
