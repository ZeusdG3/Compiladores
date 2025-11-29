#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbols.h"
#include "semantic.h"

// DEFINIR las variables aquí
int semantic_errors = 0;
extern int yylineno;

void semantic_error(const char *message) {
    fprintf(stderr, "Error semantico (linea %d): %s\n", yylineno, message);
    semantic_errors++;
}

const char* get_type_name(int type) {
    switch(type) {
        case TYPE_INT: return "int";
        case TYPE_FLOAT: return "float";
        case TYPE_CHAR: return "char";
        case TYPE_VOID: return "void";
        case TYPE_STRING: return "string";
        default: return "desconocido";
    }
}

int are_types_compatible(int type1, int type2) {
    if (type1 == type2) return 1;
    if (type1 == TYPE_FLOAT && type2 == TYPE_INT) return 1;
    if (type1 == TYPE_INT && type2 == TYPE_CHAR) return 1;
    if (type1 == TYPE_FLOAT && type2 == TYPE_CHAR) return 1;
    return 0;
}

void type_check_assignment(int left_type, int right_type, int line) {
    if (!are_types_compatible(left_type, right_type)) {
        semantic_error("asignacion incompatible");
        fprintf(stderr, "  Esperado: %s, Obtenido: %s\n", 
                get_type_name(left_type), get_type_name(right_type));
    }
}

void type_check_binary_operation(int left_type, int right_type, char* op, int line) {
    if (!are_types_compatible(left_type, right_type)) {
        semantic_error("tipos incompatibles en operacion binaria");
        fprintf(stderr, "  Operacion: %s, Tipos: %s y %s\n", 
                op, get_type_name(left_type), get_type_name(right_type));
    }
    
    if (strcmp(op, "%") == 0) {
        if (left_type != TYPE_INT || right_type != TYPE_INT) {
            semantic_error("operador '%' requiere operandos enteros");
        }
    }
}

void type_check_unary_operation(int operand_type, char* op, int line) {
    if (strcmp(op, "!") == 0) {
        if (operand_type != TYPE_INT && operand_type != TYPE_FLOAT) {
            semantic_error("operador '!' requiere operando numerico");
        }
    }
}

int check_function_call(Symbol *func_sym, int arg_count, int line) {
    if (!func_sym) {
        semantic_error("funcion no declarada");
        return 0;
    }
    
    if (func_sym->sym_type != SYM_FUNCTION) {
        semantic_error("no es una funcion");
        return 0;
    }
    
    if (func_sym->num_params != arg_count) {
        semantic_error("numero incorrecto de argumentos");
        fprintf(stderr, "  Esperado: %d, Obtenido: %d\n", 
                func_sym->num_params, arg_count);
        return 0;
    }
    
    return 1;
}

void check_return_type(int return_type, Symbol *current_function, int line) {
    if (!current_function) {
        semantic_error("return fuera de funcion");
        return;
    }
    
    if (!are_types_compatible(current_function->data_type, return_type)) {
        semantic_error("tipo de retorno incompatible");
        fprintf(stderr, "  Funcion retorna: %s, Declarado: %s\n", 
                get_type_name(return_type), get_type_name(current_function->data_type));
    }
}

void check_variable_usage(Symbol *sym, int line) {
    if (!sym) return;
    
    if (!sym->is_initialized && sym->sym_type == SYM_VARIABLE) {
        fprintf(stderr, "Advertencia semantica (linea %d): variable '%s' puede no estar inicializada\n", 
                line, sym->name);
    }
}
