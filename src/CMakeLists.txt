# Crear la biblioteca compartida
add_library(librut SHARED librut.cpp)

# Propiedades de la biblioteca
set_target_properties(librut PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    PUBLIC_HEADER "../include/librut.hpp"
)

# Crear el ejecutable principal
add_executable(rut main.cpp)

# Enlazar con la biblioteca
target_link_libraries(rut PRIVATE librut)

# Instalación de la biblioteca
install(TARGETS librut
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

# Instalar el ejecutable
install(TARGETS rut DESTINATION ${CMAKE_INSTALL_BINDIR})

# Instalar archivo .pc para pkg-config
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/../librut.pc
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/pkgconfig
)