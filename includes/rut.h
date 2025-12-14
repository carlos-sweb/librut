#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

uint32_t calculateDv(uint32_t rut_value) {
    uint32_t rut = rut_value;
    uint8_t factor = 2;
    uint32_t total = 0;
    // Recorre los dígitos de derecha a izquierda
    while( rut > 0 ){
        uint32_t digit = rut % 10;
        total += digit * factor;
        factor = (factor == 7) ? 2 : factor + 1;
        rut /= 10;
    }
    uint32_t dv = 11 - (total % 11);
    return dv;
}
#ifdef __cplusplus
}
#endif