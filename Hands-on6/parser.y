%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbols.h"
#include "semantic.h"

extern int yylex();
extern int yylineno;
extern FILE *yyin;
void yyerror(const char *s);

// SOLO declarar, no definir
extern Symbol *current_function;
extern int semantic_errors;
extern int declaration_type;
extern int expression_type;

// Inicializar las variables que son específicas del parser
int declaration_type = TYPE_INT;
int expression_type = TYPE_VOID;
Symbol *current_function = NULL;

%}

%union {
    int int_val;
    char *string_val;
    int count_val;
    int type_val;
}

%token <int_val> INTEGER
%token <string_val> IDENTIFIER FLOAT_NUM STRING_LITERAL CHAR_LITERAL
%token INT FLOAT CHAR VOID CONST
%token IF ELSE WHILE FOR DO RETURN
%token EQ NE LE GE AND OR

%type <count_val> parameter_list parameter argument_list
%type <type_val> type expression assignment_expression logical_expression
%type <type_val> relational_expression additive_expression multiplicative_expression
%type <type_val> unary_expression postfix_expression primary_expression

%nonassoc IFX
%nonassoc ELSE
%right '='
%left OR
%left AND
%left EQ NE
%left '<' '>' LE GE
%left '+' '-'
%left '*' '/' '%'
%right UMINUS

%%

program:
    {
        global_table = create_symbol_table(0);
        push_scope(global_table);
        printf("=== Iniciando Analisis Semantico ===\n");
    }
    global_declarations
    {
        printf("\n=== Analisis Semantico Completado ===\n");
        printf("Errores semanticos: %d\n", semantic_errors);
        if (semantic_errors == 0) {
            printf("✓ Programa semanticamente correcto\n");
        }
        print_symbol_table(global_table);
    }
    ;

// ... (el resto del parser se mantiene igual)
global_declarations:
    /* empty */
    | global_declarations global_declaration
    ;

global_declaration:
    function_definition
    | variable_declaration ';'
    ;

variable_declaration:
    type IDENTIFIER
    {
        Symbol *sym = create_symbol($2, SYM_VARIABLE, declaration_type, get_current_scope_level());
        if (!insert_symbol(get_current_scope(), sym)) {
            semantic_error("variable ya declarada");
        } else {
            printf("✓ Variable declarada: %s (%s)\n", $2, get_type_name(declaration_type));
        }
        free($2);
    }
    ;

type:
    INT { $$ = TYPE_INT; declaration_type = TYPE_INT; }
    | FLOAT { $$ = TYPE_FLOAT; declaration_type = TYPE_FLOAT; }
    | CHAR { $$ = TYPE_CHAR; declaration_type = TYPE_CHAR; }
    | VOID { $$ = TYPE_VOID; declaration_type = TYPE_VOID; }
    ;

function_definition:
    type IDENTIFIER '(' ')' 
    {
        Symbol *func_sym = create_symbol($2, SYM_FUNCTION, $1, 0);
        if (!insert_symbol(global_table, func_sym)) {
            semantic_error("funcion ya declarada");
        } else {
            printf("✓ Funcion declarada: %s (retorno: %s)\n", $2, get_type_name($1));
        }
        
        SymbolTable *func_scope = create_symbol_table(1);
        func_scope->parent = global_table;
        push_scope(func_scope);
        current_function = func_sym;
        free($2);
    }
    compound_statement
    {
        current_function->num_params = 0;
        SymbolTable *old_scope = pop_scope();
        if (old_scope->count > 0) {
            print_symbol_table(old_scope);
        }
        free_symbol_table(old_scope);
        current_function = NULL;
        printf("✓ Funcion completada\n");
    }
    | type IDENTIFIER '(' parameter_list ')' 
    {
        Symbol *func_sym = create_symbol($2, SYM_FUNCTION, $1, 0);
        if (!insert_symbol(global_table, func_sym)) {
            semantic_error("funcion ya declarada");
        } else {
            printf("✓ Funcion declarada: %s (retorno: %s)\n", $2, get_type_name($1));
        }
        
        SymbolTable *func_scope = create_symbol_table(1);
        func_scope->parent = global_table;
        push_scope(func_scope);
        current_function = func_sym;
        free($2);
    }
    compound_statement
    {
        current_function->num_params = $4;
        SymbolTable *old_scope = pop_scope();
        if (old_scope->count > 0) {
            print_symbol_table(old_scope);
        }
        free_symbol_table(old_scope);
        current_function = NULL;
    }
    ;

parameter_list:
    parameter
    { $$ = 1; }
    | parameter_list ',' parameter
    { $$ = $1 + 1; }
    ;

