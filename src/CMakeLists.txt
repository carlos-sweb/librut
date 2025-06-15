 cmake_minimum_required(VERSION 3.31)

# Crear la biblioteca compartida
add_library(librut SHARED librut.cpp)

# Propiedades de la biblioteca
set_target_properties(librut PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    PUBLIC_HEADER "../include/librut.hpp"
)

# Instalación de la biblioteca
install(TARGETS librut
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# Instalar archivo .pc para pkg-config
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/../librut.pc
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/pkgconfig
)