type 'a tree = 
    | Nil
    | Node of 'a list *('a tree)*('a tree) 


(*let add_succ_at_a_node : 'a -> 'a -> 'a tree -> 'a tree = fun a no tr ->
    match tr with 
        | Nil -> failwith "Not a node of the tree. There must be a mistake somewhere."
        | Node(no,ch) -> Node(no,Node[a::ch)
        | Node(r,ch) -> *)