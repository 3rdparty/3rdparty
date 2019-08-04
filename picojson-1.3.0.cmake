# PicoJSON: JSON parser / serializer.
# https://github.com/kazuho/picojson
#####################################

set(PICOJSON_URL ${3RDPARTY_URL}/picojson-${PICOJSON_VERSION}.tar.gz)

set(PICOJSON_PATCH_FILE picojson-${PICOJSON_VERSION}.patch)
set(PICOJSON_PATCH_URL ${3RDPARTY_URL}/${PICOJSON_PATCH_FILE})

external(picojson ${PICOJSON_VERSION} ${CMAKE_CURRENT_BINARY_DIR})

add_library(picojson INTERFACE)

add_dependencies(picojson ${PICOJSON_TARGET})

target_include_directories(picojson INTERFACE ${PICOJSON_ROOT})

# NOTE: PicoJson requires __STDC_FORMAT_MACROS to be defined before importing
# 'inttypes.h'.  Since other libraries may also import this header, it must
# be globally defined so that PicoJSON has access to the macros, regardless
# of the order of inclusion.
target_compile_definitions(
  picojson INTERFACE
  __STDC_FORMAT_MACROS)

file(DOWNLOAD ${PICOJSON_PATCH_URL} ${CMAKE_CURRENT_BINARY_DIR}/${PICOJSON_PATCH_FILE})
patch_cmd(PICOJSON_PATCH_CMD ${CMAKE_CURRENT_BINARY_DIR}/${PICOJSON_PATCH_FILE})

ExternalProject_Add(
  ${PICOJSON_TARGET}
  PREFIX            ${PICOJSON_CMAKE_ROOT}
  PATCH_COMMAND     ${PICOJSON_PATCH_CMD}
  CONFIGURE_COMMAND ${CMAKE_NOOP}
  BUILD_COMMAND     ${CMAKE_NOOP}
  INSTALL_COMMAND   ${CMAKE_NOOP}
  URL               ${PICOJSON_URL}
  URL_HASH          ${PICOJSON_HASH})
