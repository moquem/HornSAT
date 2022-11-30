%{
    let mk_clause : int list -> Ast.Clause.t = fun ls -> Ast.Clause.of_list ls

    let mk_cnf : int * int -> Ast.Clause.t list -> Ast.t = fun (nb_var,nb_clause) cls ->
      let open Ast in
      {nb_var; nb_clause; cnf = Cnf.of_list cls; typ = 0}
    
    let mk_xnf : int * int -> Ast.Clause.t list -> Ast.t = fun (nb_var,nb_clause) cls ->
      let open Ast in
      {nb_var; nb_clause; cnf = Cnf.of_list cls; typ = 1}
    
    let mk_hs : int * int -> Ast.Clause.t list -> Ast.t = fun (nb_var,nb_clause) cls ->
      let open Ast in
      {nb_var; nb_clause; cnf = Cnf.of_list cls; typ = 2}
%}

%token EOF
%token ZERO
%token P CNF XNF HS
%token NEWLINE
%token <int> INT


/* Starting symbols */

%start <Ast.t> file

%%

file:
  | NEWLINE* h=start_cnf l=cnf
    { mk_cnf h l }
  | NEWLINE* h=start_xnf l=cnf
    { mk_xnf h l }
  | NEWLINE* h=start_hs l=cnf
    { mk_hs h l } 

start_cnf:
  | P CNF nbvar=INT nbclause=INT NEWLINE
    { (nbvar, nbclause) }

start_xnf:
  | P XNF nbvar=INT nbclause= INT NEWLINE
    { (nbvar, nbclause) }

start_hs:
  | P HS nbvar=INT nbclause= INT NEWLINE
    { (nbvar, nbclause) }

cnf:
  | EOF
    { [] }
  | NEWLINE l=cnf
    { l }
  | c=clause l=cnf
    { c :: l }

clause:
  | c=nonempty_list(atom) ZERO NEWLINE
    { mk_clause c }

atom:
  | i=INT
    { i }
