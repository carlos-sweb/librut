# librut

Biblioteca para validacion de RUT chileno. Escrita en Zig 0.16 con interfaz C-ABI compatible. Los programas existentes en C/C++ pueden migrar sin cambios en el codigo fuente — solo cambia la forma de compilar y linkear.

Para mas informacion [Wikipedia Link](https://es.wikipedia.org/wiki/Rol_%C3%9Anico_Tributario)

## Build

```sh
zig build
```

## Tests

```sh
zig build test
```

## Uso de la libreria Zig

```zig
const std = @import("std");
const RUT = @import("rut").RUT;

pub fn main() !void {
    const rut = RUT.fromString("30.686.957-4");

    const check = rut.checkDigit();
    std.debug.print("check: {}\n", .{check});

    const digit = rut.getDigit();
    std.debug.print("digit: {s}\n", .{digit});

    const formatted = try rut.formatAlloc(allocator, ".", "-");
    defer allocator.free(formatted);
    std.debug.print("format: {s}\n", .{formatted});
}
```

## Uso en C/C++

La libreria exporta una interfaz C-ABI estable a traves de `rut.h`. No es necesario reescribir codigo existente — solo cambia la forma de compilar y linkear.

### API

```c
#include <rut.h>
```

| Firma | Parametro | Retorno |
|---|---|---|
| `uint8_t rut_calculate_dv(uint32_t rut_value)` | RUT sin DV (ej: `30686957`) | DV numerico (0-11) |
| `uint8_t rut_get_digit_str(uint32_t rut_value)` | RUT sin DV | DV como char (`'0'`-`'9'` o `'k'`) |
| `bool rut_check_dv(uint32_t rut_value, uint8_t expected)` | RUT sin DV + DV esperado | `true` si coincide |

- `rut_calculate_dv`: Retorna el digito verificador como numero entero. 10 = k, 11 = 0.
- `rut_get_digit_str`: Retorna el digito verificador como caracter ASCII.
- `rut_check_dv`: Compara un DV esperado con el calculado.

### Ejemplo minimo

```c
#include <rut.h>
#include <stdio.h>

int main(void) {
    char dv = (char)rut_get_digit_str(30686957);
    printf("30686957-%c\n", dv);  // 30686957-4

    int ok = rut_check_dv(30686957, '4');
    printf("valido: %s\n", ok ? "si" : "no");

    return 0;
}
```

### Compilacion manual

```sh
# Shared (.so)
gcc -o ejemplo main.c -L zig-out/lib -lrut -Wl,-rpath,zig-out/lib

# Static (.a)
gcc -o ejemplo main.c -L zig-out/lib -lrut_c

# C++
g++ -o ejemplo main.cpp -L zig-out/lib -lrut
```

### pkg-config (recomendado)

```sh
# Shared
gcc main.c $(pkg-config --libs --cflags librut) -o ejemplo

# Static
gcc main.c $(pkg-config --libs --cflags librut-static) -o ejemplo

# C++
g++ main.cpp $(pkg-config --libs --cflags librut) -o ejemplo
```

### CMake (find_library)

```cmake
find_library(LIBUT rut PATHS /usr/local/lib)
find_path(LIBRUT_INCLUDE rut.h PATHS /usr/local/include)

add_executable(mi_app main.c)
target_link_libraries(mi_app PRIVATE ${LIBUT})
target_include_directories(mi_app PRIVATE ${LIBRUT_INCLUDE})
```

## Instalacion en el sistema

Equivalente a `cmake install`. Zig instala los artefactos en el layout estandar FHS:

```
<prefix>/
├── bin/        rut, bench, bench_comp
├── lib/
│   ├── librut.so, librut.a, librut_c.a
│   └── pkgconfig/ librut.pc, librut-static.pc
└── include/    rut.h, rut.zig
```

```sh
# Instalacion local (zig-out/)
zig build -Doptimize=ReleaseSafe

# Instalar a /usr/local (requiere sudo, como cmake --install)
sudo $(which zig) build -Doptimize=ReleaseSafe -p /usr/local
sudo ldconfig

# Instalar a /usr
sudo $(which zig) build -Doptimize=ReleaseSafe -p /usr

# Verificar
pkg-config --libs --cflags librut

# Desinstalar
sudo $(which zig) uninstall -p /usr/local
```

> Si `sudo zig` falla con "command not found", es porque `sudo` no tiene el `PATH` de tu usuario. Usa `$(which zig)` para resolver la ruta completa del binario.
>
> Si `pkg-config` no encuentra librut despues de instalar a `/usr/local`, exporta el path:
> ```sh
> export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH
> ```

## Uso de la CLI

```sh
zig build run -- -p "30686957-4"
30.686.957-4

zig build run -- -p "30686957" --check-digit="5"
Check digit => 5 Error
30.686.957-4

zig build run -- -p "30686957" --get-digit
4

zig build run -- -p "30686957" --separate-miles="" --separate-digit=" "
30686957 4
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

## Ejecutar los ejemplos C/C++

```sh
# Compilar la libreria primero
zig build

# Ejemplos C
cd examples/c
mkdir build && cd build
cmake .. && make

# Ejecutar (shared)
LD_LIBRARY_PATH=../../zig-out/lib ./example_c_shared

# Ejecutar (static)
./example_c_static

# Ejemplos C++
cd ../../cpp
mkdir build && cd build
cmake .. && make

# Ejecutar (shared)
LD_LIBRARY_PATH=../../zig-out/lib ./example_cpp_shared

# Ejecutar (static)
./example_cpp_static
```

> Al ejecutar binarios linked contra `.so` desde el directorio de build (sin instalar al sistema), es necesario definir `LD_LIBRARY_PATH` para que el linker dinamico encuentre la libreria. Si compilas con `-Wl,-rpath` (como hace CMake en los ejemplos con `BUILD_RPATH`), no es necesario.

## Estructura del proyecto

```
librut/
├── build.zig
├── build.zig.zon
├── include/
│   └── rut.h             # Header C/C++
├── src/
│   ├── rut.zig           # Core: struct RUT + algoritmo
│   ├── c_api.zig         # Interfaz C-ABI
│   ├── root.zig
│   ├── main.zig          # CLI
│   ├── test_rut.zig
│   ├── bench.zig         # Benchmark (con I/O)
│   └── bench_comp.zig    # Benchmark (solo calculo)
├── examples/
│   ├── c/
│   │   ├── CMakeLists.txt
│   │   └── main.c
│   └── cpp/
│       ├── CMakeLists.txt
│       └── main.cpp
├── legacy/               # C/C++ original (CMake)
└── README.md
```

## Artefactos generados

| Artefacto | Descripcion | Consumidor |
|---|---|---|
| `zig-out/lib/librut.a` | Libreria estatica (Zig-ABI) | Zig |
| `zig-out/lib/librut.so` | Libreria dinamica (C-ABI) | C, C++, Rust, Python, Go... |
| `zig-out/lib/librut_c.a` | Libreria estatica (C-ABI) | C, C++, Rust, Python, Go... |
| `zig-out/lib/librut.pc` | pkg-config (shared) | C, C++ |
| `zig-out/lib/librut-static.pc` | pkg-config (static) | C, C++ |
| `zig-out/include/rut.h` | Header C con guards `extern "C"` | C, C++ |
| `zig-out/bin/rut` | CLI | Terminal |
| `zig-out/bin/bench` | Benchmark (con I/O) | Benchmarking |
| `zig-out/bin/bench_comp` | Benchmark (solo calculo) | Benchmarking |

## Rendimiento

Benchmark midiendo 10 millones de operaciones (calcular DV para RUTs 1 a 10,000,000):

| Implementacion | Tiempo | Velocidad relativa |
|---|---|---|
| **Zig (ReleaseFast)** | 36,141 ms | 12.3x |
| C++ original (CMake, ReleaseFast) | 445,296 ms | 1x |

- **Computacion pura** (sin I/O): 822ms (~120M ops/sec, 541x mas rapido que C++ con I/O)
- **Con buffered I/O** (10M lineas a stdout): 36s

```sh
# Ejecutar benchmark
zig build bench -Doptimize=ReleaseFast

# Benchmark solo calculo (sin output)
zig build bench-comp -Doptimize=ReleaseFast
```

## Algoritmo modulo 11

1. Recorrer digitos del RUT de derecha a izquierda
2. Multiplicar cada digito por un factor ciclico: 2, 3, 4, 5, 6, 7, 2, 3, ...
3. Acumular la suma de productos
4. `dv = 11 - (total % 11)`
5. Mapeo: dv == 11 -> "0", dv == 10 -> "k", caso contrario -> digito

## Solucion de problemas

| Error | Causa | Solucion |
|---|---|---|
| `undefined reference to 'rut_...'` | No se linkeo la libreria | Agregar `-lrut` o `-lrut_c` |
| `cannot find -lrut` | Linker no encuentra el `.so`/`.a` | Agregar `-L zig-out/lib` o usar pkg-config |
| `librut.so: cannot open shared object file` | Binario no sabe donde esta el `.so` | `LD_LIBRARY_PATH=zig-out/lib ./app`, o `-Wl,-rpath`, o instalar al sistema |
| `rut.h: No such file or directory` | No se especifico directorio de headers | Agregar `-I zig-out/include` o usar pkg-config |
| `expected '=', ';' or '__attribute__' before 'bool'` (C) | Compilacion en C89/C90 | Compilar con `-std=c99` o superior |
| `error: use of undeclared identifier 'bool'` (C++) | Header no se incluyo correctamente | Verificar `#include <rut.h>` y guards `extern "C"` |

## License

MIT