parameter:
    type IDENTIFIER
    {
        Symbol *param_sym = create_symbol($2, SYM_PARAMETER, $1, get_current_scope_level());
        if (!insert_symbol(get_current_scope(), param_sym)) {
            semantic_error("parametro ya declarado");
        } else {
            printf("✓ Parametro declarado: %s (%s)\n", $2, get_type_name($1));
        }
        free($2);
        $$ = 1;
    }
    ;

compound_statement:
    '{' '}'
    { printf("✓ Bloque vacio\n"); }
    | '{' statements '}'
    { printf("✓ Fin del bloque\n"); }
    ;

statements:
    statement
    | statements statement
    ;

statement:
    expression_statement
    | selection_statement
    | iteration_statement
    | jump_statement
    | compound_statement
    | variable_declaration ';'
    ;

expression_statement:
    expression ';'
    { printf("✓ Expresion valida (tipo: %s)\n", get_type_name(expression_type)); }
    | ';'
    { printf("✓ Statement vacio\n"); }
    ;

selection_statement:
    IF '(' expression ')' statement %prec IFX
    { printf("✓ If statement\n"); }
    | IF '(' expression ')' statement ELSE statement
    { printf("✓ If-else statement\n"); }
    ;

iteration_statement:
    WHILE '(' expression ')' statement
    { printf("✓ While loop\n"); }
    | FOR '(' expression_statement expression_statement expression ')' statement
    { printf("✓ For loop\n"); }
    | DO statement WHILE '(' expression ')' ';'
    { printf("✓ Do-while loop\n"); }
    ;

jump_statement:
    RETURN ';'
    {
        if (current_function && current_function->data_type != TYPE_VOID) {
            semantic_error("funcion no void debe retornar valor");
        } else {
            printf("✓ Return void\n");
        }
    }
    | RETURN expression ';'
    {
        if (current_function) {
            check_return_type(expression_type, current_function, yylineno);
        } else {
            semantic_error("return fuera de funcion");
        }
    }
    ;

expression:
    assignment_expression
    { $$ = expression_type; }
    ;

assignment_expression:
    logical_expression
    { $$ = expression_type; }
    | IDENTIFIER '=' assignment_expression
    {
        Symbol *sym = lookup_symbol_all_scopes(get_current_scope(), $1);
        if (!sym) {
            semantic_error("variable no declarada");
        } else {
            sym->is_initialized = 1;
            type_check_assignment(sym->data_type, expression_type, yylineno);
            printf("✓ Asignacion a: %s\n", $1);
        }
        $$ = sym ? sym->data_type : TYPE_INT;
        expression_type = $$;
        free($1);
    }
    ;

logical_expression:
    relational_expression
    { $$ = expression_type; }
    | logical_expression AND relational_expression
    {
        type_check_binary_operation($1, $3, "&&", yylineno);
        $$ = TYPE_INT;
        expression_type = $$;
        printf("✓ Operacion AND\n");
    }
    | logical_expression OR relational_expression
    {
        type_check_binary_operation($1, $3, "||", yylineno);
        $$ = TYPE_INT;
        expression_type = $$;
        printf("✓ Operacion OR\n");
    }
    ;

relational_expression:
    additive_expression
    { $$ = expression_type; }
    | relational_expression '<' additive_expression
    {
        type_check_binary_operation($1, $3, "<", yylineno);
        $$ = TYPE_INT;
        expression_type = $$;
        printf("✓ Operacion <\n");
    }
    | relational_expression '>' additive_expression
    {
        type_check_binary_operation($1, $3, ">", yylineno);
        $$ = TYPE_INT;
        expression_type = $$;
        printf("✓ Operacion >\n");
    }
    | relational_expression LE additive_expression
    {
        type_check_binary_operation($1, $3, "<=", yylineno);
        $$ = TYPE_INT;
        expression_type = $$;
        printf("✓ Operacion <=\n");
    }
    | relational_expression GE additive_expression
    {
        type_check_binary_operation($1, $3, ">=", yylineno);
        $$ = TYPE_INT;
        expression_type = $$;
        printf("✓ Operacion >=\n");
    }
    | relational_expression EQ additive_expression
    {
        type_check_binary_operation($1, $3, "==", yylineno);
        $$ = TYPE_INT;
        expression_type = $$;
        printf("✓ Operacion ==\n");
    }
    | relational_expression NE additive_expression
    {
        type_check_binary_operation($1, $3, "!=", yylineno);
        $$ = TYPE_INT;
        expression_type = $$;
        printf("✓ Operacion !=\n");
    }
    ;

