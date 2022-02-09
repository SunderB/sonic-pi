cmake_minimum_required(VERSION 3.13)

set(APP_ROOT ${CMAKE_CURRENT_LIST_DIR}/app)

### Compiler configuration
# Sonic Pi Requires a C++ 17 Compiler to build it
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if(APPLE)
  set(CMAKE_OSX_DEPLOYMENT_TARGET '10.14')
endif()

### Editor configuration
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})

### vcpkg configuration
# Different triplet for windows
if (WIN32)
    set(VCPKG_TARGET_TRIPLET x64-windows-static-md CACHE STRING "triplet")
endif()

# vcpkg toolchain - Must be declared before project
set(CMAKE_TOOLCHAIN_FILE ${APP_ROOT}/vcpkg/scripts/buildsystems/vcpkg.cmake CACHE STRING "Vcpkg toolchain file")
message(STATUS "CMAKE_TOOLCHAIN_FILE: ${CMAKE_TOOLCHAIN_FILE}")

### Project information
project("Sonic Pi"
  LANGUAGES CXX C
  DESCRIPTION "A code-based music creation and performance tool"
  VERSION 4.0.0
  HOMEPAGE_URL "https://sonic-pi.net"
)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/cmake)
include(cmake/utils.cmake)
include(cmake/common.cmake)

set(RUBY_CMD "ruby")

### Add subdirectories
add_subdirectory(app)