cmake_minimum_required(VERSION 3.10)

project(Protobuf-Package)

# Package Protobuf.zip
configure_file("${CMAKE_CURRENT_LIST_DIR}/config.cmake" "${CMAKE_BINARY_DIR}/protobuf-${PROTOBUF_VERSION}/protobuf/config.cmake" COPYONLY)
if(NOT EXISTS "${CMAKE_BINARY_DIR}/protoc-${PROTOBUF_VERSION}.zip")
    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        file(DOWNLOAD https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip "${CMAKE_BINARY_DIR}/protoc-${PROTOBUF_VERSION}.zip" SHOW_PROGRESS)
        set(PROTOC_EXECUTABLE "protoc")
    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        file(DOWNLOAD https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-win64.zip "${CMAKE_BINARY_DIR}/protoc-${PROTOBUF_VERSION}.zip" SHOW_PROGRESS)
        set(PROTOC_EXECUTABLE "protoc.exe")
    endif()
endif()
if(NOT EXISTS "${CMAKE_BINARY_DIR}/protoc-${PROTOBUF_VERSION}")
    file(ARCHIVE_EXTRACT INPUT "${CMAKE_BINARY_DIR}/protoc-${PROTOBUF_VERSION}.zip" DESTINATION "${CMAKE_BINARY_DIR}/protoc-${PROTOBUF_VERSION}")
    configure_file("${CMAKE_BINARY_DIR}/protoc-${PROTOBUF_VERSION}/bin/${PROTOC_EXECUTABLE}" "${CMAKE_BINARY_DIR}/protobuf-${PROTOBUF_VERSION}/protobuf/bin/${PROTOC_EXECUTABLE}" COPYONLY)
endif()
add_custom_target(
    zip_protobuf ALL
    COMMAND ${CMAKE_COMMAND} -E tar cfv "${CMAKE_BINARY_DIR}/${PACKAGE_NAME}" --format=zip .
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/protobuf-${PROTOBUF_VERSION}"
)
