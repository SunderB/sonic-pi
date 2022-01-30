cmake_minimum_required(VERSION 3.13)

message(STATUS " CMakeLists: Sonic Pi")

configure_file(${APP_ROOT}/cmake/config.h.cmake ${CMAKE_BINARY_DIR}/config.h)

#add_subdirectory(external)
add_subdirectory(server)
add_subdirectory(api)
add_subdirectory(api-tests)
add_subdirectory(gui)