#include <iostream>
#include <string_view>
#include <rut.h>

static void show(std::string_view rut) {
    char dv = static_cast<char>(rut_dv(rut.data(), rut.size()));
    std::cout << rut << '-' << dv << '\n';
}

int main() {
    std::cout << "=== librut - Ejemplos en C++ ===\n\n";
    show("16521526"); // 5
    show("30686957"); // 4
    show("12345678"); // 5
    show("16521529"); // K
    show("123456");   // 0
    show("1");        // 9
    return 0;
}
