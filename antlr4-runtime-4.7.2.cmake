# antlr4-runtime: C++ runtime for antlr4.
# https://www.antlr.org
###############################################

set(ANTLR4_RUNTIME_URL ${THIRDPARTY_URL}/antlr4-runtime-${ANTLR4_RUNTIME_VERSION}.zip)

external(antlr4-runtime ${ANTLR4_RUNTIME_VERSION} ${CMAKE_CURRENT_BINARY_DIR})

add_library(antlr4-runtime ${LIBRARY_LINKAGE} IMPORTED GLOBAL)

add_dependencies(antlr4-runtime ${ANTLR4_RUNTIME_TARGET})

set(ANTLR4_RUNTIME_INSTALL_DIR ${ANTLR4_RUNTIME_ROOT}-install)

if (CMAKE_GENERATOR MATCHES "Visual Studio")
  set_target_properties(
    antlr4-runtime PROPERTIES
    IMPORTED_LOCATION_DEBUG ${ANTLR4_RUNTIME_INSTALL_DIR}/lib/glogd${LIBRARY_SUFFIX}
    IMPORTED_IMPLIB_DEBUG ${ANTLR4_RUNTIME_INSTALL_DIR}/lib/glogd${CMAKE_IMPORT_LIBRARY_SUFFIX}
    IMPORTED_LOCATION_RELEASE ${ANTLR4_RUNTIME_INSTALL_DIR}/lib/glog${LIBRARY_SUFFIX}
    IMPORTED_IMPLIB_RELEASE ${ANTLR4_RUNTIME_INSTALL_DIR}/lib/glog${CMAKE_IMPORT_LIBRARY_SUFFIX}
  )
else ()
  set_target_properties(
    antlr4-runtime PROPERTIES
    IMPORTED_LOCATION ${ANTLR4_RUNTIME_INSTALL_DIR}/lib/libglog${LIBRARY_SUFFIX}
    IMPORTED_IMPLIB ${ANTLR4_RUNTIME_INSTALL_DIR}/lib/libglog${CMAKE_IMPORT_LIBRARY_SUFFIX}
  )
endif ()

set_target_properties(
  antlr4-runtime PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${ANTLR4_RUNTIME_INSTALL_DIR}/include/antlr4-runtime
)

set(
  ANTLR4_RUNTIME_CMAKE_ARGS
  ${CMAKE_CXX_FORWARD_ARGS}
  -BUILD_TESTS=OFF
  -DCMAKE_INSTALL_BINDIR=${ANTLR4_RUNTIME_INSTALL_DIR}/bin
  -DCMAKE_INSTALL_INCLUDEDIR=${ANTLR4_RUNTIME_INSTALL_DIR}/include
  -DCMAKE_INSTALL_LIBDIR=${ANTLR4_RUNTIME_INSTALL_DIR}/lib
  -DANTLR4_INSTALL=TRUE
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
