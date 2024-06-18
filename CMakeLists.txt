cmake_minimum_required(VERSION 3.16)

project(stitcher VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(WIN32)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        set(OpenCV_DIR ${CMAKE_CURRENT_SOURCE_DIR}/opencv/windows/mingw)
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set(OpenCV_DIR ${CMAKE_CURRENT_SOURCE_DIR}/opencv/windows/msvc)
    endif()
elseif(ANDROID)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        if(CMAKE_ANDROID_ARCH_ABI STREQUAL "x86")
            set(OpenCV_DIR ${CMAKE_CURRENT_SOURCE_DIR}/opencv/android/clang_x86/sdk/native/jni)
        elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "x86_64")
            set(OpenCV_DIR ${CMAKE_CURRENT_SOURCE_DIR}/opencv/android/clang_x86_64/sdk/native/jni)
        elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "armeabi-v7a")
            message("armeabi-v7a")
            set(OpenCV_DIR ${CMAKE_CURRENT_SOURCE_DIR}/opencv/android/clang_armeabi_v7a/sdk/native/jni)
        elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "arm64-v8a")
            message("arm64-v8a")
            set(OpenCV_DIR ${CMAKE_CURRENT_SOURCE_DIR}/opencv/android/clang_arm64_v8a/sdk/native/jni)
        endif()
    endif()
 elseif(UNIX AND NOT APPLE)
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set(OpenCV_DIR ${CMAKE_CURRENT_SOURCE_DIR}/opencv/linux/gcc/lib/cmake/opencv4)
    endif()
elseif(APPLE)
    if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
      set(OpenCV_DIR ${CMAKE_CURRENT_SOURCE_DIR}/opencv/macx/lib/cmake/opencv4)
    endif()
endif()

find_package(Felgo REQUIRED)

# Project identifier and version
# More information: https://felgo.com/doc/felgo-publishing/#project-configuration
set(PRODUCT_IDENTIFIER "com.yourcompany.wizardEVAP.Stitcher")
set(PRODUCT_VERSION_NAME "1.0.0")
set(PRODUCT_VERSION_CODE 1)

# Set either "test" or "publish" stage:
set(PRODUCT_STAGE "test")

# Optionally set a license key that is used instead of the license key from
# main.qml file (App::licenseKey for your app or GameWindow::licenseKey for your game)
# Only used for local builds and Felgo Cloud Builds (https://felgo.com/cloud-builds)
# Not used if using Felgo Live
set(PRODUCT_LICENSE_KEY "834F8439DF6B0A5DE65DE651F03962413E388178744B173917303D2415CBB3FA169127E6B0FCFDF8ED59B3C20BADD83D191955E2F42D6C41EF58800E5D7CCF6681F7532B3DC2146EF26E7264E1D6059544C1F13F5A87C1D8BBB9C91E47684D47ECEB45AA91A28B5BDA4EEBCA137AA464909351D46B4842A1242ABF6199F49A896857DE26D901A3AE8C5AE6FAD73C6D218BEDE54CA142A81678885414BF63166A9833F7521CA7FA26856690E795052854C21D130421200EA299FDF8339F100B06F95E5F253ABD87EC41C7F99E97F39E5D682730B116A4F774EFAD8DD27EF74FA7F8C6373A98AE9244D24A90F2C70C5185E557213234FC8173A3EA77C83F707535346C47C2833B3489493E6796ED4A56A99E2A108DDDEB39DB8B319B8080E270F74C530CBABE2E7FC8D3568F0DEDCAA80284EA87A9CEDCD4529099E53F5D9A65DF")

set(FELGO_PLUGINS
)

# Find all QML/JS files for the QML compiler:
file(GLOB_RECURSE QmlFiles RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} qml/*.qml qml/*.js)

# Find all non-QML/JS files in the qml and assets folder to add as resources:
file(GLOB_RECURSE AssetsFiles RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} assets/* qml/*)
list(REMOVE_ITEM AssetsFiles ${QmlFiles})

qt_add_executable(appstitcher
    main.cpp
    process.h
    process.cpp
    ${QmlFiles}
    ${AssetsFiles}
)

felgo_configure_executable(appstitcher)

# Deploy resources to build folder/package directly
# comment for publishing
deploy_resources("${QmlFiles};${AssetsFiles}")

# Add QML files and resources to QML module to included them via QRC automatically:
qt_add_qml_module(appstitcher
    URI stitcher
    VERSION 1.0
# uncomment for publishing:
#    QML_FILES ${QmlFiles}
#    RESOURCES ${AssetsFiles}
    NO_RESOURCE_TARGET_PATH
)

# NOTE: for PUBLISHING, perform the following steps:
# 1. comment the deploy_resources line above, to avoid shipping your qml files with the application (instead they get compiled to the app binary)
# 2. uncomment the QML_FILES and RESOURCES above; this compiles your qml files and js files to the app binary and protects your source code
# 3. change the setMainQmlFile() call in main.cpp to the one starting with "qrc:/" - this loads the qml files from the resources
# for more details see the "Deployment Guides" in the Felgo Documentation

# during development, use the deploy_resources because you then get shorter compilation times (the qml files do not need to be compiled to the binary but are just copied)
# also, for quickest deployment on Desktop disable the "Shadow Build" option in Projects/Builds - you can then select "Run Without Deployment" from the Build menu in Qt Creator if you only changed QML files; this speeds up application start, because your app is not copied & re-compiled but just re-interpreted

target_compile_definitions(appstitcher
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

find_package( OpenCV REQUIRED )
include_directories( ${OpenCV_INCLUDE_DIRS} )

target_link_libraries(appstitcher PRIVATE ${OpenCV_LIBS})
target_link_libraries(appstitcher PRIVATE Felgo)

# uncomment this line to add the Live Client Module and use live reloading with your custom C++ code
# for the remaining steps to build a custom Live Code Reload app see here: https://felgo.com/custom-code-reload-app/
#find_package(FelgoLive REQUIRED)
#target_link_libraries(appstitcher PRIVATE FelgoLive)
