open Ast

module type CHOICE = sig
  val choice : Ast.Cnf.t -> Ast.var
end

module DefaultChoice =
struct
  let choice : Ast.Cnf.t -> Ast.var = fun cnf -> failwith "todo: choice"
end

module type SOLVER = sig
  val solve : Ast.t -> Ast.model option
  val solve_xnf : Ast.t -> Ast.model option
  val solve_hs : Ast.t -> Ast.model option
end

module DPLL(C:CHOICE) : SOLVER =
struct
let rec solve : Ast.t -> Ast.model option = fun p -> 
    (* print_string "new_cnf \n"; 
    Ast.pp Format.std_formatter p; *)
    if Memois.mem p.cnf !memoisation then None
    else 
    if Cnf.is_empty p.cnf then Some []
    else 
    ( let l_sgl = ref [] and cnf = ref p.cnf
      in

      (* Balaie la CNF pour enlever tous les singletons *)
      while Cnf.exists (fun x -> (Clause.cardinal x) = 1) !cnf do
      let l = List.map (fun elt -> Clause.choose elt) (Cnf.elements (Cnf.filter (fun elt -> (Clause.cardinal elt) = 1) !cnf)) in 
      l_sgl := l@(!l_sgl); cnf := remove_lvar_clause l !cnf
      done;

      let cnf3 = Cnf.filter (fun elt -> not(Clause.is_empty elt)) !cnf in

      (* Vérifie si lors de l'assignation des singletons, il n'y a pas eu de conflits, à savoir assignation impossible.
      Si c'est le cas, alors on en profite pour stocker cette CNF comme insatisfiable. *)
      if Cnf.cardinal !cnf <> Cnf.cardinal cnf3 then (memoisation := Memois.add p.cnf !memoisation; None)

      else 
      match Cnf.choose_opt cnf3 with
        | None -> Some !l_sgl (* La CNF est vide, donc satisfiable *)
        | Some elt -> (* On choisit une variable dans cette clause, on sait qu'elle existe car on a enlevé toutes les clauses vides *)
                      let new_var = Clause.choose elt in 
                      begin
                        let cnf4 = remove_var_clause cnf3 new_var in (* Nettoyage de la CNF avec cette assignation *)
                        let new_cnf = {nb_var = (p.nb_var - (List.length !l_sgl)) - 1; nb_clause = Cnf.cardinal cnf4; cnf = cnf4; typ = p.typ} in
                        match solve new_cnf with
                          | None -> (* Non satisfiable, on évalue donc la variable à l'opposé *)
                          ( memoisation := Memois.add cnf4 !memoisation;
                            let second_var = -new_var in 
                            let cnf6 = remove_var_clause cnf3 second_var in
                            let second_cnf = solve {nb_var = new_cnf.nb_var; nb_clause = Cnf.cardinal cnf6; cnf = cnf6; typ = p.typ} in
                            match second_cnf with
                              | None -> memoisation := Memois.add p.cnf !memoisation; None (* Avec cette valuation, ce n'est pas non plus satisfiable *)
                              | Some l -> Some (second_var::((!l_sgl)@l)) (* Satisfiable, on retourne *)
                          )
                          | Some l -> Some (new_var::(!l_sgl@l)) (* Satisfiable, on retourne simplement *)
                      end
    )



  and remove_var_clause c v = 
      let c1 = Cnf.map (Clause.remove (-v)) c in
      Cnf.filter (fun elt -> not(Clause.mem v elt)) c1
  
  and remove_lvar_clause l c = match l with
      | [] -> c
      | h::q -> let c1 = (Cnf.map (Clause.remove (-h)) c) in
                remove_lvar_clause q (Cnf.filter (fun elt -> not(Clause.mem h elt)) c1)
  
  (* Fonctions pour trouver les variables valuées de la même manière dans toutes les clauses 
  and recup_var c = 
      Cnf.fold (fun x i -> Clause.union x i) c Clause.empty
  
  and recup_unit_var c1 c2 =
      Clause.elements (Clause.filter (fun elt -> Cnf.for_all (fun x -> Clause.mem elt x || not(Clause.mem (-elt) x)) c2) c1)
  *)

  and memoisation = ref Memois.empty  (* Ma table de mémoïsation *)




  (********************** Projet LOGIA 1  **********************)


  (* XNF *)

  and solve_xnf : Ast.t -> Ast.model option = fun p -> 
  
    if Cnf.is_empty p.cnf then Some []
    else 
    ( let l_sgl = ref [] and xnf = ref p.cnf
      in

      (* Balaie la CNF pour enlever tous les singletons *)
      while Cnf.exists (fun x -> (Clause.cardinal x) = 1) !xnf do
      let l = List.map (fun elt -> Clause.choose elt) (Cnf.elements (Cnf.filter (fun elt -> (Clause.cardinal elt) = 1) !xnf)) in 
      l_sgl := l@(!l_sgl); xnf := remove_lvar_clause_xnf l !xnf; xnf := Cnf.map (clean_assigned_lvar_xnf l) !xnf
      done;
      (* Avec remove_lvar_clause_xnf on supprime les occurences des variables à 0 *)

      (* On regarde s'il y a un conflit *)
      if conflit !l_sgl then None
      else

      (* On veut nettoyer les variables déjà assignées en utilisant la régle A xor 1 = neg A et neg (A xor B) = neg A xor B *)

      let cleaned_xnf = Cnf.filter (fun elt -> not(Clause.is_empty elt)) (Cnf.map (remove_assigned_lvar_xnf !l_sgl) !xnf) in

      match Cnf.choose_opt cleaned_xnf with
        | None -> Some !l_sgl (* La CNF est vide, donc satisfiable *)
        | Some elt -> (* On choisit une variable dans cette clause, on sait qu'elle existe car on a enlevé toutes les clauses vides *)
                      let new_var = Clause.choose elt in 
                      begin
                        let xnf2 = Cnf.map (Clause.remove (-new_var)) cleaned_xnf in
                        let xnf3 = Cnf.map (remove_assigned_var_xnf new_var) xnf2 in
                        let xnf4 = Cnf.filter (fun elt -> not(Clause.is_empty elt)) xnf3 in
                        (* Nettoyage de la CNF avec cette assignation *)
                        let new_xnf = {nb_var = (p.nb_var - (List.length !l_sgl)) - 1; nb_clause = Cnf.cardinal xnf3; cnf = xnf4; typ = p.typ} in
                        match solve_xnf new_xnf with
                          | None -> (* Non satisfiable, on évalue donc la variable à l'opposé *)
                          ( memoisation := Memois.add xnf4 !memoisation;
                            let second_var = -new_var in 
                            let xnf5 = Cnf.map (Clause.remove (-second_var)) cleaned_xnf in
                            let xnf6 = Cnf.map (remove_assigned_var_xnf second_var) xnf5 in
                            let xnf7 = Cnf.filter (fun elt -> not(Clause.is_empty elt)) xnf6 in
                            let second_cnf = {nb_var = new_xnf.nb_var; nb_clause = Cnf.cardinal xnf7; cnf = xnf7; typ = p.typ} in
                            match solve_xnf second_cnf with
                              | None -> None (* Avec cette valuation, ce n'est pas non plus satisfiable *)
                              | Some l -> Some (second_var::((!l_sgl)@l)) (* Satisfiable, on retourne *)
                          )
                          | Some l -> Some (new_var::(!l_sgl@l)) (* Satisfiable, on retourne simplement *)
                      end
    ) 

  and conflit = function
  | [] -> false
  | h::q when List.mem (-h) q -> true
  | _::q -> conflit q

  and remove_lvar_clause_xnf lvar formula = match lvar with
    | [] -> formula
    | h::q -> remove_lvar_clause_xnf q (Cnf.map (Clause.remove (-h)) formula)
  
  and clean_assigned_lvar_xnf lvar cl = 
    if Clause.cardinal cl <> 1 then cl
    else 
      match lvar with
      | [] -> cl
      | h::q when Clause.mem h cl -> Clause.empty
      | _::q -> clean_assigned_lvar_xnf q cl

  and remove_assigned_var_xnf var cl = 
    if Clause.cardinal cl = 1 && Clause.mem var cl then Clause.empty
    else 
      if Clause.cardinal cl > 1 && Clause.mem var cl then 
        let new_cl = Clause.remove var cl in
          let elt = Clause.choose new_cl in
            let new_new_cl = Clause.remove elt new_cl in
              Clause.add (-elt) new_new_cl
      else
        cl
  
  and remove_assigned_lvar_xnf lvar cl = match lvar with
    | [] -> cl
    | h::q -> remove_assigned_lvar_xnf q (remove_assigned_var_xnf h cl)

  and pretty_print = function
    | [] -> print_string "\n"
    | h::q -> print_int h; pretty_print q

  

  (* HornSAT *)

  and solve_hs : Ast.t -> Ast.model option = fun p ->
    if Cnf.is_empty p.cnf then Some []
    else 
      let var_val = Array.make (p.nb_var+1) (-1) and l = ref [] and horn = ref p.cnf and sat = ref true in
        while !sat && Cnf.exists (fun elt -> Clause.cardinal elt = 1) !horn do
          let l_sgl = ref [] in
          Cnf.iter (fun elt -> if Clause.cardinal elt = 1 then
                                  let var = Clause.choose elt in 
                                    if var < 0 then 
                                      begin
                                        if var_val.(-var) = -1  then (var_val.(-var) <- 0; l_sgl := var::(!l_sgl))
                                        else if var_val.(-var) = 1 then sat := false
                                      end
                                    else 
                                      begin
                                        if var_val.(var) = -1  then (var_val.(var) <- 1; l_sgl := var::(!l_sgl))
                                        else if var_val.(var) = 0 then sat := false
                                      end
                                      ) !horn;
          horn := remove_lvar_clause !l_sgl !horn;
          l := !l_sgl@(!l);
          if Cnf.exists (Clause.is_empty) !horn then sat := false
        done;
        if not(!sat) then None
        else 
          begin
            for i=1 to p.nb_var do
              if var_val.(i) = -1 then l := (-i)::(!l)
            done;
            Some !l
          end

  
end
