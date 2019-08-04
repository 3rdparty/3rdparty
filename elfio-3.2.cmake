# ELFIO: library for reading and generating ELF files.
# http://elfio.sourceforge.net
######################################################

set(ELFIO_URL ${3RDPARTY_URL}/elfio-${ELFIO_VERSION}.tar.gz)

external(elfio ${ELFIO_VERSION} ${CMAKE_CURRENT_BINARY_DIR})

add_library(elfio INTERFACE)

add_dependencies(elfio ${ELFIO_TARGET})

target_include_directories(elfio INTERFACE ${ELFIO_ROOT})

ExternalProject_Add(
  ${ELFIO_TARGET}
  PREFIX            ${ELFIO_CMAKE_ROOT}
  CONFIGURE_COMMAND ${CMAKE_NOOP}
  BUILD_COMMAND     ${CMAKE_NOOP}
  INSTALL_COMMAND   ${CMAKE_NOOP}
  URL               ${ELFIO_URL}
  URL_HASH          ${ELFIO_HASH})