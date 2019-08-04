# HTTP Parser: HTTP request/response parser for C.
# https://github.com/nodejs/http-parser
##################################################

set(HTTP_PARSER_URL ${THIRDPARTY_URL}/http-parser-${HTTP_PARSER_VERSION}.tar.gz)

set(HTTP_PARSER_PATCH_FILE http-parser/CMakeLists.txt.template)
set(HTTP_PARSER_PATCH_URL ${THIRDPARTY_URL}/${HTTP_PARSER_PATCH_FILE})

EXTERNAL(http_parser ${HTTP_PARSER_VERSION} ${CMAKE_CURRENT_BINARY_DIR})

# NOTE: http-parser is built as a static library unconditionally.
# TODO: Remove `GLOBAL` when `Process3rdpartyConfigure` is removed.
add_library(http_parser STATIC IMPORTED GLOBAL)

add_dependencies(http_parser ${HTTP_PARSER_TARGET})

set_target_properties(
  http_parser PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${HTTP_PARSER_ROOT})

if (WIN32)
  if (CMAKE_GENERATOR MATCHES "Visual Studio")
    set_target_properties(
      http_parser PROPERTIES
      IMPORTED_LOCATION_DEBUG ${HTTP_PARSER_ROOT}-build/Debug/http_parser${CMAKE_STATIC_LIBRARY_SUFFIX}
      IMPORTED_LOCATION_RELEASE ${HTTP_PARSER_ROOT}-build/Release/http_parser${CMAKE_STATIC_LIBRARY_SUFFIX})
  else ()
    set_target_properties(
      http_parser PROPERTIES
      IMPORTED_LOCATION ${HTTP_PARSER_ROOT}-build/http_parser${CMAKE_STATIC_LIBRARY_SUFFIX})
  endif ()
else ()
  set_target_properties(
    http_parser PROPERTIES
    IMPORTED_LOCATION ${HTTP_PARSER_ROOT}-build/libhttp_parser${CMAKE_STATIC_LIBRARY_SUFFIX})
endif ()

# NOTE: This is used to provide a CMake build for http-parser. We can't just use
# `add_library(http_parser ...)` because `ExternalProject_Add` extracts the
# tarball at build time, and `add_library` is a configuration time step.
file(DOWNLOAD ${HTTP_PARSER_PATCH_URL} ${CMAKE_CURRENT_BINARY_DIR}/${HTTP_PARSER_PATCH_FILE})
set(HTTP_PARSER_PATCH_CMD
  ${CMAKE_COMMAND} -E copy
  ${CMAKE_CURRENT_BINARY_DIR}/${HTTP_PARSER_PATCH_FILE}
  ${HTTP_PARSER_ROOT}/CMakeLists.txt)

MAKE_INCLUDE_DIR(http_parser)

GET_BYPRODUCTS(http_parser)

ExternalProject_Add(
  ${HTTP_PARSER_TARGET}
  PREFIX            ${HTTP_PARSER_CMAKE_ROOT}
  BUILD_BYPRODUCTS  ${HTTP_PARSER_BYPRODUCTS}
  PATCH_COMMAND     ${HTTP_PARSER_PATCH_CMD}
  CMAKE_ARGS        ${CMAKE_CXX_FORWARD_ARGS}
  INSTALL_COMMAND   ${CMAKE_NOOP}
  URL               ${HTTP_PARSER_URL}
  URL_HASH          ${HTTP_PARSER_HASH})