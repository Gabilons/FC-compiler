/* Written by Kampylafkas Anastasios on April 23 2017 */

/* Definitions Section */

%{

  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <assert.h>

  /* For the tokens to be defined */
  #include "FC_parser.tab.h"

  /* Useful functions */
  #include "cgen.h"

  int lineNum = 1;

%}

/* Flags to get rid of annoying warnings */
%option nounput
%option noinput

/* Identifiers */
ID                    [a-zA-Z][0-9a-zA-Z_]*

/* Numbers */
DIGIT                 [0-9]
NUMBER                {DIGIT}{DIGIT}*
DECIMAL               {NUMBER}("."{NUMBER})?
REAL                  {DECIMAL}([eE][+-]?{DECIMAL})?

INLINE_COMMENT        [\/][\/](.)*

CONST_STRING          ([\"]([^\n'"\\]|[\\][n]|[\\][t]|[\\][r]|[\\][\\]|[\\][']|[\\]["])*[\"])

CONST_CHAR            ([\']([^\n'"\\]|[\\][n]|[\\][t]|[\\][r]|[\\][\\]|[\\][']|[\\]["])?[\'])

/* Exclusive start condition */
%x comment

%%

(?-i:static)		      { return KW_STATIC; }

(?-i:boolean)		      { return KW_BOOLEAN; }
(?-i:integer)         { return KW_INTEGER; }
(?-i:char)	          { return KW_CHAR; }
(?-i:real)	          { return KW_REAL; }
(?-i:string)	        { return KW_STRING; }

(?-i:void)	          { return KW_VOID; }

(?-i:true)	          { return KW_TRUE; }
(?-i:false)	          { return KW_FALSE; }

(?-i:while)	          { return KW_WHILE; }
(?-i:for)	            { return KW_FOR; }
(?-i:do)	            { return KW_DO; }
(?-i:break)	          { return KW_BREAK; }
(?-i:continue)	      { return KW_CONTINUE; }
(?-i:return)	        { return KW_RETURN; }

(?-i:begin)	          { return KW_BEGIN; }
(?-i:end)	            { return KW_END; }

(?-i:if)	            { return KW_IF; }
(?-i:else)	          { return KW_ELSE; }

\+						        { return OP_PLUS; }
\-						        { return OP_MINUS; }
\*						        { return OP_MULTIPLY; }
\/						        { return OP_DIVIDE; }
(?-i:mod)	            { return KW_MOD; }

\=						        { return OP_EQUAL; }
\!\=					        { return OP_NOT_EQUAL; }
\<						        { return OP_LESS; }
\<\=					        { return OP_LESS_OR_EQUAL; }
\>						        { return OP_GREATER; }
\>\=					        { return OP_GREATER_OR_EQUAL; }

(?-i:and)	            { return KW_AND; }
\&\&					        { return OP_AND; }
(?-i:or)	            { return KW_OR; }
\|\|					        { return OP_OR; }
(?-i:not)	            { return KW_NOT; }
\!						        { return OP_NOT; }

\;						        { return DEL_SEMICOLON; }

\,						        { return DEL_COMMA; }

\(						        { return DEL_LEFT_PARENTHESES; }
\)						        { return DEL_RIGHT_PARENTHESES; }
\[						        { return DEL_LEFT_BRACKET; }
\]						        { return DEL_RIGHT_BRACKET; }

\:\=					        { return OP_ASSIGNMENT; }

(?-i:readString) 		  { return KW_READ_STRING; }
(?-i:readInteger) 		{ return KW_READ_INTEGER; }
(?-i:readReal) 			  { return KW_READ_REAL; }

(?-i:writeString) 		{ return KW_WRITE_STRING; }
(?-i:writeInteger)		{ return KW_WRITE_INTEGER; }
(?-i:writeReal) 		  { return KW_WRITE_REAL; }

{ID}                  { yylval.str = strdup(yytext); return IDENT; }

{NUMBER}              { yylval.intNum = atoi(yytext); return POSINT; }

{REAL}                { yylval.doubleNum = atof(yytext); return REAL; }

{INLINE_COMMENT}      /* Eat commnent */

{CONST_CHAR}          { yylval.str = strdup(yytext); return CONST_CHAR; }

{CONST_STRING}        { yylval.str = strdup(yytext); return CONST_STRING; }

"/*"					        BEGIN(comment);
<comment>[^*\n]*      /* Eat anything that's not a '*' */
<comment>"*"+[^*/\n]* /* Eat up '*'s not followed by '/' */
<comment>\n           ++lineNum;
<comment>"*"+"/"      BEGIN(INITIAL);

[ \r\t]+		          /* Eat whitespace */

\n 					          ++lineNum;

<<EOF>> 				      return EOF;

.                     { yyerror("\nLexical Error: Unrecognized literal \"%s\" in line: %d\n", yytext, lineNum); return EOF;}

%%
