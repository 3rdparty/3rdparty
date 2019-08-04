# 3rdparty

WIP

Basic idea is that if you include the file `thirdparty.cmake` in your
build then you can specify 3rdparty packages that you need and they
will get automagically downloaded and built for you. This is similar
to the hunter package manager but designed to be A LOT simplier, i.e.,
we don't do anything smart to cache things built multiple times across
different projects, etc.

This originated from the Apache Mesos code base where we refactored
and extracted bits to make it work. It's still early days and there is
a lot that needs to be done.

Basic usage, inside your `CMakeLists.txt` you'll do:

```
set(THIRDPARTY_URL "https://github.com/3rdparty/3rdparty/raw/master")
set(LIBRARY_LINKAGE STATIC)
set(LIBRARY_SUFFIX ${CMAKE_STATIC_LIBRARY_SUFFIX})

include(thirdparty)

thirdparty(
  boost
  VERSION 1.65.0
  HASH SHA256=0442df595dc56e7da11665120ce9d92ec40c192eb060488131b346bac0938ba3)

thirdparty(
  glog
  VERSION 0.4.0
  HASH SHA256=F28359AEBA12F30D73D9E4711EF356DC842886968112162BC73002645139C39C)
```

Eventually we'll want to be able do set up things declaratively like:
```
thirdparty(
  grpc
  VERSION 0.4.0
  HASH SHA256=F28359AEBA12F30D73D9E4711EF356DC842886968112162BC73002645139C39C
  USE_LOCAL_OR_EXTERNAL
  LINK static
  DEPENDS zlib protobuf)
```

## Adding Packages

When writing your own packages you can expect the following variables
to be useful:

```
CMAKE_NOOP
CMAKE_FORWARD_ARGS
CMAKE_SSL_FORWARD_ARGS
```

Your `.cmake` file will be invoked after the invocation of
`thirdparty()` and there will also be the following variables for you
to use (including the versions of these variables for other packages
that will have already been configured via `thirdparty()`):

```
PACKAGE_VERSION
PACKAGE_HASH
PACKAGE_TARGET         # Target folder where the package will be put.
PACKAGE_CMAKE_ROOT     # Where cmake will put the uncompressed source.
PACKAGE_ROOT           # Where things will be put during the various build stages.
```

These may be useful for creating a `.cmake` file for your package.