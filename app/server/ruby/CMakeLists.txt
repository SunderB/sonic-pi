set(SOURCE_ROOT ${CMAKE_CURRENT_SOURCE_DIR})
set(SOURCES
    ${SOURCE_ROOT}/core.rb
    ${SOURCE_ROOT}/paths.rb
    ${SOURCE_ROOT}/util.rb
)

install(DIRECTORY bin/ DESTINATION ${SERVER_INSTALL_DIR}/ruby/bin USE_SOURCE_PERMISSIONS COMPONENT sonic_pi_server)
install(DIRECTORY lib/ DESTINATION ${SERVER_INSTALL_DIR}/ruby/lib USE_SOURCE_PERMISSIONS COMPONENT sonic_pi_server)
install(
    DIRECTORY rb-native/
    DESTINATION ${SERVER_INSTALL_DIR}/ruby/rb-native
    COMPONENT sonic_pi_server
    USE_SOURCE_PERMISSIONS
)
install(
    DIRECTORY vendor/
    DESTINATION ${SERVER_INSTALL_DIR}/ruby/vendor
    COMPONENT sonic_pi_server
    USE_SOURCE_PERMISSIONS
)
install(
    FILES ${SOURCES}
    DESTINATION ${SERVER_INSTALL_DIR}/ruby/
    COMPONENT sonic_pi_server
)