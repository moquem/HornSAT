type execution_mode =
  | Cnf (** Solve a formula *)


(** By default we solve a formula given in the dimacs format *)
let mode = ref Cnf

(** Default solver. By doing the third part of the project, you might come with other solvers *)
module S = Dpll.DPLL(Dpll.DefaultChoice)

let pretty_print = function
  | [] -> print_string "\n"
  | h::q -> print_int h

(** Handle files given on the command line *)
let handle_file : string -> unit = fun fname ->
  let p =  Dimacs.parse_file fname in
  begin 
    match p.typ with
      | 0 -> print_string "bouh";
        begin
          match S.solve p with
          | None -> Format.printf "false@."
          | Some _ -> Format.printf "true@."
        end
      | 1 -> print_string "yo";
        begin
          match S.solve_xnf p with
          | None -> Format.printf "false@."
          | Some _ -> Format.printf "true@."
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
