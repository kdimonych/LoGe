cmake_minimum_required(VERSION 3.13)

project(main CXX)

if(ESP_BUILD)
  add_subdirectory(led_strip)
else()
  message(WARNING "Unknown target ${TARGET}, creating stubs for esp32 instead")
  # Create stubs for esp32 and freertos, stub::esp32 and stub::freertos
  add_subdirectory(stubs/esp32)
  add_subdirectory(stubs/freertos)
  add_subdirectory(stubs/spi_flash)
  add_subdirectory(stubs/led_strip)
endif()
