# gRPC: Google's high performance, open-source universal RPC framework.
# https://grpc.io/
#######################################################################

set(GRPC_URL ${THIRDPARTY_URL}/grpc-${GRPC_VERSION}.tar.gz)

set(GRPC_PATCH_FILE grpc-${GRPC_VERSION}.patch)
set(GRPC_PATCH_URL ${THIRDPARTY_URL}/${GRPC_PATCH_FILE})

external(grpc ${GRPC_VERSION} ${CMAKE_CURRENT_BINARY_DIR})

add_library(libgpr ${LIBRARY_LINKAGE} IMPORTED)
add_dependencies(libgpr ${GRPC_TARGET})

add_library(libgrpc ${LIBRARY_LINKAGE} IMPORTED)
add_dependencies(libgrpc ${GRPC_TARGET})

add_library(libgrpc++ ${LIBRARY_LINKAGE} IMPORTED)
add_dependencies(libgrpc++ ${GRPC_TARGET})

add_library(grpc INTERFACE)

target_link_libraries(grpc INTERFACE libgrpc++ libgrpc libgpr)

# TODO(chhsiao): Move grpc so these don't have to be GLOBAL.
add_executable(grpc_cpp_plugin IMPORTED GLOBAL)
add_dependencies(grpc_cpp_plugin ${GRPC_TARGET})

set(GRPC_CMAKE_ARGS
  ${CMAKE_C_FORWARD_ARGS}
  ${CMAKE_CXX_FORWARD_ARGS}
  -DCMAKE_PREFIX_PATH=${PROTOBUF_ROOT}-build
  -DgRPC_PROTOBUF_PROVIDER=package
  -DgRPC_PROTOBUF_PACKAGE_TYPE=CONFIG
  -DgRPC_ZLIB_PROVIDER=package)

if (ENABLE_SSL)
  set(GRPC_VARIANT "")
  list(APPEND GRPC_CMAKE_ARGS -DgRPC_SSL_PROVIDER=package ${CMAKE_SSL_FORWARD_ARGS})
else ()
  set(GRPC_VARIANT "_unsecure")
  list(APPEND GRPC_CMAKE_ARGS -DgRPC_SSL_PROVIDER=none)
endif ()

set(GRPC_BUILD_CMD
  ${CMAKE_COMMAND} --build . --config $<CONFIG> --target gpr &&
  ${CMAKE_COMMAND} --build . --config $<CONFIG> --target grpc${GRPC_VARIANT} &&
  ${CMAKE_COMMAND} --build . --config $<CONFIG> --target grpc++${GRPC_VARIANT} &&
  ${CMAKE_COMMAND} --build . --config $<CONFIG> --target grpc_cpp_plugin)

set_target_properties(
  grpc PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${GRPC_ROOT}/include)

file(DOWNLOAD ${GRPC_PATCH_URL} ${CMAKE_CURRENT_BINARY_DIR}/${GRPC_PATCH_FILE})
patch_cmd(GRPC_PATCH_CMD ${CMAKE_CURRENT_BINARY_DIR}/${GRPC_PATCH_FILE})

