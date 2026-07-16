#include <iostream>
#include <rut.h>

int main() {
    std::cout << "=== librut - Ejemplos en C++ ===" << std::endl << std::endl;

    /* 1. Calcular digito verificador numerico */
    uint32_t rut1 = 30686957;
    uint8_t dv_num = rut_calculate_dv(rut1);
    std::cout << "1) rut_calculate_dv(" << rut1 << ") = " << (int)dv_num << std::endl;

    /* 2. Obtener digito verificador como caracter */
    char dv_char = static_cast<char>(rut_get_digit_str(rut1));
    std::cout << "2) rut_get_digit_str(" << rut1 << ") = '" << dv_char << "'" << std::endl;

    /* 3. Verificar DV correcto */
    bool ok = rut_check_dv(rut1, '4');
    std::cout << "3) rut_check_dv(" << rut1 << ", '4') = " << (ok ? "true (Ok)" : "false (Error)") << std::endl;

    /* 4. Verificar DV incorrecto */
    bool fail = rut_check_dv(rut1, '5');
    std::cout << "4) rut_check_dv(" << rut1 << ", '5') = " << (fail ? "true (Ok)" : "false (Error)") << std::endl;

    /* 5. Caso especial: dv = 10 -> 'k' */
    uint32_t rut_k = 15470893;
    char dv_k = static_cast<char>(rut_get_digit_str(rut_k));
    std::cout << "5) rut_get_digit_str(" << rut_k << ") = '" << dv_k << "'  (dv=10 -> k)" << std::endl;

    /* 6. Caso especial: dv = 11 -> '0' */
    uint32_t rut_zero = 10000000;
    char dv_zero = static_cast<char>(rut_get_digit_str(rut_zero));
    std::cout << "6) rut_get_digit_str(" << rut_zero << ") = '" << dv_zero << "'" << std::endl;

    /* 7. RUT grande */
    uint32_t rut_big = 99999999;
    char dv_big = static_cast<char>(rut_get_digit_str(rut_big));
    std::cout << "7) rut_get_digit_str(" << rut_big << ") = '" << dv_big << "'" << std::endl;

    return 0;
}
