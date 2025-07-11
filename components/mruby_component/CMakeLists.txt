# Original file from: https://github.com/mruby-esp32/mruby-esp32/blob/master/components/mruby_component/CMakeLists.txt
# Copyright (c) 2016 Carson McDonald
# Licensed under the MIT License

set(MRUBY_DIR "${COMPONENT_DIR}/mruby")
set(LIBMRUBY_FILE "${COMPONENT_DIR}/mruby/build/esp32/lib/libmruby.a")
set(MRUBY_CONFIG ${COMPONENT_DIR}/esp32_build_config.rb)

idf_component_register(
  INCLUDE_DIRS mruby/include
  REQUIRES esp_hw_support esp_rom esp_timer driver esp_adc esp_wifi mqtt micro_ros_espidf_component
)

add_custom_command(
  OUTPUT ${LIBMRUBY_FILE}
  COMMAND ${CMAKE_COMMAND} -E env "MRUBY_CONFIG=${MRUBY_CONFIG}" "CC=${CMAKE_C_COMPILER}" "LD=${CMAKE_LINKER}" "AR=${CMAKE_AR}" "COMPONENT_INCLUDES=$<TARGET_PROPERTY:${COMPONENT_TARGET},INTERFACE_INCLUDE_DIRECTORIES>" rake
  WORKING_DIRECTORY ${MRUBY_DIR}
  BYPRODUCTS ${COMPONENT_DIR}/esp32_build_config.rb.lock
  VERBATIM
)

add_prebuilt_library(
  libmruby ${LIBMRUBY_FILE}
  PRIV_REQUIRES esp_hw_support esp_rom esp_timer driver esp_adc esp_wifi mqtt micro_ros_espidf_component
)
target_link_libraries(${COMPONENT_LIB} INTERFACE libmruby)

add_custom_target(mruby DEPENDS ${LIBMRUBY_FILE})
add_dependencies(${COMPONENT_LIB} mruby)