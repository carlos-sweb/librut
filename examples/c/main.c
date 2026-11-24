#include <stdio.h>
#include <string.h>
#include <rut.h>

static void show(const char *rut) {
    char dv = (char)rut_dv(rut, strlen(rut));
    printf("%s-%c\n", rut, dv);
}

int main(void) {
    printf("=== librut - Ejemplos en C ===\n\n");
    show("16521526"); /* 5 */
    show("30686957"); /* 4 */
    show("12345678"); /* 5 */
    show("16521529"); /* K */
    show("123456");   /* 0 */
    show("1");        /* 9 */
    return 0;
}
