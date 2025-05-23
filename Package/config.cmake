set(absl_DIR "${CMAKE_CURRENT_LIST_DIR}/lib/cmake/absl")
set(utf8_range_DIR "${CMAKE_CURRENT_LIST_DIR}/lib/cmake/utf8_range")
set(protobuf_DIR "${CMAKE_CURRENT_LIST_DIR}/lib/cmake/protobuf")
set(Protobuf_DIR "${CMAKE_CURRENT_LIST_DIR}/lib/cmake/protobuf")

set(Protobuf_INCLUDE_DIR "${CMAKE_CURRENT_LIST_DIR}/include")
set(Protobuf_LIB_DIR "${CMAKE_CURRENT_LIST_DIR}/lib")

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(Protobuf_PROTOC_EXECUTABLE "${CMAKE_CURRENT_LIST_DIR}/bin/protoc")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    set(Protobuf_PROTOC_EXECUTABLE "${CMAKE_CURRENT_LIST_DIR}/bin/protoc.exe")
endif()
set(PROTOC_EXEC "${Protobuf_PROTOC_EXECUTABLE}")

include("${CMAKE_CURRENT_LIST_DIR}/lib/cmake/protobuf/protobuf-config.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/lib/cmake/protobuf/protobuf-module.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/lib/cmake/protobuf/protobuf-options.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/lib/cmake/protobuf/protobuf-targets.cmake")

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    add_custom_target(
        Protobuf-DLL-Copy
        DEPENDS "${CMAKE_CURRENT_LIST_DIR}/__run_always"
        COMMENT "Protobuf DLL Copy"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_LIST_DIR}/bin/abseil_dll.dll" "${CMAKE_BINARY_DIR}/$<CONFIG>/bin/abseil_dll.dll"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_LIST_DIR}/bin/libprotobuf-lite.dll" "${CMAKE_BINARY_DIR}/$<CONFIG>/bin/libprotobuf-lite.dll"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_LIST_DIR}/bin/libprotobuf.dll" "${CMAKE_BINARY_DIR}/$<CONFIG>/bin/libprotobuf.dll"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_LIST_DIR}/bin/libutf8_range.dll" "${CMAKE_BINARY_DIR}/$<CONFIG>/bin/libutf8_range.dll"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_LIST_DIR}/bin/libutf8_validity.dll" "${CMAKE_BINARY_DIR}/$<CONFIG>/bin/libutf8_validity.dll"
    )
    add_dependencies(protobuf::libprotobuf Protobuf-DLL-Copy)
endif()

