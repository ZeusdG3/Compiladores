# Analizador Sintáctico (Flex + Bison)

## Descripción
Este proyecto implementa un **analizador sintáctico** para un subconjunto del lenguaje C utilizando **Flex** y **Bison**. El parser valida la estructura gramatical del código fuente según las producciones definidas y genera mensajes informativos sobre el análisis realizado.

## INTEGRANTES DEL EQUIPO
ZEUS HADES CORONA PLASCENCIA
MIGUEL ANGEL GONZALEZ PEREZ

### Componentes Principales
- **`lexer.l`** - Analizador léxico (Flex)
- **`parser.y`** - Analizador sintáctico (Bison) 
- **`input.c`** - Caso de prueba con código válido
- **`README.md`** - Documentación del proyecto

## 📖 Producciones Gramaticales Implementadas

### 1. Estructura del Programa

## ✅ Elementos Validados

### Declaraciones
- [x] **Variables globales y locales**
- [x] **Funciones** con y sin parámetros
- [x] **Múltiples parámetros** en funciones

### Estructuras de Control
- [x] **Sentencias `if` y `if-else`**
- [x] **Bucles `while`, `for`, `do-while`**
- [x] **Sentencias `return`** con y sin valor

### Expresiones
- [x] **Expresiones aritméticas** con precedencia
- [x] **Operadores relacionales** y lógicos
- [x] **Llamadas a funciones** con argumentos
- [x] **Asignaciones** de variables

### Bloques y Ámbitos
- [x] **Bloques `{...}`** anidados
- [x] **Declaraciones locales** dentro de funciones
- [x] **Sentencias compuestas**

## 🔧 Precedencia de Operadores

| Precedencia | Operadores | Asociatividad |
|-------------|------------|---------------|
| Más alta | `!`, `-` (unario), `+` (unario) | Derecha |
| | `*`, `/`, `%` | Izquierda |
| | `+`, `-` | Izquierda |
| | `<`, `>`, `<=`, `>=` | Izquierda |
| | `==`, `!=` | Izquierda |
| | `&&` | Izquierda |
| | `||` | Izquierda |
| Más baja | `=` | Derecha |

## 🚀 Compilación y Ejecución

### Requisitos
- **flex** (analizador léxico)
- **bison** (analizador sintáctico)
- **gcc** (compilador C)

### Comandos de Compilación
```bash
# 1. Generar el parser desde la gramática
bison -d parser.y

# 2. Generar el lexer desde las reglas léxicas
flex lexer.l

# 3. Compilar ambos componentes
gcc -o analizador lex.yy.c y.tab.c

# 4. Ejecutar con archivo de entrada
./analizador input.c


=== Analizador Sintáctico Simplificado ===

Tipo: int
Declarada variable: globalA
Tipo: int  
Declarada variable: globalB
Tipo: int
Parámetro: a
Parámetro: b
Declarada función: suma con 2 parámetros
Bloque de código iniciado
Tipo: int
Declarada variable: resultado
Asignación a: resultado
Operación suma
Return con valor
Fin del bloque
...

Analisis completado. Errores: 0
✓ Programa válido
✓ Parseo exitoso
