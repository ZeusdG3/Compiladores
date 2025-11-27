# Analizador Léxico (Flex)

## Descripción
Este proyecto contiene un analizador léxico implementado con **Flex** que reconoce
un subconjunto del lenguaje C. El lexer identifica palabras reservadas, identificadores,
literales numéricos, operadores, delimitadores, directivas de preprocesador (#include, #define)
y comentarios (/* ... */ y //...). Para cada token impreso muestra el tipo, el lexema y la línea.


## Archivos incluidos
- `lexer.l` : Archivo fuente de Flex que define las reglas léxicas.
- `input.c` : Ejemplo de código C para analizar.


## Requisitos
- flex
- gcc (o compilador compatible)
