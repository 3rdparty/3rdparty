# Google Test: Google's C++ test framework (GoogleTest and GoogleMock).
# https://github.com/google/googletest
#######################################################################

set(GOOGLETEST_URL ${THIRDPARTY_URL}/googletest-release-${GOOGLETEST_VERSION}.tar.gz)

set(GOOGLETEST_PATCH_FILE googletest-release-${GOOGLETEST_VERSION}.patch)
set(GOOGLETEST_PATCH_URL ${THIRDPARTY_URL}/${GOOGLETEST_PATCH_FILE})

external(googletest ${GOOGLETEST_VERSION} ${CMAKE_CURRENT_BINARY_DIR})

add_library(googletest INTERFACE)

add_dependencies(googletest ${GOOGLETEST_TARGET})

target_link_libraries(googletest INTERFACE gmock gtest)

# Note that Google Test is always built with static libraries because of the
# following open issue when using shared libraries, on both Windows and Linux:
# https://github.com/google/googletest/issues/930
add_library(gmock STATIC IMPORTED GLOBAL)
add_library(gtest STATIC IMPORTED GLOBAL)

set_target_properties(
  gmock PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${GOOGLETEST_ROOT}/googlemock/include)

set_target_properties(
  gtest PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${GOOGLETEST_ROOT}/googletest/include)

set(GOOGLETEST_CMAKE_FORWARD_ARGS ${CMAKE_CXX_FORWARD_ARGS})

if (WIN32)
  set(GOOGLETEST_COMPILE_DEFINITIONS
    # Silence deprecation warning in the interface of Google Test.
    _SILENCE_TR1_NAMESPACE_DEPRECATION_WARNING
    # Build in C++11 mode.
    GTEST_LANG_CXX11=1)

  set_target_properties(
    gtest PROPERTIES
    INTERFACE_COMPILE_DEFINITIONS "${GOOGLETEST_COMPILE_DEFINITIONS}")

  if (CMAKE_GENERATOR MATCHES "Visual Studio")
    set_target_properties(
      gmock PROPERTIES
      IMPORTED_LOCATION_DEBUG ${GOOGLETEST_ROOT}-build/googlemock/Debug/gmock${CMAKE_STATIC_LIBRARY_SUFFIX}
      IMPORTED_LOCATION_RELEASE ${GOOGLETEST_ROOT}-build/googlemock/Release/gmock${CMAKE_STATIC_LIBRARY_SUFFIX})

    set_target_properties(
      gtest PROPERTIES
      IMPORTED_LOCATION_DEBUG ${GOOGLETEST_ROOT}-build/googlemock/gtest/Debug/gtest${CMAKE_STATIC_LIBRARY_SUFFIX}
      IMPORTED_LOCATION_RELEASE ${GOOGLETEST_ROOT}-build/googlemock/gtest/Release/gtest${CMAKE_STATIC_LIBRARY_SUFFIX})
  else ()
    set_target_properties(
      gmock PROPERTIES
      IMPORTED_LOCATION ${GOOGLETEST_ROOT}-build/googlemock/gmock${CMAKE_STATIC_LIBRARY_SUFFIX})

    set_target_properties(
      gtest PROPERTIES
      IMPORTED_LOCATION ${GOOGLETEST_ROOT}-build/googlemock/gtest/gtest${CMAKE_STATIC_LIBRARY_SUFFIX})
  endif ()

  # Silence new deprecation warning in Visual Studio 15.5.
  # NOTE: This has been patched upstream, but we don't patch Google Test.
  # https://github.com/google/googletest/issues/1111
  list(APPEND GOOGLETEST_CMAKE_FORWARD_ARGS
    -DCMAKE_CXX_FLAGS=/D_SILENCE_TR1_NAMESPACE_DEPRECATION_WARNING)
else ()
  set_target_properties(
    gmock PROPERTIES
    IMPORTED_LOCATION ${GOOGLETEST_ROOT}-build/googlemock/libgmock${CMAKE_STATIC_LIBRARY_SUFFIX})

  set_target_properties(
    gtest PROPERTIES
    IMPORTED_LOCATION ${GOOGLETEST_ROOT}-build/googlemock/gtest/libgtest${CMAKE_STATIC_LIBRARY_SUFFIX})
endif ()

file(DOWNLOAD ${GOOGLETEST_PATCH_URL} ${CMAKE_CURRENT_BINARY_DIR}/${GOOGLETEST_PATCH_FILE})
patch_cmd(GOOGLETEST_PATCH_CMD ${CMAKE_CURRENT_BINARY_DIR}/${GOOGLETEST_PATCH_FILE})

MAKE_INCLUDE_DIR(gmock)
MAKE_INCLUDE_DIR(gtest)

GET_BYPRODUCTS(gmock)
GET_BYPRODUCTS(gtest)

# Unconditionally build static libraries.
list(APPEND GOOGLETEST_CMAKE_FORWARD_ARGS -DBUILD_SHARED_LIBS=OFF)

# But also link to the CRT dynamically.
list(APPEND GOOGLETEST_CMAKE_FORWARD_ARGS
  -Dgtest_force_shared_crt=ON)

ExternalProject_Add(
  ${GOOGLETEST_TARGET}
  PREFIX            ${GOOGLETEST_CMAKE_ROOT}
  BUILD_BYPRODUCTS  ${GMOCK_BYPRODUCTS};${GTEST_BYPRODUCTS}
  PATCH_COMMAND     ${GOOGLETEST_PATCH_CMD}
  CMAKE_ARGS        ${GOOGLETEST_CMAKE_FORWARD_ARGS}
  INSTALL_COMMAND   ${CMAKE_NOOP}
  URL               ${GOOGLETEST_URL}
  URL_HASH          ${GOOGLETEST_HASH})