if (WIN32)
  list(APPEND GRPC_CMAKE_ARGS -DZLIB_ROOT=${ZLIB_ROOT}-lib)

  if (CMAKE_GENERATOR MATCHES "Visual Studio")
    set_target_properties(
      libgpr PROPERTIES
      IMPORTED_LOCATION_DEBUG ${GRPC_ROOT}-build/Debug/gpr${LIBRARY_SUFFIX}
      IMPORTED_LOCATION_RELEASE ${GRPC_ROOT}-build/Release/gpr${LIBRARY_SUFFIX}
      IMPORTED_IMPLIB_DEBUG ${GRPC_ROOT}-build/Debug/gpr${CMAKE_IMPORT_LIBRARY_SUFFIX}
      IMPORTED_IMPLIB_RELEASE ${GRPC_ROOT}-build/Release/gpr${CMAKE_IMPORT_LIBRARY_SUFFIX})

    set_target_properties(
      libgrpc PROPERTIES
      IMPORTED_LOCATION_DEBUG ${GRPC_ROOT}-build/Debug/grpc${GRPC_VARIANT}${LIBRARY_SUFFIX}
      IMPORTED_LOCATION_RELEASE ${GRPC_ROOT}-build/Release/grpc${GRPC_VARIANT}${LIBRARY_SUFFIX}
      IMPORTED_IMPLIB_DEBUG ${GRPC_ROOT}-build/Debug/grpc${GRPC_VARIANT}${CMAKE_IMPORT_LIBRARY_SUFFIX}
      IMPORTED_IMPLIB_RELEASE ${GRPC_ROOT}-build/Release/grpc${GRPC_VARIANT}${CMAKE_IMPORT_LIBRARY_SUFFIX})

    set_target_properties(
      libgrpc++ PROPERTIES
      IMPORTED_LOCATION_DEBUG ${GRPC_ROOT}-build/Debug/grpc++${GRPC_VARIANT}${LIBRARY_SUFFIX}
      IMPORTED_LOCATION_RELEASE ${GRPC_ROOT}-build/Release/grpc++${GRPC_VARIANT}${LIBRARY_SUFFIX}
      IMPORTED_IMPLIB_DEBUG ${GRPC_ROOT}-build/Debug/grpc++${GRPC_VARIANT}${CMAKE_IMPORT_LIBRARY_SUFFIX}
      IMPORTED_IMPLIB_RELEASE ${GRPC_ROOT}-build/Release/grpc++${GRPC_VARIANT}${CMAKE_IMPORT_LIBRARY_SUFFIX})

    set_target_properties(
      grpc_cpp_plugin PROPERTIES
      IMPORTED_LOCATION_DEBUG ${GRPC_ROOT}-build/Debug/grpc_cpp_plugin.exe
      IMPORTED_LOCATION_RELEASE ${GRPC_ROOT}-build/Release/grpc_cpp_plugin.exe)
  else ()
    set_target_properties(
      libgpr PROPERTIES
      IMPORTED_LOCATION ${GRPC_ROOT}-build/gpr${LIBRARY_SUFFIX}
      IMPORTED_IMPLIB ${GRPC_ROOT}-build/gpr${CMAKE_IMPORT_LIBRARY_SUFFIX})

    set_target_properties(
      libgrpc PROPERTIES
      IMPORTED_LOCATION ${GRPC_ROOT}-build/grpc${GRPC_VARIANT}${LIBRARY_SUFFIX}
      IMPORTED_IMPLIB ${GRPC_ROOT}-build/grpc${GRPC_VARIANT}${CMAKE_IMPORT_LIBRARY_SUFFIX})

    set_target_properties(
      libgrpc++ PROPERTIES
      IMPORTED_LOCATION ${GRPC_ROOT}-build/grpc++${GRPC_VARIANT}${LIBRARY_SUFFIX}
      IMPORTED_IMPLIB ${GRPC_ROOT}-build/grpc++${GRPC_VARIANT}${CMAKE_IMPORT_LIBRARY_SUFFIX})

    set_target_properties(
      grpc_cpp_plugin PROPERTIES
      IMPORTED_LOCATION ${GRPC_ROOT}-build/grpc_cpp_plugin.exe)
  endif()
else ()
  set_target_properties(
    libgpr PROPERTIES
    IMPORTED_LOCATION ${GRPC_ROOT}-build/libgpr${LIBRARY_SUFFIX})

  set_target_properties(
    libgrpc PROPERTIES
    IMPORTED_LOCATION ${GRPC_ROOT}-build/libgrpc${GRPC_VARIANT}${LIBRARY_SUFFIX})

  set_target_properties(
    libgrpc++ PROPERTIES
    IMPORTED_LOCATION ${GRPC_ROOT}-build/libgrpc++${GRPC_VARIANT}${LIBRARY_SUFFIX})

  set_target_properties(
    grpc_cpp_plugin PROPERTIES
    IMPORTED_LOCATION ${GRPC_ROOT}-build/grpc_cpp_plugin)
endif ()

MAKE_INCLUDE_DIR(grpc)

GET_BYPRODUCTS(libgpr)
GET_BYPRODUCTS(libgrpc)
GET_BYPRODUCTS(libgrpc++)
GET_BYPRODUCTS(grpc_cpp_plugin)

ExternalProject_Add(
  ${GRPC_TARGET}
  DEPENDS          protobuf protoc zlib
  PREFIX           ${GRPC_CMAKE_ROOT}
  PATCH_COMMAND    ${GRPC_PATCH_CMD}
  BUILD_BYPRODUCTS ${LIBGPR_BYPRODUCTS};${LIBGRPC_BYPRODUCTS};${LIBGRPC++_BYPRODUCTS};${GRPC_CPP_PLUGIN_BYPRODUCTS}
  CMAKE_ARGS       ${GRPC_CMAKE_ARGS}
  BUILD_COMMAND    ${GRPC_BUILD_CMD}
  INSTALL_COMMAND  ${CMAKE_NOOP}
  URL              ${GRPC_URL}
  URL_HASH         ${GRPC_HASH})