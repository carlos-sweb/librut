# librut

For more information [Wikipedia Link](https://es.wikipedia.org/wiki/Rol_%C3%9Anico_Tributario)

## How use librut.hpp

Here is the simplest example:

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
If you want to browse through a bunch of RUT numbers, I'll show you how:

```cpp

#include <chrono>
#include <stdio.h>
#include <librut.hpp>
using namespace ppRut;

int main() {

  auto time_begin = std::chrono::high_resolution_clock::now();

  int begin = 1000000,end = 99999999;

  while(begin<end){

    rut rut(begin);  

    printf("%s\n",rut.format().c_str());

    begin++;

  }  
  
   auto time_end = std::chrono::high_resolution_clock::now();

   auto duration = std::chrono::duration_cast<std::chrono::milliseconds>( time_end - time_begin );

   printf("Execution time %d ms \n", duration.count() );

   return 0;

}
```
The result of a local test:

Linux fedora 6.14.11-300.fc42.x86_64
32 GB RAM
Execution time 7.4 minutes to analyze 98.999.999 Chilean R.U.T

```sh
......
99.999.994-8
99.999.995-6
99.999.996-4
99.999.997-2
99.999.998-0
Execution time 445296 ms
```


```cmake
cmake_minimum_required(VERSION 3.31)

project(example-rut VERSION 0.1.0 LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 20)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(rut REQUIRED)

include(GNUInstallDirs)

add_executable(${PROJECT_NAME} main.cpp)

target_link_libraries(${PROJECT_NAME} PUBLIC ppRut::rut_core )
# or 
# target_link_libraries(${PROJECT_NAME} PUBLIC ppRut::rut_lib )

install(TARGETS ${PROJECT_NAME} LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
```

## How use rut "CommandLineApp" ?

```sh
git clone https://github.com/carlos-sweb/librut && cd librut
mkdir build && cd build && cmake .. && make
sudo make install
```
```sh
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

