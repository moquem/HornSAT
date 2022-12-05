open Dpll
open Ast

type execution_mode =
  | Cnf (** Solve a formula *)


(** By default we solve a formula given in the dimacs format *)
let mode = ref Cnf

(** Default solver. By doing the third part of the project, you might come with other solvers *)
module S = Dpll.DPLL(Dpll.DefaultChoice)

let rec pretty_print = function
  | [] -> print_string "\n"
  | h::q -> print_int h; print_string " "; pretty_print q

let rec pretty_print_tree deep = function
  | Nil -> print_string "_"
  | Node(l,0,Nil,0,Nil) -> print_string "conflit lors de l'assignation des singletons: "; pretty_print l
  | Node(l,v1,t1,v2,t2) -> print_string("-> assignation unit clauses: ");  
                          pretty_print l; 
                          for i=0 to deep*3 do print_string "-" done; 
                          print_string "deep:"; print_int deep; print_string " first choice: "; print_int v1; print_string " "; pretty_print_tree (deep+1) t1; 
                          for i=0 to deep*3 do print_string "-" done; 
                          print_string "deep:"; print_int deep; print_string " second choice: "; print_int v2; print_string " "; pretty_print_tree (deep+1) t2

(** Handle files given on the command line *)
let handle_file : string -> unit = fun fname ->
  let p =  Dimacs.parse_file fname in
  begin 
    match p.typ with
      | 0 -> 
        begin
          match S.solve p with
          | None -> Format.printf "false@."
          | Some lvar -> 
            let l = ref lvar in
              for i=1 to p.nb_var do
                if not(List.mem i lvar) && not(List.mem (-i) lvar) then l := i::!l
              done;
          pretty_print !l; Format.printf "true@."
        end
      | 1 -> 
        begin
          match S.solve_xnf p with
          | None, t -> pretty_print_tree 0 t; print_string "\n"; Format.printf "false@."
          | Some lvar, _ -> pretty_print lvar; Format.printf "true@."
        end
      | 2 -> 
        begin
          match S.solve_hs p with
          | None, Some v -> print_string "Conflit lors de l'assignation de: "; print_int v; print_string "\n"; Format.printf " false@."
          | Some lvar, None -> pretty_print lvar; Format.printf "true@."
          | _ -> ()
        end
      | _ -> ()
  end

(** Specification of the options handle by the program. You are only allowed to ADD new options *)
let spec =
  let debug_flags =
    let fn acc l = acc ^ "\n        " ^ l in
    List.fold_left fn "\n      Available flags:" (Console.log_summary ())
  in
  let spec = Arg.align
      [ ( "--debug"
        , Arg.String (Console.set_debug true)
        , "<flags> Sets the given debugging flags" ^ debug_flags )
      ]
  in
  spec

(** Entry point of the program *)
let _ =
  let open Console in
  let usage = Format.sprintf "Usage: %s [CMD] [FILE]" Sys.argv.(0) in
  let files = ref [] in
  Arg.parse spec (fun s -> files := s :: !files) usage;
  try
    begin
      match !mode with
      | Cnf -> List.iter handle_file !files
    end
  with
  | Fatal(None,    msg) -> exit_with "%s" msg
  | Fatal(Some(p), msg) -> exit_with "[%a] %s" Location.print p msg
