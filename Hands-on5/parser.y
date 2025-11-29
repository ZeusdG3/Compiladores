%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
extern FILE *yyin;
void yyerror(const char *s);

int semantic_errors = 0;

%}

%union {
    int int_val;
    char *string_val;
    int count_val;
}

%token <int_val> INTEGER
%token <string_val> IDENTIFIER FLOAT_NUM STRING_LITERAL CHAR_LITERAL
%token INT FLOAT CHAR VOID CONST
%token IF ELSE WHILE FOR DO RETURN
%token EQ NE LE GE AND OR

%type <count_val> parameter_list parameter argument_list

/* Precedencia de operadores */
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
    global_declarations
    {
        printf("\nAnalisis completado. Errores: %d\n", semantic_errors);
        if (semantic_errors == 0) {
            printf("✓ Programa valido\n");
        }
    }
    ;

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
        printf("Declarada variable: %s\n", $2);
        free($2);
    }
    ;

type:
    INT { printf("Tipo: int\n"); }
    | FLOAT { printf("Tipo: float\n"); }
    | CHAR { printf("Tipo: char\n"); }
    | VOID { printf("Tipo: void\n"); }
    ;

function_definition:
    type IDENTIFIER '(' ')' compound_statement
    {
        printf("Declarada funcion: %s (sin parametros)\n", $2);
        free($2);
    }
    | type IDENTIFIER '(' parameter_list ')' compound_statement
    {
        printf("Declarada funcion: %s con %d parametros\n", $2, $4);
        free($2);
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
        printf("Parametro: %s\n", $2);
        free($2);
        $$ = 1;
    }
    ;

compound_statement:
    '{' '}'
    { printf("Bloque vacio\n"); }
    | '{' statements '}'
    { printf("Fin del bloque\n"); }
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
    { printf("Expresion valida\n"); }
    | ';'
    { printf("Statement vacio\n"); }
    ;

selection_statement:
    IF '(' expression ')' statement %prec IFX
    { printf("If statement\n"); }
    | IF '(' expression ')' statement ELSE statement
    { printf("If-else statement\n"); }
    ;

iteration_statement:
    WHILE '(' expression ')' statement
    { printf("While loop\n"); }
    | FOR '(' expression_statement expression_statement expression ')' statement
    { printf("For loop\n"); }
    | DO statement WHILE '(' expression ')' ';'
    { printf("Do-while loop\n"); }
    ;

jump_statement:
    RETURN ';'
    { printf("Return void\n"); }
    | RETURN expression ';'
    { printf("Return con valor\n"); }
    ;

expression:
    assignment_expression
    ;

assignment_expression:
    logical_expression
    | IDENTIFIER '=' assignment_expression
    {
        printf("Asignacion a: %s\n", $1);
        free($1);
    }
    ;

logical_expression:
    relational_expression
    | logical_expression AND relational_expression
    { printf("Operacion AND logico\n"); }
    | logical_expression OR relational_expression
    { printf("Operacion OR logico\n"); }
    ;

relational_expression:
    additive_expression
    | relational_expression '<' additive_expression
    { printf("Operacion menor que\n"); }
    | relational_expression '>' additive_expression
    { printf("Operacion mayor que\n"); }
    | relational_expression LE additive_expression
    { printf("Operacion menor o igual\n"); }
    | relational_expression GE additive_expression
    { printf("Operacion mayor o igual\n"); }
    | relational_expression EQ additive_expression
    { printf("Operacion igualdad\n"); }
    | relational_expression NE additive_expression
    { printf("Operacion desigualdad\n"); }
    ;

additive_expression:
    multiplicative_expression
    | additive_expression '+' multiplicative_expression
    { printf("Operacion suma\n"); }
    | additive_expression '-' multiplicative_expression
    { printf("Operacion resta\n"); }
    ;

multiplicative_expression:
    unary_expression
    | multiplicative_expression '*' unary_expression
    { printf("Operacion multiplicacion\n"); }
    | multiplicative_expression '/' unary_expression
    { printf("Operacion division\n"); }
    | multiplicative_expression '%' unary_expression
    { printf("Operacion modulo\n"); }
    ;

unary_expression:
    postfix_expression
    | '-' unary_expression %prec UMINUS
    { printf("Operacion menos unario\n"); }
    | '+' unary_expression
    { printf("Operacion mas unario\n"); }
    | '!' unary_expression
    { printf("Operacion NOT logico\n"); }
    ;

postfix_expression:
    primary_expression
    | IDENTIFIER '(' ')'
    {
        printf("Llamada a funcion: %s (sin argumentos)\n", $1);
        free($1);
    }
    | IDENTIFIER '(' argument_list ')'
    {
        printf("Llamada a funcion: %s con %d argumentos\n", $1, $3);
        free($1);
    }
    ;

primary_expression:
    IDENTIFIER
    {
        printf("Identificador: %s\n", $1);
        free($1);
    }
    | INTEGER
    { printf("Entero: %d\n", $1); }
    | FLOAT_NUM
    { printf("Float: %s\n", $1); free($1); }
    | STRING_LITERAL
    { printf("String: %s\n", $1); free($1); }
    | CHAR_LITERAL
    { printf("Char: %s\n", $1); free($1); }
    | '(' expression ')'
    ;

argument_list:
    expression
    { $$ = 1; }
    | argument_list ',' expression
    { $$ = $1 + 1; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error en linea %d: %s\n", yylineno, s);
}

int main(int argc, char *argv[]) {
    printf("=== Analizador Sintactico Simplificado ===\n");
    
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            fprintf(stderr, "No se pudo abrir: %s\n", argv[1]);
            return 1;
        }
        yyin = file;
    }
    
    int result = yyparse();
    
    if (result == 0) {
        printf("✓ Parseo exitoso\n");
    } else {
        printf("✗ Error en el parseo\n");
    }
    
    return result;
}