additive_expression:
    multiplicative_expression
    { $$ = expression_type; }
    | additive_expression '+' multiplicative_expression
    {
        type_check_binary_operation($1, $3, "+", yylineno);
        $$ = ($1 == TYPE_FLOAT || $3 == TYPE_FLOAT) ? TYPE_FLOAT : TYPE_INT;
        expression_type = $$;
        printf("✓ Operacion +\n");
    }
    | additive_expression '-' multiplicative_expression
    {
        type_check_binary_operation($1, $3, "-", yylineno);
        $$ = ($1 == TYPE_FLOAT || $3 == TYPE_FLOAT) ? TYPE_FLOAT : TYPE_INT;
        expression_type = $$;
        printf("✓ Operacion -\n");
    }
    ;

multiplicative_expression:
    unary_expression
    { $$ = expression_type; }
    | multiplicative_expression '*' unary_expression
    {
        type_check_binary_operation($1, $3, "*", yylineno);
        $$ = ($1 == TYPE_FLOAT || $3 == TYPE_FLOAT) ? TYPE_FLOAT : TYPE_INT;
        expression_type = $$;
        printf("✓ Operacion *\n");
    }
    | multiplicative_expression '/' unary_expression
    {
        type_check_binary_operation($1, $3, "/", yylineno);
        $$ = TYPE_FLOAT;
        expression_type = $$;
        printf("✓ Operacion /\n");
    }
    | multiplicative_expression '%' unary_expression
    {
        type_check_binary_operation($1, $3, "%", yylineno);
        $$ = TYPE_INT;
        expression_type = $$;
        printf("✓ Operacion %%\n");
    }
    ;

unary_expression:
    postfix_expression
    { $$ = expression_type; }
    | '-' unary_expression %prec UMINUS
    {
        type_check_unary_operation(expression_type, "-", yylineno);
        $$ = expression_type;
        printf("✓ Operacion menos unario\n");
    }
    | '+' unary_expression
    {
        type_check_unary_operation(expression_type, "+", yylineno);
        $$ = expression_type;
        printf("✓ Operacion mas unario\n");
    }
    | '!' unary_expression
    {
        type_check_unary_operation(expression_type, "!", yylineno);
        $$ = TYPE_INT;
        expression_type = $$;
        printf("✓ Operacion NOT\n");
    }
    ;

postfix_expression:
    primary_expression
    { $$ = expression_type; }
    | IDENTIFIER '(' ')'
    {
        Symbol *func_sym = lookup_symbol_all_scopes(get_current_scope(), $1);
        if (check_function_call(func_sym, 0, yylineno)) {
            printf("✓ Llamada a funcion: %s\n", $1);
        }
        $$ = func_sym ? func_sym->data_type : TYPE_INT;
        expression_type = $$;
        free($1);
    }
    | IDENTIFIER '(' argument_list ')'
    {
        Symbol *func_sym = lookup_symbol_all_scopes(get_current_scope(), $1);
        if (check_function_call(func_sym, $3, yylineno)) {
            printf("✓ Llamada a funcion: %s (%d args)\n", $1, $3);
        }
        $$ = func_sym ? func_sym->data_type : TYPE_INT;
        expression_type = $$;
        free($1);
    }
    ;

primary_expression:
    IDENTIFIER
    {
        Symbol *sym = lookup_symbol_all_scopes(get_current_scope(), $1);
        if (!sym) {
            semantic_error("identificador no declarado");
            $$ = TYPE_INT;
        } else {
            $$ = sym->data_type;
            check_variable_usage(sym, yylineno);
            printf("✓ Identificador: %s (%s)\n", $1, get_type_name(sym->data_type));
        }
        expression_type = $$;
        free($1);
    }
    | INTEGER
    {
        $$ = TYPE_INT;
        expression_type = $$;
        printf("✓ Entero: %d\n", $1);
    }
    | FLOAT_NUM
    {
        $$ = TYPE_FLOAT;
        expression_type = $$;
        printf("✓ Float: %s\n", $1);
        free($1);
    }
    | STRING_LITERAL
    {
        $$ = TYPE_STRING;
        expression_type = $$;
        printf("✓ String: %s\n", $1);
        free($1);
    }
    | CHAR_LITERAL
    {
        $$ = TYPE_CHAR;
        expression_type = $$;
        printf("✓ Char: %s\n", $1);
        free($1);
    }
    | '(' expression ')'
    {
        $$ = $2;
        expression_type = $$;
    }
    ;

argument_list:
    expression
    { $$ = 1; }
    | argument_list ',' expression
    { $$ = $1 + 1; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error de sintaxis (linea %d): %s\n", yylineno, s);
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "No se pudo abrir: %s\n", argv[1]);
            return 1;
        }
        yyin = file;
    }
    
    int result = yyparse();
    
    if (global_table) {
        free_symbol_table(global_table);
    }
    
    return result;
}
