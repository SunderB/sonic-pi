# native libraries & executables
install(
    DIRECTORY native/ 
    DESTINATION ${SERVER_INSTALL_DIR}/native
    COMPONENT sonic_pi_server
    USE_SOURCE_PERMISSIONS
    PATTERN "native/ruby/share" EXCLUDE
)

add_subdirectory(beam)
add_subdirectory(ruby)