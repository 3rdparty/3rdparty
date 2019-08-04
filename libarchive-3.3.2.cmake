# libarchive: Multi-format archive and compression library.
# https://github.com/libarchive/libarchive
###########################################################

set(LIBARCHIVE_URL ${3RDPARTY_URL}/libarchive-${LIBARCHIVE_VERSION}.tar.gz)

set(LIBARCHIVE_PATCH_FILE libarchive-${LIBARCHIVE_VERSION}.patch)
set(LIBARCHIVE_PATCH_URL ${3RDPARTY_URL}/${LIBARCHIVE_PATCH_FILE})

external(libarchive ${LIBARCHIVE_VERSION} ${CMAKE_CURRENT_BINARY_DIR})

add_library(libarchive STATIC IMPORTED GLOBAL)

add_dependencies(libarchive ${LIBARCHIVE_TARGET})

set(LIBARCHIVE_CMAKE_ARGS
  ${CMAKE_FORWARD_ARGS}
  ${CMAKE_C_FORWARD_ARGS}
  -DENABLE_ACL=OFF
  -DENABLE_CNG=OFF
  -DENABLE_CPIO=OFF
  -DENABLE_EXPAT=OFF
  -DENABLE_ICONV=OFF
  -DENABLE_LibGCC=OFF
  -DENABLE_LIBXML2=OFF
  -DENABLE_LZO=OFF
  -DENABLE_NETTLE=OFF
  -DENABLE_OPENSSL=OFF
  -DENABLE_PCREPOSIX=OFF
  -DENABLE_TEST=OFF
  -DCMAKE_PREFIX_PATH=${ZLIB_ROOT}-lib@@${BZIP2_ROOT}-lib@@${XZ_ROOT}-lib
  -DCMAKE_INSTALL_PREFIX=${LIBARCHIVE_ROOT}-build)

file(DOWNLOAD ${LIBARCHIVE_PATCH_URL} ${CMAKE_CURRENT_BINARY_DIR}/${LIBARCHIVE_PATCH_FILE})
patch_cmd(LIBARCHIVE_PATCH_CMD ${CMAKE_CURRENT_BINARY_DIR}/${LIBARCHIVE_PATCH_FILE})

# NOTE: On Windows, libarchive is linked against several compression
# libraries included in the build chain, such as bzip2, xz, and zlib.
# On other platforms, libarchive links to zlib only, as bzip2 and xz
# are not in the build chain.
if (WIN32)
  set_target_properties(
    libarchive PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS LIBARCHIVE_STATIC
    # NOTE: The install step avoids the need for separate DEBUG and
    # RELEASE paths.
    IMPORTED_LOCATION ${LIBARCHIVE_ROOT}-build/lib/archive_static${LIBRARY_SUFFIX}
    INTERFACE_INCLUDE_DIRECTORIES ${LIBARCHIVE_ROOT}-build/include
    INTERFACE_LINK_LIBRARIES "bzip2;xz;zlib")
  set(LIBARCHIVE_DEPENDS bzip2 xz zlib)

  # Make libarchive link against the same zlib the rest of the build
  # links to. This is necessary because the zlib project
  # unconditionally builds both shared and static libraries, and we
  # need to be consistent about which is linked.
  list(APPEND LIBARCHIVE_CMAKE_ARGS
    -DZLIB_LIBRARY=$<TARGET_FILE:zlib>)
else ()
  list(APPEND LIBARCHIVE_CMAKE_ARGS
    -DENABLE_BZip2=OFF
    -DENABLE_LZMA=OFF)

  set_target_properties(
    libarchive PROPERTIES
    IMPORTED_LOCATION ${LIBARCHIVE_ROOT}-build/lib/libarchive${CMAKE_STATIC_LIBRARY_SUFFIX}
    INTERFACE_INCLUDE_DIRECTORIES ${LIBARCHIVE_ROOT}-build/include
    INTERFACE_LINK_LIBRARIES "zlib")
  set(LIBARCHIVE_DEPENDS zlib)
endif ()

MAKE_INCLUDE_DIR(libarchive)

GET_BYPRODUCTS(libarchive)

ExternalProject_Add(
  ${LIBARCHIVE_TARGET}
  DEPENDS           ${LIBARCHIVE_DEPENDS}
  PREFIX            ${LIBARCHIVE_CMAKE_ROOT}
  BUILD_BYPRODUCTS  ${LIBARCHIVE_BYPRODUCTS}
  PATCH_COMMAND     ${LIBARCHIVE_PATCH_CMD}
  LIST_SEPARATOR    @@
  CMAKE_ARGS        ${LIBARCHIVE_CMAKE_ARGS}
  URL               ${LIBARCHIVE_URL}
  URL_HASH          ${LIBARCHIVE_HASH})