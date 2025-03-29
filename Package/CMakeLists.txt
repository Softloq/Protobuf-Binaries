cmake_minimum_required(VERSION 3.10)

project(Protobuf-Package)

# Package Protobuf.zip
configure_file("${CMAKE_CURRENT_LIST_DIR}/protobuf.cmake" "${CMAKE_BINARY_DIR}/protobuf-$ENV{PROTOBUF_VERSION}/protobuf/protobuf.cmake" COPYONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/copy_dll.cmake" "${CMAKE_BINARY_DIR}/protobuf-$ENV{PROTOBUF_VERSION}/protobuf/copy_dll.cmake" COPYONLY)
if(NOT EXISTS "${CMAKE_BINARY_DIR}/protoc-$ENV{PROTOBUF_VERSION}.zip")
    file(DOWNLOAD https://github.com/protocolbuffers/protobuf/releases/download/v$ENV{PROTOBUF_VERSION}/protoc-$ENV{PROTOBUF_VERSION}-win64.zip "${CMAKE_BINARY_DIR}/protoc-$ENV{PROTOBUF_VERSION}.zip" SHOW_PROGRESS)
endif()
if(NOT EXISTS "${CMAKE_BINARY_DIR}/protoc-$ENV{PROTOBUF_VERSION}")
    file(ARCHIVE_EXTRACT INPUT "${CMAKE_BINARY_DIR}/protoc-$ENV{PROTOBUF_VERSION}.zip" DESTINATION "${CMAKE_BINARY_DIR}/protoc-$ENV{PROTOBUF_VERSION}")
    configure_file("${CMAKE_BINARY_DIR}/protoc-$ENV{PROTOBUF_VERSION}/bin/protoc.exe" "${CMAKE_BINARY_DIR}/protobuf-$ENV{PROTOBUF_VERSION}/protobuf/bin/protoc.exe" COPYONLY)
endif()
add_custom_target(zip_protobuf ALL
    COMMAND ${CMAKE_COMMAND} -E tar cfv "${CMAKE_BINARY_DIR}/protobuf.zip" --format=zip .
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/protobuf-$ENV{PROTOBUF_VERSION}")
