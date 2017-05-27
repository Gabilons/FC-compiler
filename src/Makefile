# Written by Kampylafkas Anastasios on May 8 2017

#------------- Compilers and Flags -------------
ifndef DEBUG
# Default: compile for debug
DEBUG=1
endif

# Default C compiler
CC=gcc

# Flags
BASICFLAGS= -std=c11

# Debug Flags
DEBUGFLAGS= -g
# Optimize Flags
OPTFLAGS= -march=native -O3

INCLUDE_PATH=-I${SRC_DIR}

CFLAGS= -Wall -D_GNU_SOURCE $(BASICFLAGS) $(INCLUDE_PATH)

ifeq ($(DEBUG),1)
CFLAGS+=  $(DEBUGFLAGS)
else
CFLAGS+=  $(OPTFLAGS)
endif

#Flex
FLEX=flex
F_LIBS=-lfl

#Bison
BISON=bison
B_LIBS=-d -v -r all --report=solved
#-----------------------------------------------

# Working directory
SRC_DIR=.

#-------------------- Files --------------------
SOURCES= cgen.c
# File Dependancies
FC_compilerDep= FC_lexer.c cgen.c FC_parser.tab.c

FC_lexerDep= FC_lexer.l cgen.h FC_parser.tab.h

FC_parserDep= FC_parser.y cgen.h

# Generated files
FLEX_GEN= FC_lexer.c

BISON_GEN= FC_parser.tab.h FC_parser.tab.c FC_parser.output

COMP_GEN= FC_compiler

GEN= ${FLEX_GEN} ${BISON_GEN} ${COMP_GEN}
#-----------------------------------------------

# Rules

.PHONY:	all	clean

all: FC_compiler

FC_compiler: ${FC_compilerDep}
	${CC} $(CFLAGS) -o $@ $^ ${F_LIBS}

FC_lexer.c: ${FC_lexerDep}
	$(FLEX) -o $@ $<

FC_parser.tab.c FC_parser.tab.h: ${FC_parserDep}
		$(BISON) ${B_LIBS} $<

depend: $(SOURCES)
	$(CC) $(CFLAGS) -MM $^ > .depend

include .depend

# Cleaning Project files
clean: realClean cleanDepend

cleanDepend:
	@echo "Cleaning .depend file"
	@rm .depend
	@echo Done
	@echo

realClean:
	@echo
	@echo "Cleaning object files"
	@rm  ${SRC_DIR}/${GEN}
	@echo Done
	@echo
