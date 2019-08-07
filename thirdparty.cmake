include(ExternalProject) # For `ExternalProject_Add()`.

macro(THIRDPARTY_DOWNLOAD FILE)
  message(STATUS "Downloading 3rdparty/${FILE}")
  file(DOWNLOAD ${THIRDPARTY_URL}/${FILE} ${CMAKE_CURRENT_BINARY_DIR}/${FILE})
endmacro()

thirdparty_download(FindPackageHelper.cmake)
thirdparty_download(FindAPR.cmake)
thirdparty_download(FindSVN.cmake)

macro(THIRDPARTY_INCLUDE FILE)
  thirdparty_download(${FILE})
  include(${CMAKE_CURRENT_BINARY_DIR}/${FILE})
endmacro()

thirdparty_include(External.cmake)
thirdparty_include(GetByproducts.cmake)
thirdparty_include(MakeIncludeDir.cmake)
thirdparty_include(PatchCommand.cmake)


# Add the directory we downloaded to so we can use things like
# `FindAPR.cmake` and `FindSVN.cmake` with `find_package()` in the
# future.
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_BINARY_DIR})


############################## README ############################## 
#
# There are three variables that get set up that can be used by code
# that uses `ExternalProject_Add()`. These are:
#
#   CMAKE_NOOP
#   CMAKE_FORWARD_ARGS
#   CMAKE_SSL_FORWARD_ARGS
#
# Please read about each below for understanding when you might want
# to use them.
#
####################################################################

# Sets a variable CMAKE_NOOP as noop operation.
#
# NOTE: This is especially important when building third-party libraries on
# Windows; the default behavior of `ExternalProject` is to try to assume that
# third-party libraries can be configured/built/installed with CMake, so in
# cases where this isn't true, we have to "trick" CMake into skipping those
# steps by giving it a noop command to run instead.
set(CMAKE_NOOP ${CMAKE_COMMAND} -E echo)

# This `CMAKE_FORWARD_ARGS` variable is sent as the `CMAKE_ARGS` argument to
# the `ExternalProject_Add` macro (along with any per-project arguments), and
# is used when the external project is configured as a CMake project.
# If either the `CONFIGURE_COMMAND` or `BUILD_COMMAND` arguments of
# `ExternalProject_Add` are used, then the `CMAKE_ARGS` argument will be
# ignored.
#
# NOTE: The CMAKE_GENERATOR_TOOLSET is impliticly set by `ExternalProject_Add`,
# and cannot be included twice.
list(APPEND CMAKE_FORWARD_ARGS
  # TODO(andschwa): Set the CMAKE_GENERATOR explicitly as an argmuent to
  # `ExternalProject_Add`.
  -G${CMAKE_GENERATOR}
  -DCMAKE_POSITION_INDEPENDENT_CODE=${CMAKE_POSITION_INDEPENDENT_CODE}
  -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS})

# This only matters for single-configuration generators.
# E.g. Makefile, but not Visual Studio.
if (NOT "${CMAKE_BUILD_TYPE}" STREQUAL "")
  list(APPEND CMAKE_FORWARD_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE})
endif ()

foreach (lang C CXX)
  list(APPEND CMAKE_${lang}_FORWARD_ARGS
    ${CMAKE_FORWARD_ARGS}
    -DCMAKE_${lang}_COMPILER=${CMAKE_${lang}_COMPILER}
    -DCMAKE_${lang}_COMPILER_LAUNCHER=${CMAKE_${lang}_COMPILER_LAUNCHER}
    -DCMAKE_${lang}_FLAGS=${CMAKE_${lang}_FLAGS})

  foreach (config DEBUG RELEASE RELWITHDEBINFO MINSIZEREL)
    list(APPEND CMAKE_${lang}_FORWARD_ARGS
      -DCMAKE_${lang}_FLAGS_${config}=${CMAKE_${lang}_FLAGS_${config}})
  endforeach ()
endforeach ()


# Set up CMAKE_SSL_FORWARD_ARGS for calls to `ExternalProject_Add()`.
if (OPENSSL_ROOT_DIR)
  list(APPEND CMAKE_SSL_FORWARD_ARGS
    -DOPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR})
endif ()
if (OPENSSL_USE_STATIC_LIBS)
  list(APPEND CMAKE_SSL_FORWARD_ARGS
    -DOPENSSL_USE_STATIC_LIBS=${OPENSSL_USE_STATIC_LIBS})
endif ()
if (OPENSSL_MSVC_STATIC_RT)
  list(APPEND CMAKE_SSL_FORWARD_ARGS
    -DOPENSSL_MSVC_STATIC_RT=${OPENSSL_MSVC_STATIC_RT})
endif ()


# NOTE: this is defined as a macro so that the definitions we set are
# availble to parent scope since we call `include()` and need those
# definitions available as well.
macro(THIRDPARTY NAME)
  string(REPLACE "-" "_" NAME ${NAME})
  string(TOUPPER ${NAME} NAME_UPPER)
  string(TOLOWER ${NAME} NAME_LOWER)

  message

  message(STATUS "NAME is ${NAME}")
  message(STATUS "NAME_LOWER is ${NAME_LOWER}")
  message(STATUS "NAME_UPPER is ${NAME_UPPER}")

  set(THIRDPARTY_KEYWORDS VERSION HASH)

  cmake_parse_arguments(THIRDPARTY_ARGS "" "${THIRDPARTY_KEYWORDS}" "" ${ARGN})

  # Set VERSION variable, e.g., `BOOST_VERSION` and export to parent scope.
  if (THIRDPARTY_ARGS_VERSION)
    set(VERSION_VARIABLE ${NAME_UPPER}_VERSION)
    set(${VERSION_VARIABLE} ${THIRDPARTY_ARGS_VERSION})
  endif ()

  # Set HASH variable, e.g., `BOOST_HASH` and export to parent scope.
  if (THIRDPARTY_ARGS_HASH)
    set(HASH_VARIABLE ${NAME_UPPER}_HASH)
    set(${HASH_VARIABLE} ${THIRDPARTY_ARGS_HASH})
  endif ()

  # Download the cmake specifics for this package.
  set(THIRDPARTY_CMAKE_FILE ${NAME_LOWER}-${THIRDPARTY_ARGS_VERSION}.cmake)
  set(THIRDPARTY_CMAKE_URL ${THIRDPARTY_URL}/${THIRDPARTY_CMAKE_FILE})
  message(STATUS "Downloading 3rdparty/${THIRDPARTY_CMAKE_FILE}")
  file(DOWNLOAD ${THIRDPARTY_CMAKE_URL} ${CMAKE_CURRENT_BINARY_DIR}/${THIRDPARTY_CMAKE_FILE})
  include(${CMAKE_CURRENT_BINARY_DIR}/${THIRDPARTY_CMAKE_FILE})
endmacro()
