type var = int

type lit = int

type model = int list

type 'a tree = 
    | Nil
    | Node of 'a list* 'a * ('a tree) * 'a * ('a tree) 

module Clause = Set.Make(struct type t = lit let compare = compare end)

module Cnf = Set.Make(struct type t = Clause.t let compare = Clause.compare end)

module Memois = Set.Make(struct type t = Cnf.t let compare = Cnf.compare end)

type t =
  {
    nb_var : int;
    nb_clause : int;
    cnf : Cnf.t;
    typ : int
  }

let neg var = -var

type 'a printer = Format.formatter -> 'a -> unit

let pp_clause : Clause.t printer = fun fmt clause ->
  Clause.iter (fun v -> Format.fprintf fmt "%d " v) clause

let pp_cnf : Cnf.t printer = fun fmt cnf ->
  Cnf.iter (fun clause -> Format.fprintf fmt "%a0@." pp_clause clause) cnf

let pp : t printer = fun fmt t ->
  Format.fprintf fmt "p %d %d@." t.nb_var t.nb_clause;
  Format.fprintf fmt "%a@." pp_cnf t.cnf
