# FC-compiler
The FC-compiler project is a semester project for the course "Theory of Computation" in Technical University of Crete. The main purpose of this project is to create a compiler for the fictional programming language FC (Fictional C) using the open source tools lex (FLEX) and yacc (BISON). The goal here is to give the (FC-)compiler a program written in FC and give us back the corresponding (compiled-translated) program in C programming language.

To run the program just go into the src directory and run the FC_script. 

"./FC_script"

This will run the makeFile and it will generate all the necessary files. Afterwards it will try to compile all the \*.fc files inside the Samples folder (both Good and Bad examples). For every single one of them it will generate a simple message to let you know if the compilation process was successful or not (with green or red font respectively).
