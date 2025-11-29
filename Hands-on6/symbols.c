#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "symbols.h"

SymbolTable *global_table = NULL;
SymbolTable *current_scope = NULL;
SymbolTable *scope_stack[MAX_SCOPE_LEVEL];
int scope_stack_top = -1;

void push_scope(SymbolTable *table) {
    if (scope_stack_top < MAX_SCOPE_LEVEL - 1) {
        scope_stack[++scope_stack_top] = table;
        current_scope = table;
    }
}

SymbolTable* pop_scope(void) {
    if (scope_stack_top >= 0) {
        SymbolTable *old_scope = scope_stack[scope_stack_top--];
        if (scope_stack_top >= 0) {
            current_scope = scope_stack[scope_stack_top];
        } else {
            current_scope = global_table;
        }
        return old_scope;
    }
    return NULL;
}

SymbolTable* get_current_scope(void) {
    return current_scope;
}

int get_current_scope_level(void) {
    return current_scope ? current_scope->scope_level : 0;
}

SymbolTable* create_symbol_table(int scope_level) {
    SymbolTable *table = (SymbolTable*)malloc(sizeof(SymbolTable));
    table->scope_level = scope_level;
    table->count = 0;
    table->parent = NULL;
    
    for (int i = 0; i < MAX_SYMBOLS; i++) {
        table->symbols[i] = NULL;
    }
    
    return table;
}

void free_symbol_table(SymbolTable *table) {
    if (!table) return;
    
    for (int i = 0; i < MAX_SYMBOLS; i++) {
        Symbol *current = table->symbols[i];
        while (current) {
            Symbol *next = current->next;
            free(current->name);
            free(current);
            current = next;
        }
    }
    free(table);
}

unsigned int hash(char *name) {
    unsigned int hashval = 0;
    for (; *name != '\0'; name++) {
        hashval = *name + 31 * hashval;
    }
    return hashval % MAX_SYMBOLS;
}

Symbol* create_symbol(char *name, int sym_type, int data_type, int scope_level) {
    Symbol *sym = (Symbol*)malloc(sizeof(Symbol));
    sym->name = strdup(name);
    sym->sym_type = sym_type;
    sym->data_type = data_type;
    sym->scope_level = scope_level;
    sym->is_initialized = 0;
    sym->num_params = 0;
    sym->next = NULL;
    return sym;
}

int insert_symbol(SymbolTable *table, Symbol *sym) {
    if (!table || !sym) return 0;
    
    unsigned int index = hash(sym->name);
    
    Symbol *current = table->symbols[index];
    while (current) {
        if (strcmp(current->name, sym->name) == 0 && 
            current->scope_level == sym->scope_level) {
            return 0;
        }
        current = current->next;
    }
    
    sym->next = table->symbols[index];
    table->symbols[index] = sym;
    table->count++;
    
    return 1;
}

Symbol* lookup_symbol(SymbolTable *table, char *name) {
    if (!table || !name) return NULL;
    
    unsigned int index = hash(name);
    Symbol *current = table->symbols[index];
    
    while (current) {
        if (strcmp(current->name, name) == 0) {
            return current;
        }
        current = current->next;
    }
    
    return NULL;
}

Symbol* lookup_symbol_all_scopes(SymbolTable *table, char *name) {
    SymbolTable *current_table = table;
    
    while (current_table) {
        Symbol *sym = lookup_symbol(current_table, name);
        if (sym) {
            return sym;
        }
        current_table = current_table->parent;
    }
    
    return NULL;
}

void print_symbol_table(SymbolTable *table) {
    if (!table) return;
    
    printf("\n--- Tabla de Simbolos (Nivel %d) ---\n", table->scope_level);
    printf("%-20s %-12s %-10s %-8s %-12s\n", 
           "Nombre", "Tipo", "Tipo Dato", "Scope", "Inicializado");
    printf("------------------------------------------------------------\n");
    
    int count = 0;
    for (int i = 0; i < MAX_SYMBOLS; i++) {
        Symbol *current = table->symbols[i];
        while (current) {
            const char *type_str = "";
            switch (current->sym_type) {
                case SYM_VARIABLE: type_str = "Variable"; break;
                case SYM_FUNCTION: type_str = "Funcion"; break;
                case SYM_PARAMETER: type_str = "Parametro"; break;
            }
            
            const char *data_type_str = "";
            switch (current->data_type) {
                case TYPE_INT: data_type_str = "int"; break;
                case TYPE_FLOAT: data_type_str = "float"; break;
                case TYPE_CHAR: data_type_str = "char"; break;
                case TYPE_VOID: data_type_str = "void"; break;
                case TYPE_STRING: data_type_str = "string"; break;
            }
            
            printf("%-20s %-12s %-10s %-8d %-12s\n", 
                   current->name, type_str, data_type_str, 
                   current->scope_level, 
                   current->is_initialized ? "Si" : "No");
            
            current = current->next;
            count++;
        }
    }
    
    if (count == 0) {
        printf("(vacia)\n");
    }
    printf("Total simbolos: %d\n", count);
}
