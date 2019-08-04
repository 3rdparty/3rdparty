# glog: Google Logging Library.
# https://github.com/google/glog
################################

set(GLOG_URL ${THIRDPARTY_URL}/glog-${GLOG_VERSION}.tar.gz)

set(GLOG_PATCH_FILE glog-${GLOG_VERSION}.patch)
set(GLOG_PATCH_URL ${THIRDPARTY_URL}/${GLOG_PATCH_FILE})

external(glog ${GLOG_VERSION} ${CMAKE_CURRENT_BINARY_DIR})

add_library(glog ${LIBRARY_LINKAGE} IMPORTED GLOBAL)

add_dependencies(glog ${GLOG_TARGET})

# Patch glog to deal with a problem that appears when compiling on clang
# under the C++11 standard. cf. MESOS-860, MESOS-966.
# On Windows, patch it to enable stack tracing.
file(DOWNLOAD ${GLOG_PATCH_URL} ${CMAKE_CURRENT_BINARY_DIR}/${GLOG_PATCH_FILE})
patch_cmd(GLOG_PATCH_CMD ${CMAKE_CURRENT_BINARY_DIR}/${GLOG_PATCH_FILE})

set(GLOG_LIBRARY_NAME libglog)

if (WIN32)
  # NOTE: Windows-specific workaround for a glog issue documented here[1].
  # Basically, Windows.h and glog/logging.h both define ERROR. Since we don't
  # need the Windows ERROR, we can use this flag to avoid defining it at all.
  # Unlike the other fix (defining GLOG_NO_ABBREVIATED_SEVERITIES), this fix
  # is guaranteed to require no changes to the original Mesos code. See also
  # the note in the code itself[2].
  #
  # [1] https://htmlpreview.github.io/?https://github.com/google/glog/blob/master/doc/glog.html#windows
  # [2] https://github.com/google/glog/blob/f012836db187d5897d4adaaf621b4d53ae4865da/src/windows/glog/logging.h#L965
  set(GLOG_COMPILE_DEFINITIONS NOGDI NOMINMAX)
  if (NOT BUILD_SHARED_LIBS)
    list(APPEND GLOG_COMPILE_DEFINITIONS GOOGLE_GLOG_DLL_DECL=)
  endif ()

  set_target_properties(
    glog PROPERTIES
    # TODO(andschwa): Remove this when glog is updated.
    IMPORTED_LINK_INTERFACE_LIBRARIES DbgHelp
    INTERFACE_COMPILE_DEFINITIONS "${GLOG_COMPILE_DEFINITIONS}")

endif ()

set(GLOG_INSTALL_DIR ${GLOG_ROOT}-install)

if (CMAKE_GENERATOR MATCHES "Visual Studio")
  set_target_properties(
    glog PROPERTIES
    IMPORTED_LOCATION_DEBUG ${GLOG_INSTALL_DIR}/lib/glogd${LIBRARY_SUFFIX}
    IMPORTED_IMPLIB_DEBUG ${GLOG_INSTALL_DIR}/lib/glogd${CMAKE_IMPORT_LIBRARY_SUFFIX}
    IMPORTED_LOCATION_RELEASE ${GLOG_INSTALL_DIR}/lib/glog${LIBRARY_SUFFIX}
    IMPORTED_IMPLIB_RELEASE ${GLOG_INSTALL_DIR}/lib/glog${CMAKE_IMPORT_LIBRARY_SUFFIX}
  )
else ()
  set_target_properties(
    glog PROPERTIES
    IMPORTED_LOCATION ${GLOG_INSTALL_DIR}/lib/libglog${LIBRARY_SUFFIX}
    IMPORTED_IMPLIB ${GLOG_INSTALL_DIR}/lib/libglog${CMAKE_IMPORT_LIBRARY_SUFFIX}
  )
endif ()

set_target_properties(
  glog PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${GLOG_INSTALL_DIR}/include
)

set(
  GLOG_CMAKE_ARGS
  ${CMAKE_CXX_FORWARD_ARGS}
  -DBUILD_TESTING=OFF
  -DCMAKE_INSTALL_BINDIR=${GLOG_INSTALL_DIR}/bin
  -DCMAKE_INSTALL_INCLUDEDIR=${GLOG_INSTALL_DIR}/include
  -DCMAKE_INSTALL_LIBDIR=${GLOG_INSTALL_DIR}/lib
  -DWITH_GFLAGS=OFF
)

MAKE_INCLUDE_DIR(glog)

GET_BYPRODUCTS(glog)

ExternalProject_Add(
  ${GLOG_TARGET}
  PREFIX            ${GLOG_CMAKE_ROOT}
  BUILD_BYPRODUCTS  ${GLOG_BYPRODUCTS}
  PATCH_COMMAND     ${GLOG_PATCH_CMD}
  CMAKE_ARGS        ${GLOG_CMAKE_ARGS}
  INSTALL_DIR       ${GLOG_INSTALL_DIR}
  URL               ${GLOG_URL}
  URL_HASH          ${GLOG_HASH})
