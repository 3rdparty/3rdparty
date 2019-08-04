# Protocol Buffers: Google's data interchange format.
# https://developers.google.com/protocol-buffers/
#####################################################

set(PROTOBUF_URL ${THIRDPARTY_URL}/protobuf-${PROTOBUF_VERSION}.tar.gz)

set(PROTOBUF_PATCH_FILE protobuf-${PROTOBUF_VERSION}.patch)
set(PROTOBUF_PATCH_URL ${THIRDPARTY_URL}/${PROTOBUF_PATCH_FILE})

external(protobuf ${PROTOBUF_VERSION} ${CMAKE_CURRENT_BINARY_DIR})

# TODO(andschwa): Move protobufs so these don't have to be GLOBAL.
add_library(protobuf ${LIBRARY_LINKAGE} IMPORTED GLOBAL)

add_dependencies(protobuf ${PROTOBUF_TARGET})

add_executable(protoc IMPORTED GLOBAL)

add_dependencies(protoc ${PROTOBUF_TARGET})

set_target_properties(
  protobuf PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${PROTOBUF_ROOT}/src)

set(PROTOBUF_CMAKE_FORWARD_ARGS ${CMAKE_CXX_FORWARD_ARGS}
  -Dprotobuf_BUILD_TESTS=OFF)

if (WIN32)
  file(DOWNLOAD ${PROTOBUF_PATCH_URL} ${CMAKE_CURRENT_BINARY_DIR}/${PROTOBUF_PATCH_FILE})
  patch_cmd(PROTOBUF_PATCH_CMD ${CMAKE_CURRENT_BINARY_DIR}/${PROTOBUF_PATCH_FILE})

  # Link to the CRT dynamically.
  list(APPEND PROTOBUF_CMAKE_FORWARD_ARGS
    -Dprotobuf_MSVC_STATIC_RUNTIME=OFF)

  if (CMAKE_GENERATOR MATCHES "Visual Studio")
    set_target_properties(
      protobuf PROPERTIES
      IMPORTED_LOCATION_DEBUG ${PROTOBUF_ROOT}-build/Debug/libprotobufd${LIBRARY_SUFFIX}
      IMPORTED_LOCATION_RELEASE ${PROTOBUF_ROOT}-build/Release/libprotobuf${LIBRARY_SUFFIX})

    set_target_properties(
      protoc PROPERTIES
      IMPORTED_LOCATION_DEBUG ${PROTOBUF_ROOT}-build/Debug/protoc.exe
      IMPORTED_LOCATION_RELEASE ${PROTOBUF_ROOT}-build/Release/protoc.exe)
  else ()
    # This is for single-configuration generators such as Ninja.
    if (CMAKE_BUILD_TYPE MATCHES Debug)
      set(PROTOBUF_SUFFIX "d")
    endif ()

    set_target_properties(
      protobuf PROPERTIES
      IMPORTED_LOCATION ${PROTOBUF_ROOT}-build/libprotobuf${PROTOBUF_SUFFIX}${LIBRARY_SUFFIX})

    set_target_properties(
      protoc PROPERTIES
      IMPORTED_LOCATION ${PROTOBUF_ROOT}-build/protoc.exe)
  endif ()
else ()
  # This is for single-configuration generators such as GNU Make.
  if (CMAKE_BUILD_TYPE MATCHES Debug)
    set(PROTOBUF_SUFFIX d)
  endif ()

  set_target_properties(
    protobuf PROPERTIES
    IMPORTED_LOCATION ${PROTOBUF_ROOT}-build/libprotobuf${PROTOBUF_SUFFIX}${LIBRARY_SUFFIX})

  set_target_properties(
    protoc PROPERTIES
    IMPORTED_LOCATION ${PROTOBUF_ROOT}-build/protoc)
endif ()

MAKE_INCLUDE_DIR(protobuf)

GET_BYPRODUCTS(protobuf)

ExternalProject_Add(
  ${PROTOBUF_TARGET}
  PREFIX            ${PROTOBUF_CMAKE_ROOT}
  PATCH_COMMAND     ${PROTOBUF_PATCH_CMD}
  BUILD_BYPRODUCTS  ${PROTOBUF_BYPRODUCTS}
  SOURCE_SUBDIR     cmake
  CMAKE_ARGS        ${PROTOBUF_CMAKE_FORWARD_ARGS}
  INSTALL_COMMAND   ${CMAKE_NOOP}
  URL               ${PROTOBUF_URL}
  URL_HASH          ${PROTOBUF_HASH})
