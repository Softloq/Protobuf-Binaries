cmake_minimum_required(VERSION 3.10)

project(Protobuf-Prerequisite)

# Download Protobuf
if(NOT EXISTS "${CMAKE_BINARY_DIR}/Downloads/protobuf-${PROTOBUF_VERSION}.zip")
    file(DOWNLOAD "https://github.com/protocolbuffers/protobuf/archive/refs/tags/v${PROTOBUF_VERSION}.zip" "${CMAKE_BINARY_DIR}/Downloads/protobuf-${PROTOBUF_VERSION}.zip" SHOW_PROGRESS)
endif()
if(NOT EXISTS "${CMAKE_BINARY_DIR}/Downloads/protobuf-${PROTOBUF_VERSION}")
    file(ARCHIVE_EXTRACT INPUT "${CMAKE_BINARY_DIR}/Downloads/protobuf-${PROTOBUF_VERSION}.zip" DESTINATION "${CMAKE_BINARY_DIR}/Downloads")
endif()
