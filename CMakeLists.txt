cmake_minimum_required(VERSION 3.22)

project(plasma-keyboard LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

find_package(ECM 6.0.0 REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH})

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml DBus GuiPrivate)
find_package(KF6CoreAddons REQUIRED)
find_package(KF6I18n REQUIRED)
find_package(PkgConfig REQUIRED)
find_package(Wayland REQUIRED COMPONENTS Client)

pkg_check_modules(WAYLAND_CLIENT REQUIRED wayland-client)
find_program(WAYLAND_SCANNER_EXECUTABLE NAMES wayland-scanner REQUIRED)

# Generate Wayland virtual keyboard protocol C/H files
set(PROTOCOL_XML "${CMAKE_CURRENT_SOURCE_DIR}/src/protocols/virtual-keyboard-unstable-v1.xml")
set(PROTOCOL_CODE "${CMAKE_CURRENT_BINARY_DIR}/virtual-keyboard-unstable-v1-protocol.c")
set(PROTOCOL_HEADER "${CMAKE_CURRENT_BINARY_DIR}/virtual-keyboard-unstable-v1-client-protocol.h")

add_custom_command(
    OUTPUT ${PROTOCOL_HEADER}
    COMMAND ${WAYLAND_SCANNER_EXECUTABLE} client-header ${PROTOCOL_XML} ${PROTOCOL_HEADER}
    DEPENDS ${PROTOCOL_XML}
)

add_custom_command(
    OUTPUT ${PROTOCOL_CODE}
    COMMAND ${WAYLAND_SCANNER_EXECUTABLE} private-code ${PROTOCOL_XML} ${PROTOCOL_CODE}
    DEPENDS ${PROTOCOL_XML}
)

# Optional LayerShellQt support
find_package(LayerShellQt)

qt_add_executable(plasma-keyboard
    src/main.cpp
    src/keyboardcontroller.cpp
    src/keyboardcontroller.h
    src/waylandvirtualkeyboard.cpp
    src/waylandvirtualkeyboard.h
    src/gestureengine.cpp
    src/gestureengine.h
    src/klipperintegration.cpp
    src/klipperintegration.h
    ${PROTOCOL_CODE}
    ${PROTOCOL_HEADER}
)

target_include_directories(plasma-keyboard PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(plasma-keyboard PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::GuiPrivate
    Qt6::Quick
    Qt6::Qml
    Qt6::DBus
    KF6::CoreAddons
    KF6::I18n
    Wayland::Client
)

if(LayerShellQt_FOUND)
    target_link_libraries(plasma-keyboard PRIVATE LayerShellQt::Interface)
    target_compile_definitions(plasma-keyboard PRIVATE HAVE_LAYERSHELLQT=1)
endif()

qt_add_qml_module(plasma-keyboard
    URI "org.kde.plasma.keyboard"
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/KeyButton.qml
        qml/SwipeCanvas.qml
        qml/DPadPanel.qml
        qml/TouchBarView.qml
        qml/themes/BreezeDark.qml
        qml/themes/TeenageOP1.qml
        qml/themes/NothingDark.qml
        qml/themes/NothingLight.qml
)

install(TARGETS plasma-keyboard DESTINATION bin)
