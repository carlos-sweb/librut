# librut

For more information [Wikipedia Link](https://es.wikipedia.org/wiki/Rol_%C3%9Anico_Tributario)

## How use librut.hpp

```cpp
#include <iostream>
#include <librut.hpp>
int main(){
	ppRut::rut rut("30.686.957-4");
	bool check = rut.checkDigit();
	std::cout <<  ( check ? "Ok":"Error" ) << "\n";
	std::cout << rut.getDigit() << "\n";
	std::cout << rut.format() << "\n";
	std::cout << rut.format(".","-") << "\n";
}
```
or

```cpp
#include <iostream>
#include <librut.hpp>
using namespace std;
using namespace ppRut;
int main()
{
    int start = 1000000, end = 99999999;
    while(start < end){
        rut rut(start);
        cout << rut.format() << "\n";
        start++;
    }
    return 0;
}
```
```cmake
cmake_minimum_required(VERSION 3.16)

project(rut-test LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(rut REQUIRED)

add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME} PUBLIC ppRut::rut_core)

include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
```

## How use rut CommandLineApp

```ssh
git clone https://github.com/carlos-sweb/librut && cd librut
mkdir build && cd build && cmake .. && make
sudo make install
```
```ssh
rut --parser="30686957-4"
30.686.957-4

rut --parser="30686957" --check-digit="5"
check digit => Error
30.686.957-4

rut --parser="30686957" --get-digit
4

rut --parser="30686957" --separate-miles="" --separate-digit=" "
30686957 4
```

