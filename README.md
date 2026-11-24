# librut

Biblioteca minimalista de alto rendimiento para calcular el dígito verificador del RUT chileno. Escrita en **Zig 0.17** con interfaz **C-ABI** (`.a` y `.so`).

**Filosofía:** recibe únicamente el string limpio con los dígitos del RUT (sin puntos, sin guion, sin DV) y devuelve el carácter ASCII del dígito verificador (`'0'`–`'9'` o `'K'`). El formateo o limpieza previa queda a criterio de cada usuario y entorno.

## Algoritmo central (`src/rut.zig`)

```zig
pub fn rutDv(s: []const u8) u8 {
    var m: i64 = 2;
    var t: i64 = 0;
    var i: usize = s.len;
    while (i > 0) {
        i -= 1;
        t += @as(i64, s[i] - '0') * m;
        m = if (m == 7) 2 else m + 1;
    }
    const dv_num = 11 - @mod(t, 11);
    return switch (dv_num) {
        11 => '0',
        10 => 'K',
        else => @intCast('0' + dv_num),
    };
}
```

## Build y Tests

```sh
zig build -Doptimize=ReleaseFast
zig build test
```

## Uso en Zig

```zig
const rut = @import("rut");
const dv = rut.rutDv("16521526"); // '5'
```

## Uso en C / C++ (`.a` y `.so`)

```c
#include <rut.h>
#include <stdio.h>
#include <string.h>

int main(void) {
    const char *r = "16521526";
    char dv = (char)rut_dv(r, strlen(r));
    printf("%s-%c\n", r, dv); // 16521526-5
    return 0;
}
```

```sh
# Static (.a)
gcc -O3 main.c -I zig-out/include -L zig-out/lib -lrut_c -o app

# Shared (.so)
gcc -O3 main.c -I zig-out/include -L zig-out/lib -lrut -Wl,-rpath,zig-out/lib -o app
```

## Uso de la CLI

La CLI es un cliente de `librut`: se encarga de limpiar y formatear el RUT y delega el cálculo del dígito verificador a `rutDv`.

```sh
zig build run -- -p "16521526"
# 16.521.526-5

zig build run -- -p "30686957" --check-digit "5"
# Check digit => 5 Error
# 30.686.957-4

zig build run -- -p "16521526" --get-digit
# 5

zig build run -- -p "30686957" --separate-miles "" --separate-digit " "
# 30686957 4
```

### Opciones

```
 -p,--parser: <RUT>          string rut to check
 --check-digit:              digit to compare
 --get-digit:                get only digit verifier
 --separate-miles:           string to separate miles default .
 --separate-digit:           string to separate digit default -
 -v,--version:               show version
 -h,--help:                  show this help
```

## Benchmark

```sh
zig build bench-comp -Doptimize=ReleaseFast
```

## Artefactos generados

- `zig-out/lib/librut.a` — Librería estática (Zig)
- `zig-out/lib/librut_c.a` — Librería estática (C-ABI)
- `zig-out/lib/librut.so` — Librería dinámica (C-ABI)
- `zig-out/include/rut.h` — Header C/C++
- `zig-out/bin/rut` — CLI minimalista
- `zig-out/bin/bench_comp` — Benchmark de cómputo puro (100M ops)

## License

MIT
