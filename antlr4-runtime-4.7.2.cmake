# antlr4-runtime: C++ runtime for antlr4.
# https://www.antlr.org
###############################################

# TODO(benh): Rename the target here to `antlr4-runtime` to
# distinguish that the only thing we're buildling is the C++ runtime.

set(ANTLR4_RUNTIME_URL ${THIRDPARTY_URL}/antlr4-runtime-${ANTLR4_RUNTIME_VERSION}.zip)

external(antlr4-runtime ${ANTLR4_RUNTIME_VERSION} ${CMAKE_CURRENT_BINARY_DIR})

add_library(antlr4-runtime ${LIBRARY_LINKAGE} IMPORTED GLOBAL)

add_dependencies(antlr4-runtime ${ANTLR4_RUNTIME_TARGET})

set(
  ANTLR4_RUNTIME_CMAKE_ARGS
  ${CMAKE_CXX_FORWARD_ARGS}
  -BUILD_TESTS=OFF)

set(ANTLR4_RUNTIME_INSTALL_DIR ${ANTLR4_RUNTIME_ROOT}-install)

set_target_properties(
  antlr4-runtime PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${ANTLR4_RUNTIME_INSTALL_DIR}/include/antlr4-runtime
)

set_target_properties(
  antlr4-runtime PROPERTIES
  IMPORTED_LOCALTION ${ANTLR4_RUNTIME_INSTALL_DIR}/lib/libantlr4-runtime${LIBRARY_SUFFIX}
)

MAKE_INCLUDE_DIR(antlr4-runtime)

GET_BYPRODUCTS(antlr4-runtime)

ExternalProject_ADD(
  ${ANTLR4_RUNTIME_TARGET}
  PREFIX             ${ANTLR4_RUNTIME_CMAKE_ROOT}
  BUILD_BYPRODUCTS   ${ANTLR4_RUNTIME_BYPRODUCTS}
  CMAKE_ARGS         ${ANTLR4_RUNTIME_CMAKE_ARGS}
  INSTALL_DIR        ${ANTLR4_RUNTIME_INSTALL_DIR}
  URL                ${ANTLR4_RUNTIME_URL}
  URL_HASH           ${ANTLR4_RUNTIME_HASH}
)
