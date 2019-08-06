# libevent: An event notification library.
# http://libevent.org/
##########################################

set(LIBEVENT_URL ${THIRDPARTY_URL}/libevent-${LIBEVENT_VERSION}.tar.gz)

external(libevent ${LIBEVENT_VERSION} ${CMAKE_CURRENT_BINARY_DIR})

add_library(libevent ${LIBRARY_LINKAGE} IMPORTED)

add_dependencies(libevent ${LIBEVENT_TARGET})

set_target_properties(
  libevent PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${LIBEVENT_ROOT}/include;${LIBEVENT_ROOT}-build/include")

if (WIN32)
  if (CMAKE_GENERATOR MATCHES "Visual Studio")
    set_target_properties(
      libevent PROPERTIES
      IMPORTED_LOCATION_DEBUG ${LIBEVENT_ROOT}-build/lib/Debug/event${LIBRARY_SUFFIX}
      IMPORTED_LOCATION_RELEASE ${LIBEVENT_ROOT}-build/lib/Release/event${LIBRARY_SUFFIX})
  else ()
    set_target_properties(
      libevent PROPERTIES
      IMPORTED_LOCATION ${LIBEVENT_ROOT}-build/lib/event${LIBRARY_SUFFIX})
  endif ()
else ()
  set_target_properties(
    libevent PROPERTIES
    IMPORTED_LOCATION ${LIBEVENT_ROOT}-build/lib/libevent${LIBRARY_SUFFIX})
endif ()


# NOTE: Libevent does not respect the BUILD_SHARED_LIBS global flag.
if (BUILD_SHARED_LIBS)
  set(LIBEVENT_LIBRARY_TYPE SHARED)
else ()
  set(LIBEVENT_LIBRARY_TYPE STATIC)
endif ()

set(LIBEVENT_CMAKE_FORWARD_ARGS
  ${CMAKE_C_FORWARD_ARGS}
  ${CMAKE_SSL_FORWARD_ARGS}
  -DEVENT__LIBRARY_TYPE=${LIBEVENT_LIBRARY_TYPE}
  -DEVENT__DISABLE_OPENSSL=$<NOT:$<BOOL:${ENABLE_SSL}>>
  -DEVENT__DISABLE_BENCHMARK=ON
  -DEVENT__DISABLE_REGRESS=ON
  -DEVENT__DISABLE_SAMPLES=ON
  -DEVENT__DISABLE_TESTS=ON)

if (CMAKE_C_COMPILER_ID MATCHES GNU OR CMAKE_C_COMPILER_ID MATCHES Clang)
  list(APPEND LIBEVENT_CMAKE_FORWARD_ARGS -DCMAKE_C_FLAGS=-fPIC)
 endif ()

MAKE_INCLUDE_DIR(libevent)

GET_BYPRODUCTS(libevent)

ExternalProject_Add(
  ${LIBEVENT_TARGET}
  PREFIX            ${LIBEVENT_CMAKE_ROOT}
  BUILD_BYPRODUCTS  ${LIBEVENT_BYPRODUCTS}
  CMAKE_ARGS        ${LIBEVENT_CMAKE_FORWARD_ARGS}
  INSTALL_COMMAND   ${CMAKE_NOOP}
  URL               ${LIBEVENT_URL}
  URL_HASH          ${LIBEVENT_HASH})