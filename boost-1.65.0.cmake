# Boost: C++ Libraries.
# http://www.boost.org
#######################

set(BOOST_URL ${THIRDPARTY_URL}/boost-${BOOST_VERSION}.tar.gz)

set(BOOST_PATCH_FILE boost-${BOOST_VERSION}.patch)
set(BOOST_PATCH_URL ${THIRDPARTY_URL}/${BOOST_PATCH_FILE})

external(boost ${BOOST_VERSION} ${CMAKE_CURRENT_BINARY_DIR})

add_library(boost INTERFACE)

add_dependencies(boost ${BOOST_TARGET})

if (CMAKE_CXX_COMPILER_ID MATCHES GNU OR CMAKE_CXX_COMPILER_ID MATCHES Clang)
  # Headers including Boost 1.65.0 fail to compile with GCC 7.2 and
  # CLang 3.6 without `-Wno-unused-local-typedefs`.
  # TODO(andschwa): Remove this when Boost has a resolution.
  target_compile_options(boost INTERFACE -Wno-unused-local-typedefs)
endif ()

target_include_directories(boost INTERFACE ${BOOST_ROOT})

# Patch Boost to avoid repeated "Unknown compiler warnings" on Windows.
file(DOWNLOAD ${BOOST_PATCH_URL} ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_PATCH_FILE})
patch_cmd(BOOST_PATCH_CMD ${CMAKE_CURRENT_BINARY_DIR}/${BOOST_PATCH_FILE})

ExternalProject_Add(
  ${BOOST_TARGET}
  PREFIX            ${BOOST_CMAKE_ROOT}
  PATCH_COMMAND     ${BOOST_PATCH_CMD}
  CONFIGURE_COMMAND ${CMAKE_NOOP}
  BUILD_COMMAND     ${CMAKE_NOOP}
  INSTALL_COMMAND   ${CMAKE_NOOP}
  URL               ${BOOST_URL}
  URL_HASH          ${BOOST_HASH})