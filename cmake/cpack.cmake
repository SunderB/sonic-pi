### CPack Configuration
set(CPACK_PACKAGE_NAME "Sonic Pi")
set(CPACK_PACKAGE_VENDOR "sonic-pi.net")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Sonic Pi - The Live Coding Music Synth for Everyone")
set(CPACK_PACKAGE_VERSION ${CMAKE_PROJECT_VERSION})
set(CPACK_PACKAGE_VERSION_MAJOR ${CMAKE_PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${CMAKE_PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${CMAKE_PROJECT_VERSION_PATCH})
set(CPACK_PACKAGE_INSTALL_DIRECTORY "Sonic Pi")
set(CPACK_PACKAGE_FILE_NAME "sonic-pi-${CPACK_PACKAGE_VERSION}-${CMAKE_SYSTEM_PROCESSOR}")
set(CPACK_PACKAGE_DIRECTORY ${CMAKE_BINARY_DIR}/packages)


if(CPACK_GENERATOR MATCHES "DEB")
    # .deb package for Debian, Ubuntu, and derivatives
    # See https://cmake.org/cmake/help/latest/cpack_gen/deb.html for more info.
    set(CPACK_PACKAGE_EXECUTABLES "app/gui/qt/sonic-pi;Sonic Pi")

    # Set the generated package to install to the /opt prefix on Linux, 
    # since Sonic Pi doesn't work well with FHS yet
    set(CPACK_PACKAGING_INSTALL_PREFIX "/opt/sonic-pi")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libssl, git, ruby (>= 2.7.0), elixir (>= 1.12), erlang-base (>= 24), libqt5svg5, supercollider-server, sc3-plugins-server, alsa-utils, jackd2, libjack-jackd2-0, pulseaudio-module-jack, librtmidi")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Sonic Pi Core Team (https://sonic-pi.net)")
    set(CPACK_DEBIAN_PACKAGE_RELEASE "1")

    # if(${CMAKE_SYSTEM_PROCESSOR} MATCHES x86_64)
    #     set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
    # elseif (${CMAKE_SYSTEM_PROCESSOR} MATCHES x86)
    #     set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "i386")
    # endif()

    set(CPACK_DEBIAN_PACKAGE_NAME "sonic-pi-${CPACK_DEBIAN_PACKAGE_VERSION}-${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}")
elseif(CPACK_GENERATOR MATCHES "BUNDLE")
    # macOS bundle installer
    # TODO
elseif(CPACK_GENERATOR MATCHES "WIX")
    # WiX installer for Windows
    # See https://cmake.org/cmake/help/latest/cpack_gen/wix.html for more info.
    set(WIX_FILES_DIR ${CMAKE_SOURCE_DIR}/install/windows/wix)
    
    set(CPACK_PACKAGE_EXECUTABLES "app/gui/qt/sonic-pi.exe;Sonic Pi")
    set(CPACK_WIX_UPGRADE_GUID "ECA5D03B-CEBD-4672-A0A2-176CBCBA4429")
    #set(CPACK_WIX_PRODUCT_GUID) - this is generated randomly
    set(CPACK_WIX_LICENSE_RTF "${WIX_FILES_DIR}/LICENSE.rtf")
    set(CPACK_WIX_PRODUCT_ICON "${CMAKE_SOURCE_DIR}/app/gui/qt/images/icon.ico")
    set(CPACK_WIX_UI_BANNER "${WIX_FILES_DIR}/wix_ui_banner.bmp")
    set(CPACK_WIX_UI_DIALOG "${WIX_FILES_DIR}/wix_ui_dialog.bmp")
    set(CPACK_WIX_PROGRAM_MENU_FOLDER ".") # Start Menu folder - put the shortcut in the root of the folder
    set(CPACK_WIX_PROPERTY_ARPCONTACT "https://in-thread.sonic-pi.net")
    set(CPACK_WIX_PROPERTY_ARPHELPLINK "https://in-thread.sonic-pi.net")
    set(CPACK_WIX_PROPERTY_ARPURLINFOABOUT "https://sonic-pi.net")
endif()

# This must always be last!
include(CPack)

# Configure components
cpack_add_component(sonic_pi_resources  DISPLAY_NAME "Sonic Pi Resources" REQUIRED)
cpack_add_component(sonic_pi_server     DISPLAY_NAME "Sonic Pi Server" REQUIRED DEPENDS sonic_pi_resources)
cpack_add_component(sonic_pi_api        DISPLAY_NAME "Sonic Pi API" REQUIRED DEPENDS sonic_pi_server)
cpack_add_component(sonic_pi_qt_gui     DISPLAY_NAME "Sonic Pi Qt GUI" REQUIRED DEPENDS sonic_pi_server sonic_pi_api)
cpack_add_component(sonic_pi_imgui_gui  DISPLAY_NAME "Sonic Pi Imgui GUI (Experimental)" HIDDEN DEPENDS sonic_pi_server sonic_pi_api)
