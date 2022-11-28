
(* The type of tokens. *)

type token = 
  | ZERO
  | XNF
  | P
  | NEWLINE
  | INT of (int)
  | HS
  | EOF
  | CNF
