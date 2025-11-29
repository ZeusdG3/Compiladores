%{
#include "y.tab.h"
#include <stdlib.h>
#include <string.h>

extern int yylineno;
%}

DIGIT    [0-9]
ID       [a-zA-Z_][a-zA-Z0-9_]*
STRING   \"([^"\\]|\\.)*\"
CHAR     \'([^'\\]|\\.)*\'
FLOAT_RE ({DIGIT}+\.{DIGIT}+|{DIGIT}+\.|\.{DIGIT}+)

%%

"int"       return INT;
"float"     return FLOAT;
"char"      return CHAR;
"void"      return VOID;
"const"     return CONST;
"if"        return IF;
"else"      return ELSE;
"while"     return WHILE;
"for"       return FOR;
"do"        return DO;
"return"    return RETURN;
"=="        return EQ;
"!="        return NE;
"<="        return LE;
">="        return GE;
"&&"        return AND;
"||"        return OR;

{ID}        { yylval.string_val = strdup(yytext); return IDENTIFIER; }
{FLOAT_RE}  { yylval.string_val = strdup(yytext); return FLOAT_NUM; }
{DIGIT}+    { yylval.int_val = atoi(yytext); return INTEGER; }
{STRING}    { yylval.string_val = strdup(yytext); return STRING_LITERAL; }
{CHAR}      { yylval.string_val = strdup(yytext); return CHAR_LITERAL; }

[ \t\n]+    ;
.           { return yytext[0]; }

%%

int yywrap() {
    return 1;
}
