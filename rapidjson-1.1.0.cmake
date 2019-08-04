# RapidJSON: JSON parser / serializer.
# https://github.com/Tencent/rapidjson
#####################################

set(RAPIDJSON_URL ${3RDPARTY_URL}/rapidjson-${RAPIDJSON_VERSION}.tar.gz)

external(rapidjson ${RAPIDJSON_VERSION} ${CMAKE_CURRENT_BINARY_DIR})

add_library(rapidjson INTERFACE)

add_dependencies(rapidjson ${RAPIDJSON_TARGET})

target_include_directories(
    rapidjson INTERFACE
    ${RAPIDJSON_ROOT}/include)

ExternalProject_Add(
  ${RAPIDJSON_TARGET}
  PREFIX            ${RAPIDJSON_CMAKE_ROOT}
  CONFIGURE_COMMAND ${CMAKE_NOOP}
  BUILD_COMMAND     ${CMAKE_NOOP}
  INSTALL_COMMAND   ${CMAKE_NOOP}
  URL               ${RAPIDJSON_URL}
  URL_HASH          ${RAPIDJSON_HASH})
