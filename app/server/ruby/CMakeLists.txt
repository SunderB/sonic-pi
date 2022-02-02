message(INFO "Compiling native ruby extensions...")
execute_process(
    COMMAND ${RUBY_CMD} bin/compile-extensions.rb
    WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
)

message(INFO "Translating tutorial...")
execute_process(
  COMMAND ${RUBY_CMD} bin/i18n-tool.rb -t
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
)

message(INFO "Generating docs for the Qt GUI...")
execute_process(
  COMMAND cp ../../gui/qt/utils/ruby_help.tmpl "${CMAKE_CURRENT_BINARY_DIR}"/../../gui/qt/utils/ruby_help.h
    ${RUBY_CMD} bin/qt-doc.rb -o "${CMAKE_CURRENT_BINARY_DIR}"/../../gui/qt/utils/ruby_help.h
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
)