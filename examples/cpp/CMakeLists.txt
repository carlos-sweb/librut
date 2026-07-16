cmake_minimum_required(VERSION 3.10)
project(rut_cpp_example CXX)

set(LIB_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../zig-out/lib")
set(INC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../include")

# --- Ejemplo con .so (shared) ---
add_executable(example_cpp_shared main.cpp)
target_include_directories(example_cpp_shared PRIVATE ${INC_DIR})
target_link_directories(example_cpp_shared PRIVATE ${LIB_DIR})
target_link_libraries(example_cpp_shared PRIVATE rut)
set_target_properties(example_cpp_shared PROPERTIES
    BUILD_RPATH "${LIB_DIR}"
    INSTALL_RPATH "${LIB_DIR}"
)

# --- Ejemplo con .a (static) ---
add_executable(example_cpp_static main.cpp)
target_include_directories(example_cpp_static PRIVATE ${INC_DIR})
target_link_directories(example_cpp_static PRIVATE ${LIB_DIR})
target_link_libraries(example_cpp_static PRIVATE rut_c)
