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

