%{
  open Ast

  let curry params body =
    List.fold_right (fun x body -> Abstraction { param = x; body }) params body
  ;;
%}

%token<string> VAR
%token<string> TERM
%token<string> STRING
%token LAMBDA DOT LP RP EOF
%token ATRIB SEMICOLON INCLUDE

%nonassoc LAMBDA
%right SEMICOLON
%right DOT
%left LP VAR TERM
%left APP

%start<stmt> parse

%%

parse:
  EOF { Unit }
| s = stmt EOF { s }

stmt:
  e = expr { Term e }
| t = TERM ATRIB e = expr { Atribution { ident = t; value = e } }
| s = stmt SEMICOLON { s }
| s1 = stmt SEMICOLON s2 = stmt { Sequence { s1 = s1; s2 = s2 } }
| INCLUDE s = STRING { Include s }

expr:
  LP e = expr RP { e }
| v = VAR { Variable v }
| t = TERM { Identifier t }
| t = expr a = expr %prec APP { Application { term = t; argum = a } }
| LAMBDA v = nonempty_list(VAR) DOT e = expr { curry v e }

%%
