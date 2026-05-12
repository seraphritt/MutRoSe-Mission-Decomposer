%option prefix="xy"
%option noyywrap

%{
    #include <iostream>
    #include <vector>
    #include <cstring>

    #include "../utils/query.hpp"
    #include "queryparser.hpp"

    using namespace std;

    static int current_line = 1;
    static int current_column = 1;

    #define YY_USER_ACTION                                      \
        xylloc.first_line = current_line;                       \
        xylloc.first_column = current_column;                   \
        for (int i = 0; i < yyleng; ++i) {                      \
            if (yytext[i] == '\n') {                            \
                current_line++;                                 \
                current_column = 1;                             \
            } else {                                            \
                current_column++;                               \
            }                                                   \
        }                                                       \
        xylloc.last_line = current_line;                        \
        xylloc.last_column = current_column - 1;
%}

%%

\(                              { return '('; }
\)                              { return ')'; }
\&\&                            { return KEY_AND; }
\|\|                            { return KEY_OR; }

[ \t\n\r]                       ; /* whitespace */

[!a-zA-Z]{1}[a-zA-Z0-9_. ="<>]* {
                                    xylval.sval = strdup(yytext);
                                    return STRNAME;
                                }

%%

void set_input_query(const char* in) {
    yy_scan_string(in);

    current_line = 1;
    current_column = 1;

    xylloc.first_line = 1;
    xylloc.last_line = 1;
    xylloc.first_column = 1;
    xylloc.last_column = 1;
}

void end_scan(void) {
    yy_delete_buffer(YY_CURRENT_BUFFER);
}
