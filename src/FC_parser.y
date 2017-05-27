/* Written by Kampylafkas Anastasios on May 13 2017 */

%{

  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include <stdarg.h>

  #include "cgen.h"

  extern int yylex(void);
  extern int lineNum;

%}

/*
  The union here is used to specify a collection of all possible data types.
  It is used to for semantics checking.
*/
%union
{
  char* str;
  int intNum;
  double doubleNum;
}

/* Enable parser tracing and verbose error messages */
%define parse.trace
%define parse.error verbose

/* Terminal symbols */
%token KW_STATIC;
%token KW_BOOLEAN;
%token KW_INTEGER;
%token KW_CHAR;
%token KW_REAL;
%token KW_STRING;

%token KW_VOID;

%token KW_TRUE
%token KW_FALSE

%token KW_WHILE;
%token KW_FOR
%token KW_DO
%token KW_BREAK
%token KW_CONTINUE
%token KW_RETURN

%token KW_BEGIN
%token KW_END

%token DEL_SEMICOLON

%token DEL_COMMA

%token KW_READ_STRING
%token KW_WRITE_STRING

%token KW_READ_INTEGER
%token KW_WRITE_INTEGER

%token KW_READ_REAL
%token KW_WRITE_REAL

/* Declaration of the type of token when needed */
%token <str> IDENT

%token <intNum> POSINT
%token <doubleNum> REAL

%token <str> CONST_CHAR
%token <str> CONST_STRING

%token OP_ASSIGNMENT

%token DEL_RIGHT_PARENTHESES
%token DEL_LEFT_PARENTHESES

%token DEL_RIGHT_BRACKET
%token DEL_LEFT_BRACKET

%token KW_IF

/* Set left/right associativity */
%left KW_OR OP_OR
%left KW_AND OP_AND
%left OP_EQUAL OP_NOT_EQUAL OP_LESS OP_LESS_OR_EQUAL OP_GREATER OP_GREATER_OR_EQUAL
%right OP_PLUS OP_MINUS
%left OP_MULTIPLY OP_DIVIDE KW_MOD
%left MINUS_PLUS_PRECEDENCE
%right KW_NOT OP_NOT

/* Precedence to get rid of the annoying Shift/Reduce */
%precedence IF_PRECEDENCE
%precedence KW_ELSE

/* Terminal symbols */
%start program

/* Variables terminal symbols */
%type <str> programs_body
%type <str> variables
%type <str> data_type
%type <str> dimensions_or_assignment
%type <str> more_variables
%type <str> dimensions
%type <str> assignment
%type <str> sign
%type <str> character_or_boolean
%type <str> dimension_expression


/* Functions terminal symbols */
%type <str> function
%type <str> parameters
%type <str> functions_body
%type <str> more_functions
%type <str> more_parameters

/* Expressions terminal symbols */
%type <str> expression
%type <str> expressions

/* Statements terminal symbols */
%type <str> statement
%type <str> statements
%type <str> for_assignment

%%

/**************************************************************  Program (Top level) ****************************************************/

program: programs_body
{
	/*
		We have a successful parse!
		Check for any errors and generate output.
	*/
	if( yyerror_count==0 )
	{
		puts(c_prologue);
    printf("%s", $1);
		printf("\n/*Your program is lexicaly and syntactically correct!!*/");
	}
};

/**************************************************************  Variables **************************************************************/

programs_body:   variables programs_body      { $$ = template("%s\n%s", $1, $2); }
               | function more_functions      { $$ = template("\n%s\n%s", $1, $2); }

variables:             data_type IDENT dimensions_or_assignment more_variables DEL_SEMICOLON        { $$ = template("%s %s%s%s", $1, $2, $3, $4); }
           | KW_STATIC data_type IDENT dimensions_or_assignment more_variables DEL_SEMICOLON        { $$ = template("static %s %s%s%s", $2, $3, $4, $5); }

data_type:  KW_INTEGER             { $$ = template("int"); }
          | KW_BOOLEAN             { $$ = template("int"); }
          | KW_CHAR                { $$ = template("char"); }
          | KW_REAL                { $$ = template("double"); }
          | KW_STRING              { $$ = template("char*"); }

dimensions_or_assignment:   dimensions        { $$ = template("%s", $1); }
                          | assignment        { $$ = template("%s", $1); }

dimensions:   %empty                                                                    { $$ = template(""); }
            | DEL_LEFT_BRACKET dimension_expression DEL_RIGHT_BRACKET dimensions        { $$ = template("[abs((int)%s)]%s", $2, $4); }

