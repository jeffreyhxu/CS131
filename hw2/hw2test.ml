let accept_empty deriv = function
  | [] -> Some (deriv, [])
  | _ -> None

type my_nonterms =
  | Start | A | B | C

let my_grammar =
 (Start,
  function
    | Start ->
        [[N B; N C];
         [N B; N C; T "end"]; (* tests disjunction with first rule *)
         [N A; N B; N C];     (* tests concatenation *)
         [T "sa"; N A];
         []]
    | A ->
        [[T "a"; N B];
	 [T "a"; N C]; (* which rule to use if it starts with "a"? *)
	 [N C]]
    | B ->
        [[N A];
         [T "b"];
         [T "b"; T "c"]] (* should a "c" be part of B or C? *)
    | C ->
        [[T "c"]]
 )

let test_0 =
  ((parse_prefix my_grammar accept_empty ["b"; "c"; "end"])
   = Some ([(Start, [N B; N C; T "end"]); (B, [T "b"]); (C, [T "c"])], []))

let test_1 =
  ((parse_prefix my_grammar accept_empty ["a"; "a"; "c"; "b"; "c"; "c"])
   = Some ([(Start, [N A; N B; N C]); (A, [T "a"; N B]); (B, [N A]); (A, [T "a"; N B]); (B, [N A]); (A, [N C]); (C, [T "c"]); (B, [T "b"; T "c"]); (C, [T "c"])], []))
(* Note that this isn't the shortest derivation: it goes A->aB->aA->aC->ac
   instead of A->aC->ac. *)
