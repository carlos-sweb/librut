cmake_minimum_required(VERSION 3.31)
project(rut VERSION 0.1.0 LANGUAGES CXX C)

cmake_policy(SET CMP0077 NEW)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(BUILD_TESTING "build tests" ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_package(fmt REQUIRED)

include(GNUInstallDirs)
configure_file(librut.pc.in librut.pc @ONLY)

add_library(rut_core SHARED
    src/librut.cpp
    includes/librut.hpp
)
# Controlamos explícitamente el nombre de salida
set_target_properties(rut_core PROPERTIES
    OUTPUT_NAME "librut"  # Sin prefijo "lib"
    PREFIX ""          # Eliminamos cualquier prefijo automático
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    DEFINE_SYMBOL "RUT_EXPORT"
    CXX_VISIBILITY_PRESET hidden    

)

target_include_directories(rut_core PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/includes>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_link_libraries(rut_core)

# ... (el resto de la configuración igual que antes)

add_library(rut_lib STATIC
    src/librut.cpp
    includes/librut.hpp  # Mejora: Añadir cabeceras al target
)

set_target_properties(rut_lib PROPERTIES
	OUTPUT_NAME "librut"
	PREFIX ""
	VERSION ${PROJECT_VERSION}
	SOVERSION 1
)

target_include_directories(rut_lib PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/includes>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_link_libraries(rut_lib)


add_executable(${PROJECT_NAME} src/main.cpp)

target_link_libraries(${PROJECT_NAME} PUBLIC fmt::fmt rut_lib)

target_include_directories(${PROJECT_NAME} PRIVATE includes)

install(TARGETS ${PROJECT_NAME} LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} )
install(TARGETS rut_core
        EXPORT rut-targets
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

install(EXPORT rut-targets
    FILE rut-config.cmake
    NAMESPACE ppRut::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/rut-${PROJECT_VERSION}
)
install(FILES 
    "${CMAKE_CURRENT_BINARY_DIR}/librut.pc"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
)
install(FILES "${CMAKE_CURRENT_LIST_DIR}/includes/librut.hpp" DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(FILES "${CMAKE_CURRENT_LIST_DIR}/LICENSE.txt" DESTINATION ${CMAKE_INSTALL_DOCDIR})
install(FILES "${CMAKE_CURRENT_LIST_DIR}/README.md" DESTINATION ${CMAKE_INSTALL_DOCDIR})