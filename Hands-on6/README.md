Descripción General

Este proyecto extiende el analizador sintáctico desarrollado en el Hands-on 5 para incorporar un análisis semántico básico y por scopes, utilizando Tablas de Símbolos, una tabla global y una pila de scopes para manejar contextos anidados

Alcance del Análisis Semántico
El analizador semántico implementa las siguientes validaciones:

✔ Validaciones básicas

Uso de variables no declaradas.

Redeclaración de símbolos (variables, constantes, funciones).

Verificación del número de parámetros en llamadas a funciones.

✔ Scopes y manejo de contexto

Tabla de símbolos global.

Tablas locales para funciones y bloques {}.

Pila de scopes para manejar contextos anidados.

Distinción entre declaraciones globales y locales.

✔ Opcional implementado (si aplica en tu código)

Validación simple de estructuras de control (if, while, for)
para asegurar que las variables usadas estén declaradas en el scope correspondiente.

Archivos incluidos

parser.y – Contiene las reglas sintácticas y acciones semánticas.

lexer.l – Analizador léxico usado por Flex.

input.c – Archivo de prueba para validar declaraciones, scopes y errores.

README.md – Este documento.
