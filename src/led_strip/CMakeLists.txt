cmake_minimum_required(VERSION 3.13)

if(NOT ESP_BUILD)
  return()
endif()

project(led_strip C)

set(HEADER_LIST led_strip/led_strip_encoder.h led_strip/led_strip.h)

set(SOURCE_LIST led_strip/led_strip_encoder.c led_strip/led_strip.c)

# Add library cpp files
add_library(led_strip STATIC)

# Associate the sources with the library
target_sources(led_strip PUBLIC ${SOURCE_LIST} ${HEADER_LIST})

target_link_libraries(led_strip idf::freertos idf::spi_flash
                      idf::esp_driver_rmt)

# Add include directory
target_include_directories(led_strip INTERFACE ${CMAKE_CURRENT_LIST_DIR})
