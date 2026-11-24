#ifndef RUT_H
#define RUT_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

uint8_t rut_calculate_dv(uint32_t rut_value);
uint8_t rut_calculate_dv_str(const char *digits, size_t len);
uint8_t rut_get_digit_str(uint32_t rut_value);
uint8_t rut_get_digit_from_str(const char *digits, size_t len);
bool    rut_check_dv(uint32_t rut_value, uint8_t expected);

#ifdef __cplusplus
}
#endif

#endif
