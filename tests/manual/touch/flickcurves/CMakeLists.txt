cmake_minimum_required(VERSION 3.21)
project(FlickCurves VERSION 1.0 LANGUAGES CXX)

find_package(Qt6 6.12 REQUIRED COMPONENTS Quick QuickControls2 QuickLayouts)
qt_standard_project_setup(REQUIRES 6.12)

qt_add_executable(flickcurves MANUAL_FINALIZATION MACOSX_BUNDLE main.cpp)
target_link_libraries(flickcurves PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::QuickLayouts)
qt_import_plugins(flickcurves INCLUDE Qt6::QJpegPlugin)

qt_add_resources(flickcurves "flickcurves_qml"
    PREFIX "/"
    BASE "${CMAKE_CURRENT_SOURCE_DIR}/.."
    FILES "${CMAKE_CURRENT_SOURCE_DIR}/../flickcurves.qml"
)

set(photo_dir "${CMAKE_CURRENT_SOURCE_DIR}/../../../../examples/quick/views/listview/content/pics")
qt_add_resources(flickcurves "flickcurves_photos"
    PREFIX "/examples/quick/views/listview/content/pics"
    BASE "${photo_dir}"
    FILES
        "${photo_dir}/lemonade.jpg"
        "${photo_dir}/fruit-salad.jpg"
        "${photo_dir}/hamburger.jpg"
        "${photo_dir}/vegetable-soup.jpg"
        "${photo_dir}/pancakes.jpg"
)

set_target_properties(flickcurves PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER "org.qtproject.manual.flickcurves"
    MACOSX_BUNDLE_BUNDLE_NAME "Flick Curves"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}"
    MACOSX_BUNDLE_BUNDLE_VERSION "1"
    XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2"
)

if(IOS)
    set_target_properties(flickcurves PROPERTIES
        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/Info.plist.in"
    )
endif()

qt_finalize_executable(flickcurves)
