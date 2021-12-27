cmake_minimum_required(VERSION 3.13)

message(STATUS " CMakeLists: Sonic Pi")

set(APP_ROOT ${CMAKE_CURRENT_LIST_DIR})

list(APPEND CMAKE_MODULE_PATH ${APP_ROOT}/cmake)
include(cmake/utils.cmake)
include(cmake/common.cmake)

configure_file(${APP_ROOT}/cmake/config.h.cmake ${CMAKE_BINARY_DIR}/config.h)

#add_subdirectory(external)
add_subdirectory(server)
add_subdirectory(api)
add_subdirectory(api-tests)
add_subdirectory(gui)




