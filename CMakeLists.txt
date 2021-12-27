cmake_minimum_required(VERSION 3.13)

set(APP_ROOT ${CMAKE_CURRENT_LIST_DIR}/app)

# Sonic Pi Requires a C++ 17 Compiler to build it
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

if(APPLE)
  set(CMAKE_OSX_DEPLOYMENT_TARGET '10.14')
endif()

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR} PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})

# Different triplet for windows
if (WIN32)
    set(VCPKG_TARGET_TRIPLET x64-windows-static-md CACHE STRING "triplet")
endif()

# vcpkg toolchain - Must be declared before project
set(CMAKE_TOOLCHAIN_FILE ${APP_ROOT}/vcpkg/scripts/buildsystems/vcpkg.cmake CACHE STRING "Vcpkg toolchain file")
message(STATUS "CMAKE_TOOLCHAIN_FILE: ${CMAKE_TOOLCHAIN_FILE}")

project(SonicPi)

set(SERVER_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/app/server)
set(ETC_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/etc)
set(API_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/app/api)
set(GUI_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/app/gui)

# Set installation directories
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    if(WIN32)
    # Windows
        set(CMAKE_INSTALL_PREFIX "C:/Program Files/Sonic Pi" CACHE PATH "..." FORCE)
    elseif(${CMAKE_SYSTEM_NAME} MATCHES Darwin)
    # macOS
        # TODO
        # set(ROOT_INSTALL_DIR "/opt/sonic-pi")
    else()
        # assume Linux
        set(CMAKE_INSTALL_PREFIX "/opt/sonic-pi" CACHE PATH "..." FORCE)
    endif()
endif()

add_subdirectory(app)
add_subdirectory(etc)