dimension_expression:   POSINT                                                                { $$ = template("%d", $1); }
                      | REAL                                                                  { $$ = template("%lf", $1); }
                      | IDENT                                                                 { $$ = template("%s", $1); }
                      | DEL_LEFT_PARENTHESES dimension_expression DEL_RIGHT_PARENTHESES       { $$ = template("(%s)", $2); }
                      | dimension_expression OP_PLUS dimension_expression											{ $$ = template("%s + %s", $1, $3); }
              		    | dimension_expression OP_MINUS dimension_expression										{ $$ = template("%s - %s", $1, $3); }
              		    | dimension_expression OP_MULTIPLY dimension_expression									{ $$ = template("%s * %s", $1, $3); }
              		    | dimension_expression OP_DIVIDE dimension_expression										{ $$ = template("%s / %s", $1, $3); }
              	 	    | dimension_expression KW_MOD dimension_expression											{ $$ = template("%s %% %s", $1, $3); }
                      | OP_PLUS dimension_expression %prec MINUS_PLUS_PRECEDENCE							{ $$ = template("%s", $2); }
                      | OP_MINUS dimension_expression	%prec MINUS_PLUS_PRECEDENCE							{ $$ = template("-%s", $2); }

assignment:   OP_ASSIGNMENT character_or_boolean        { $$ = template("=%s", $2); }
            | OP_ASSIGNMENT sign POSINT                 { $$ = template("=%s%d", $2, $3); }
            | OP_ASSIGNMENT sign REAL                   { $$ = template("=%s%lf", $2, $3); }

sign:   %empty          { $$ = template(""); }
      | OP_PLUS         { $$ = template("+"); }
      | OP_MINUS        { $$ = template("-"); }

character_or_boolean:   CONST_CHAR           { $$ = template("%s", $1); }
                      | CONST_STRING         { $$ = template("%s", $1); }
                      | KW_TRUE              { $$ = template("1"); }
                      | KW_FALSE             { $$ = template("0"); }

more_variables:   %empty                                                   { $$ = template(""); }
                | DEL_COMMA IDENT dimensions_or_assignment more_variables  { $$ = template(", %s%s%s", $2, $3, $4); }

/****************************************************************************************************************************************/


/**************************************************************  Functions **************************************************************/

function:   data_type IDENT DEL_LEFT_PARENTHESES parameters DEL_RIGHT_PARENTHESES KW_BEGIN functions_body KW_END           { $$ = template("%s %s (%s)\n{\n%s\n}", $1, $2, $4, $7); }
          | KW_VOID IDENT DEL_LEFT_PARENTHESES parameters DEL_RIGHT_PARENTHESES KW_BEGIN functions_body KW_END             { $$ = template("void %s (%s)\n{\n%s\n}", $2, $4, $7); }

parameters:   %empty                              { $$ = template(""); }
            | data_type IDENT more_parameters     { $$ = template("%s %s %s", $1, $2, $3); }

more_parameters:   %empty                                         { $$ = template(""); }
                 | DEL_COMMA data_type IDENT more_parameters      { $$ = template(",%s %s %s", $2, $3, $4); }

functions_body:   variables functions_body           { $$ = template("\t%s\n%s", $1, $2); }
                | statements                                  { $$ = template("\t%s\n", $1); }

more_functions:   %empty                                { $$ = template(""); }
                | function more_functions               { $$ = template("%s\n\n%s", $1, $2); }

/****************************************************************************************************************************************/


/**************************************************************  Expressions ************************************************************/

expression:   POSINT                                                                           { $$ = template("%d", $1); }
            | REAL                                                                             { $$ = template("%lf", $1); }
            | CONST_CHAR                                                                       { $$ = template("%s", $1); }
            | CONST_STRING                                                                     { $$ = template("%s", $1); }
            | IDENT                                                                            { $$ = template("%s", $1); }
            | KW_TRUE                                                                          { $$ = template("1"); }
            | KW_FALSE 																                                         { $$ = template("0"); }
            | expression OP_PLUS expression 										                               { $$ = template("%s + %s", $1, $3); }
			      | expression OP_MINUS expression 											                             { $$ = template("%s - %s", $1, $3); }
			      | expression OP_MULTIPLY expression  				   					                           { $$ = template("%s * %s", $1, $3); }
			      | expression OP_DIVIDE expression 											                           { $$ = template("%s / %s", $1, $3); }
            | expression KW_MOD expression 												                             { $$ = template("%s mod %s", $1, $3); }
            | expression OP_EQUAL expression                                                   { $$ = template("%s == %s", $1, $3); }
            | expression OP_NOT_EQUAL expression 		                                           { $$ = template("%s != %s", $1, $3); }
            | expression OP_GREATER expression 											                           { $$ = template("%s > %s", $1, $3); }
		    	  | expression OP_GREATER_OR_EQUAL expression 	                                     { $$ = template("%s >= %s", $1, $3); }
            | expression OP_LESS expression 							     			                           { $$ = template("%s < %s", $1, $3); }
			      | expression OP_LESS_OR_EQUAL expression  		  				                           { $$ = template("%s <= %s", $1, $3); }
			      | expression KW_AND expression 												                             { $$ = template("%s && %s", $1, $3); }
			      | expression OP_AND expression  									  		                           { $$ = template("%s && %s", $1, $3); }
			      | expression KW_OR expression  										  		                           { $$ = template("%s || %s", $1, $3); }
			      | expression OP_OR expression 											  	                           { $$ = template("%s || %s", $1, $3); }
            | DEL_LEFT_PARENTHESES expression DEL_RIGHT_PARENTHESES                            { $$ = template("(%s)", $2); }
            | KW_NOT expression 									   					    	                           { $$ = template("!%s", $2); }
	          | OP_NOT expression 											  			    	                           { $$ = template("!%s", $2); }
            | OP_PLUS expression %prec MINUS_PLUS_PRECEDENCE                                   { $$ = template("+%s", $2); }
            | OP_MINUS expression %prec MINUS_PLUS_PRECEDENCE                                  { $$ = template("-%s", $2); }
            | KW_READ_STRING DEL_LEFT_PARENTHESES DEL_RIGHT_PARENTHESES  	                     { $$ = template("gets()"); }
			      | KW_READ_INTEGER DEL_LEFT_PARENTHESES DEL_RIGHT_PARENTHESES                       { $$ = template("atoi(gets())"); }
			      | KW_READ_REAL  DEL_LEFT_PARENTHESES DEL_RIGHT_PARENTHESES 	                       { $$ = template("atof(gets())"); }
            | IDENT DEL_LEFT_PARENTHESES expressions DEL_RIGHT_PARENTHESES                     { $$ = template("%s(%s)", $1, $3);}
            | IDENT DEL_LEFT_BRACKET dimension_expression DEL_RIGHT_BRACKET dimensions 		     { $$ = template("%s[%s]%s", $1, $3, $5); }

