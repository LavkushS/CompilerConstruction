%option noyywrap

%{
#include "parser.hh"
#include <string>

extern int yyerror(std::string msg);
%}

%%

"+"       { return TPLUS; }
"-"       { return TDASH; }
"*"       { return TSTAR; }
"/"       { return TSLASH; }
";"       { return TSCOL; }
"("       { return TLPAREN; }
")"       { return TRPAREN; }
"="       { return TEQUAL; }
"dbg"     { return TDBG; }
"let"     { return TLET; }
"if"      { return TIF; }
"else"      { return TELSE; }
"{"         { return TLCURL; }
"}"         { return TRCURL; }
":"       { return TCOLON; }
"int"     { return TTYPEI; }
"short"     { return TTYPES; }
"long"     { return TTYPEL; }
"fun"       {return TFUN;}
"main"      {return TMAIN;}
[0-9]+    { yylval.lexeme = std::string(yytext); return TINT_LIT; }
[a-zA-Z]+ { yylval.lexeme = std::string(yytext); return TIDENT; }
[ \t\n]   { /* skip */ }
"//".*\n            {  }
"/*"[^*/]*"*/"      {  }
.         { yyerror("unknown char"); }

%%

std::string token_to_string(int token, const char *lexeme) {
    std::string s;
    switch (token) {
        case TPLUS: s = "TPLUS"; break;
        case TDASH: s = "TDASH"; break;
        case TSTAR: s = "TSTAR"; break;
        case TSLASH: s = "TSLASH"; break;
        case TSCOL: s = "TSCOL"; break;
        case TLPAREN: s = "TLPAREN"; break;
        case TRPAREN: s = "TRPAREN"; break;
        case TEQUAL: s = "TEQUAL"; break;
        
        case TDBG: s = "TDBG"; break;
        case TLET: s = "TLET"; break;

        case TCOLON: s = "TCOLON";  break;
        case TTYPEI: s= "TTYPEI"; break;
        case TTYPES: s= "TTYPES"; break;
        case TTYPEL: s= "TTYPEL"; break;
        case TIF: s= "TIF"; break;
        case TELSE: s= "TELSE"; break;
        case TLCURL: s= "TLCURL"; break;
        case TRCURL: s= "TRCURL"; break;
        case TFUN: s="TFUN"; break;
        case TMAIN: s="TMAIN"; break;
        
        case TINT_LIT: s = "TINT_LIT"; s.append("  ").append(lexeme); break;
        case TIDENT: s = "TIDENT"; s.append("  ").append(lexeme); break;
    }

    return s;
}