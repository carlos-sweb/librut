cmake_minimum_required(VERSION 3.31)
project(rut VERSION 0.1.0 LANGUAGES CXX C)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
find_package(fmt REQUIRED)
find_package(GTest REQUIRED)
find_package(absl REQUIRED)

include(GNUInstallDirs)
configure_file(librut.pc.in librut.pc @ONLY)

add_executable(rut src/main.cpp)

target_link_libraries(rut PUBLIC fmt::fmt PRIVATE absl::strings)
target_include_directories(rut PRIVATE includes)

install(TARGETS rut 
	LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
	RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
	)