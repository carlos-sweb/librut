#include <stdio.h>
#include <rut.h>

int main(void) {
    printf("=== librut - Ejemplos en C ===\n\n");

    /* 1. Calcular digito verificador numerico */
    uint32_t rut1 = 30686957;
    uint8_t dv_num = rut_calculate_dv(rut1);
    printf("1) rut_calculate_dv(%u) = %u\n", rut1, dv_num);

    /* 2. Obtener digito verificador como caracter */
    char dv_char = (char)rut_get_digit_str(rut1);
    printf("2) rut_get_digit_str(%u) = '%c'\n", rut1, dv_char);

    /* 3. Verificar DV correcto */
    int ok = rut_check_dv(rut1, '4');
    printf("3) rut_check_dv(%u, '4') = %s\n", rut1, ok ? "true (Ok)" : "false (Error)");

    /* 4. Verificar DV incorrecto */
    int fail = rut_check_dv(rut1, '5');
    printf("4) rut_check_dv(%u, '5') = %s\n", rut1, fail ? "true (Ok)" : "false (Error)");

    /* 5. Caso especial: dv = 10 -> 'k' */
    uint32_t rut_k = 15470893;
    char dv_k = (char)rut_get_digit_str(rut_k);
    printf("5) rut_get_digit_str(%u) = '%c'  (dv=10 -> k)\n", rut_k, dv_k);

    /* 6. Caso especial: dv = 11 -> '0' */
    uint32_t rut_zero = 10000000;
    char dv_zero = (char)rut_get_digit_str(rut_zero);
    printf("6) rut_get_digit_str(%u) = '%c'\n", rut_zero, dv_zero);

    /* 7. RUT grande */
    uint32_t rut_big = 99999999;
    char dv_big = (char)rut_get_digit_str(rut_big);
    printf("7) rut_get_digit_str(%u) = '%c'\n", rut_big, dv_big);

    return 0;
}