function(protoc_gen ProtoGenerate_ROOT_DIR ProtoGenerate_DLL_EXPORT_H ProtoGenerate_DLL_EXPORT_DECL)
    if(NOT "${ProtoGenerate_DLL_EXPORT_H}" STREQUAL "")
        set(proto_cpp_include_prefix "#include \"${ProtoGenerate_DLL_EXPORT_H}\"\n")
    else()
        set(proto_cpp_include_prefix "")
    endif()
    if(NOT "${ProtoGenerate_DLL_EXPORT_DECL}" STREQUAL "")
        set(proto_cpp_out_option "dllexport_decl=${ProtoGenerate_DLL_EXPORT_DECL}:")
    else()
        set(proto_cpp_out_option "")
    endif()

    # clean up mismatch protobuf files

    unset(ProtoGenerate_INC_FILES)
    file(GLOB_RECURSE ProtoGenerate_INC_FILES ${ProtoGenerate_ROOT_DIR}/include/**.pb.h)
    foreach(PROTO_INC_FILE IN LISTS ProtoGenerate_INC_FILES)
        get_filename_component(PROTO_INC_DIR ${PROTO_INC_FILE} DIRECTORY)
        get_filename_component(PROTO_INC_NAME ${PROTO_INC_FILE} NAME)
        string(REGEX REPLACE "/include/" "/src/" PROTO_SRC_DIR "${PROTO_INC_DIR}")
        string(REGEX REPLACE ".pb.h$" ".pb.cc" PROTO_SRC_NAME "${PROTO_INC_NAME}")
        string(REGEX REPLACE ".pb.h$" ".proto" PROTO_FILE_NAME "${PROTO_INC_NAME}")
        if(NOT EXISTS ${PROTO_SRC_DIR}/${PROTO_SRC_NAME} OR NOT EXISTS ${PROTO_SRC_DIR}/${PROTO_FILE_NAME})
            file(REMOVE ${PROTO_SRC_DIR}/${PROTO_SRC_NAME})
            file(REMOVE ${PROTO_INC_FILE})
        endif()
    endforeach()

    unset(ProtoGenerate_SRC_FILES)
    file(GLOB_RECURSE ProtoGenerate_SRC_FILES ${ProtoGenerate_ROOT_DIR}/src/**.pb.cc)
    foreach(PROTO_SRC_FILE IN LISTS ProtoGenerate_SRC_FILES)
        get_filename_component(PROTO_SRC_DIR ${PROTO_SRC_FILE} DIRECTORY)
        get_filename_component(PROTO_SRC_NAME ${PROTO_SRC_FILE} NAME)
        string(REGEX REPLACE "/src/" "/include/" PROTO_INC_DIR "${PROTO_SRC_DIR}")
        string(REGEX REPLACE ".pb.cc$" ".pb.h" PROTO_INC_NAME "${PROTO_SRC_NAME}")
        string(REGEX REPLACE ".pb.cc$" ".proto" PROTO_FILE_NAME "${PROTO_SRC_NAME}")
        if(NOT EXISTS ${PROTO_INC_DIR}/${PROTO_INC_NAME} OR NOT EXISTS ${PROTO_SRC_DIR}/${PROTO_FILE_NAME})
            file(REMOVE ${PROTO_INC_DIR}/${PROTO_INC_NAME})
            file(REMOVE ${PROTO_SRC_FILE})
        endif()
    endforeach()

    # build the protobuf output files in their respective directories

    unset(ProtoGenerate_SRC)
    file(GLOB_RECURSE ProtoGenerate_SRC ${ProtoGenerate_ROOT_DIR}/src/**.proto)
    foreach(PROTO_FILE IN LISTS ProtoGenerate_SRC)
        get_filename_component(PROTO_SRC_DIR ${PROTO_FILE} DIRECTORY)
        get_filename_component(PROTO_FILE_NAME ${PROTO_FILE} NAME)
        string(REGEX REPLACE "/src/" "/include/" PROTO_INC_DIR "${PROTO_SRC_DIR}")
        string(REGEX REPLACE ".proto$" ".pb.h" PROTO_INC_NAME "${PROTO_FILE_NAME}")
        string(REGEX REPLACE ".proto$" ".pb.cc" PROTO_SRC_NAME "${PROTO_FILE_NAME}")
        string(REGEX REPLACE ".*/include/" "" PROTO_INC_DIR_SUFFIX "${PROTO_INC_DIR}")
        
        execute_process(COMMAND ${PROTOC_EXEC} -I=${PROTO_INC_DIR} --proto_path=${PROTO_SRC_DIR} --cpp_out=${proto_cpp_out_option}${PROTO_SRC_DIR} ${PROTO_FILE})
        file(READ ${PROTO_SRC_DIR}/${PROTO_SRC_NAME} PROTO_SRC_FILE_CONTENT)
        string(REGEX REPLACE "#include \"${PROTO_INC_NAME}\"" "#include \"${PROTO_INC_DIR_SUFFIX}/${PROTO_INC_NAME}\"" PROTO_SRC_FILE_CONTENT "${PROTO_SRC_FILE_CONTENT}")
        file(WRITE ${PROTO_SRC_DIR}/${PROTO_SRC_NAME} "${PROTO_SRC_FILE_CONTENT}")

        execute_process(COMMAND ${CMAKE_COMMAND} -E rename ${PROTO_SRC_DIR}/${PROTO_INC_NAME} ${PROTO_INC_DIR}/${PROTO_INC_NAME})
        file(READ ${PROTO_INC_DIR}/${PROTO_INC_NAME} PROTO_INC_FILE_CONTENT)
        string(REGEX REPLACE "#include <limits>" "${proto_cpp_include_prefix}#include <limits>" PROTO_INC_FILE_CONTENT "${PROTO_INC_FILE_CONTENT}")
        file(WRITE ${PROTO_INC_DIR}/${PROTO_INC_NAME} "${PROTO_INC_FILE_CONTENT}")
    endforeach()
endfunction()