expressions :   %empty                                 { $$ = template("");}
              |	expression 			                       { $$ = template("%s", $1);}
            	| expression DEL_COMMA expressions       { $$ = template("%s, %s", $1, $3);}

/****************************************************************************************************************************************/


/**************************************************************  Statements *************************************************************/

statements:   %empty                { $$ = template("");}
            | statement statements  { $$ = template("%s\n%s",$1,$2); }

statement:   DEL_SEMICOLON 																				                                                                                          { $$ = template(";"); }
           | KW_BEGIN statements KW_END 										         	   				   								                                                          { $$ = template("{\n\t%s\n}", $2);}
           | IDENT OP_ASSIGNMENT expression DEL_SEMICOLON                                                                                                   { $$ = template("%s=%s;", $1, $3); }
           | KW_IF DEL_LEFT_PARENTHESES expression DEL_RIGHT_PARENTHESES  statement %prec IF_PRECEDENCE                                                     { $$ = template("if(%s)\n\t%s", $3, $5); }
			     | KW_IF DEL_LEFT_PARENTHESES expression DEL_RIGHT_PARENTHESES statement KW_ELSE statement                                                        { $$ = template("if(%s)\n\t%s \n\telse\n\t\t%s", $3, $5, $7); }
           | KW_FOR DEL_LEFT_PARENTHESES for_assignment DEL_SEMICOLON for_assignment DEL_RIGHT_PARENTHESES statement				   			   			                { $$ = template("\tfor(%s;%s)\n\t%s", $3, $5, $7);}
			     | KW_FOR DEL_LEFT_PARENTHESES for_assignment DEL_SEMICOLON expression DEL_SEMICOLON for_assignment DEL_RIGHT_PARENTHESES statement				   		  { $$ = template("\tfor(%s;%s;%s)\n\t%s", $3, $5, $7, $9);}
           | KW_WHILE DEL_LEFT_PARENTHESES expression DEL_RIGHT_PARENTHESES statement 	                                                                    { $$ = template("while(%s)\n\t%s", $3, $5); }
				   | KW_DO statement KW_WHILE DEL_LEFT_PARENTHESES expression DEL_RIGHT_PARENTHESES DEL_SEMICOLON                                                   { $$ = template("do\n\t%s\nwhile(%s); ", $2, $5); }
           | KW_BREAK DEL_SEMICOLON 																	                                                                                      { $$ = template("break;"); }
			     | KW_CONTINUE DEL_SEMICOLON																	                                                                                    { $$ = template("continue;"); }
           | KW_RETURN expression DEL_SEMICOLON																							                                                                { $$ = template("return %s;", $2);}
           | KW_WRITE_STRING DEL_LEFT_PARENTHESES expression DEL_RIGHT_PARENTHESES DEL_SEMICOLON 				                                                    { $$ = template("puts(%s);", $3); }
			     | KW_WRITE_REAL DEL_LEFT_PARENTHESES expression DEL_RIGHT_PARENTHESES DEL_SEMICOLON				                                                      { $$ = template("printf(\"%%g\", %s);",$3); }
			     | KW_WRITE_INTEGER DEL_LEFT_PARENTHESES expression DEL_RIGHT_PARENTHESES	DEL_SEMICOLON			                                                      { $$ = template("printf(\"%%d\", %s);",$3); }
           | IDENT DEL_LEFT_PARENTHESES expressions DEL_RIGHT_PARENTHESES DEL_SEMICOLON 				  			                                                    { $$ = template("%s(%s);", $1, $3);}

for_assignment: IDENT OP_ASSIGNMENT expression { $$ = template("%s=%s", $1, $3); }

/****************************************************************************************************************************************/


%%

int main()
{
  return( yyparse() );
}
