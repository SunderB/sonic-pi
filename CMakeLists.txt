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
  VERSION 4.0.0.beta
  HOMEPAGE_URL "https://sonic-pi.net"
)

list(APPEND CMAKE_MODULE_PATH ${APP_ROOT}/cmake)
include(cmake/utils.cmake)
include(cmake/common.cmake)

### Installation directories
set(SERVER_INSTALL_DIR app/server)
set(ETC_INSTALL_DIR etc)
set(API_INSTALL_DIR app/api)
set(GUI_INSTALL_DIR app/gui)

if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    if(WIN32)
    # Windows
        set(CMAKE_INSTALL_PREFIX "C:/Program Files/Sonic Pi" CACHE PATH "..." FORCE)
    elseif(${CMAKE_SYSTEM_NAME} MATCHES Darwin)
    # macOS
        # TODO
        # set(ROOT_INSTALL_DIR "/opt/sonic-pi")
    else()
        # Assume this is Linux
        # Set the default install prefix to /opt on Linux, since Sonic Pi
        # doesn't work well with FHS yet
        set(CMAKE_INSTALL_PREFIX "/opt/sonic-pi" CACHE PATH "..." FORCE)
    endif()
endif()

### Add subdirectories
add_subdirectory(app)
add_subdirectory(etc)

if ("${CMAKE_SYSTEM_NAME}" MATCHES Linux)
    option(SPI_INSTALL_DESKTOP_FILE "Toggle if the desktop file should be installed" OFF)
    message(INFO "Install desktop file: ${SPI_INSTALL_DESKTOP_FILE}")
    if (SPI_INSTALL_DESKTOP_FILE)
        configure_file(install/linux/sonic-pi.desktop.tmpl install/linux/sonic-pi.desktop)
        install(FILES install/linux/sonic-pi.desktop DESTINATION /usr/share/applications)
    endif()
endif()

include(cmake/cpack.cmake)


