project(tau)

set(SOURCE_ROOT ${CMAKE_CURRENT_LIST_DIR}tau/src)
set(PRIV_ROOT ${CMAKE_CURRENT_LIST_DIR}/tau/priv)

set(SOURCES
    ${SOURCE_ROOT}/osc/osc.erl
    ${SOURCE_ROOT}/osc/osc_tests.erl
    ${SOURCE_ROOT}/sp_link/sp_link.erl
    ${SOURCE_ROOT}/sp_link/sp_link_test.erl
    ${SOURCE_ROOT}/sp_midi/sp_midi.erl
    ${SOURCE_ROOT}/sp_midi/sp_midi_test.erl
    ${SOURCE_ROOT}/tau_server/tau_server.erl
    ${SOURCE_ROOT}/tau_server/tau_keepalive.erl
    ${SOURCE_ROOT}/tau_server/tau_server_api.erl
    ${SOURCE_ROOT}/tau_server/tau_server_app.erl
    ${SOURCE_ROOT}/tau_server/tau_server_cue.erl
    ${SOURCE_ROOT}/tau_server/tau_server_link.erl
    ${SOURCE_ROOT}/tau_server/tau_server_midi_in.erl
    ${SOURCE_ROOT}/tau_server/tau_server_midi_out.erl
    ${SOURCE_ROOT}/tau_server/tau_server_midi.erl
    ${SOURCE_ROOT}/tau_server/tau_server_sup.erl
    ${SOURCE_ROOT}/tau_server/tau_server_tracker.erl
)
set(DEP_LIBRARIES
    ${PRIV_ROOT}/libsp_link.so
    ${PRIV_ROOT}/libsp_midi.so
)

add_custom_target(tau ALL
    cmake -E env MIX_ENV=prod mix local.hex --force
    COMMAND cmake -E env MIX_ENV=prod mix local.rebar --force
    COMMAND cmake -E env MIX_ENV=prod mix deps.get
    COMMAND cmake -E env MIX_ENV=prod mix assets.deploy
    COMMAND cmake -E env MIX_ENV=prod mix release --overwrite
    COMMAND cmake -E copy src/tau.app.src ebin/tau.app
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/tau
)
install(
    DIRECTORY tau/
    DESTINATION ${SERVER_INSTALL_DIR}/beam/tau
    USE_SOURCE_PERMISSIONS
    COMPONENT sonic_pi_server
)