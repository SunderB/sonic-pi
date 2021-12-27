
install(DIRECTORY native/ DESTINATION ${SERVER_INSTALL_DIR}/native USE_SOURCE_PERMISSIONS)

add_subdirectory(beam)
add_subdirectory(ruby)