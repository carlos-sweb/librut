#include <stdio.h>
#include <string.h>

char *reverse_string(char *str) {
    // Verificar puntero nulo y strings vacíos
    if (str == NULL || *str == '\0') return str;
    char *start = str;
    char *end = str + strlen(str) - 1;  // Apunta al último carácter válido
    while (start < end) {
        // Intercambio seguro de caracteres
        char temp = *start;
        *start = *end;
        *end = temp;
        // Movemos los punteros hacia el centro
        start++;
        end--;
    }    
    return str;  // Retornamos el mismo puntero modificado
}

int main() {
    int num = 16000000;
    char buffer[20];
    snprintf(buffer,sizeof(buffer),"%d",num);
    reverse_string(buffer);
    int ii = 2;
    int total = 0;
    for(int i = 0 ; i < strlen(buffer);i++ ){
      char c = buffer[i];
      int num  = c - '0';
      total = total + ( num*ii );
      if(ii == 7 ){ ii =2; }else{ ii++;};      
    }
    printf("Total %d\n",total);
    int parte_entera = (total/11);
    printf("parte entera %d\n",parte_entera);
    printf("result:  %d\n", 11-(total-(parte_entera*11)));
    return 0;
}