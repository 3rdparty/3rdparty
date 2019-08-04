# This function works around a CMake issue with the Ninja generator where it
# does not understand imported libraries, and instead needs `BUILD_BYPRODUCTS`
# explicitly set.
# https://cmake.org/pipermail/cmake/2015-April/060234.html
function(GET_BYPRODUCTS TARGET)
  string(TOUPPER ${TARGET} NAME)
  if (CMAKE_GENERATOR MATCHES "Ninja")
    get_target_property(BYPRODUCTS ${TARGET} IMPORTED_LOCATION)
    set(${NAME}_BYPRODUCTS ${BYPRODUCTS} PARENT_SCOPE)
  else ()
    # Make this function a no-op when not using Ninja.
    set(${NAME}_BYPRODUCTS "" PARENT_SCOPE)
  endif()
endfunction()