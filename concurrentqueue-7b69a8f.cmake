# moodycamel::ConcurrentQueue: An industrial-strength lock-free queue.
# https://github.com/cameron314/concurrentqueue
######################################################################

set(CONCURRENTQUEUE_URL ${THIRDPARTY_URL}/concurrentqueue-${CONCURRENTQUEUE_VERSION}.tar.gz)

external(concurrentqueue ${CONCURRENTQUEUE_VERSION} ${CMAKE_CURRENT_BINARY_DIR})

add_library(concurrentqueue INTERFACE)

add_dependencies(concurrentqueue ${CONCURRENTQUEUE_TARGET})

target_include_directories(concurrentqueue INTERFACE ${CONCURRENTQUEUE_ROOT})

ExternalProject_Add(
  ${CONCURRENTQUEUE_TARGET}
  PREFIX            ${CONCURRENTQUEUE_CMAKE_ROOT}
  CONFIGURE_COMMAND ${CMAKE_NOOP}
  BUILD_COMMAND     ${CMAKE_NOOP}
  INSTALL_COMMAND   ${CMAKE_NOOP}
  URL               ${CONCURRENTQUEUE_URL}
  URL_HASH          ${CONCURRENTQUEUE_HASH})
