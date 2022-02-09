add_subdirectory(beam)

get_filename_component(QT_GUI_PATH "../gui/qt" ABSOLUTE)

message(STATUS "Compiling native ruby extensions...")
execute_process(
    COMMAND ${RUBY_CMD} ruby/bin/compile-extensions.rb
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
)

message(STATUS "Translating tutorial...")
execute_process(
    COMMAND ${RUBY_CMD} ruby/bin/i18n-tool.rb -t
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
)

message(STATUS "Generating docs for the Qt GUI...")
configure_file(${QT_GUI_PATH}/utils/ruby_help.tmpl ${QT_GUI_PATH}/utils/ruby_help.h)
execute_process(
    COMMAND ${RUBY_CMD} ruby/bin/qt-doc.rb -o ${QT_GUI_PATH}/utils/ruby_help.h
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
)