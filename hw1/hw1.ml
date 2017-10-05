type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal;;

let rec subset a b =
  match a with
  | [] -> true
  | firsta :: resta ->
      (List.mem firsta b) && (subset resta b)

let equal_sets a b =
  (subset a b) && (subset b a);;

let rec set_union a b =
  match a with
  | [] -> b
  | firsta :: resta ->
      if List.mem firsta b
        then set_union resta b
        else firsta :: (set_union resta b);;

let rec set_intersection a b =
  match a with
  | [] -> []
  | firsta :: resta ->
      if List.mem firsta b
        then firsta :: (set_intersection resta b)
        else set_intersection resta b;;

let rec set_diff a b =
  match a with
  | [] -> []
  | firsta :: resta ->
      if List.mem firsta b
        then set_diff resta b
        else firsta :: (set_diff resta b);;

let rec computed_fixed_point eq f x =
  if eq (f x) x
    then x
    else computed_fixed_point eq f (f x);;

let rec repeat_f f p x =
  if p = 0
    then x
    else f (repeat_f f (p - 1) x);;

let rec computed_periodic_point eq f p x =
  if eq (repeat_f f p x) x
    then x
    else computed_periodic_point eq f p (f x);;

let rec while_away s p x =
  if p x
    then x :: (while_away s p (s x))
    else [];;

let rec rle_decode lp =
  match lp with
  | [] -> []
  | head :: tail ->
      if (fst head) = 0
        then rle_decode tail
        else (snd head) :: (rle_decode ((((fst head) - 1), (snd head)) :: tail));;

let rec find_terminals syms =
  match syms with
  | [] -> []
  | T term :: rest -> T term :: (find_terminals rest)
  | N nonterm :: rest -> find_terminals rest;;

let rec scan_rules rules i goods last_good good_rule_nums =
  if i = last_good
    then goods
    else
    let right = snd (List.nth rules i)
    and next = (succ i) mod (List.length rules) in
    let newgoods = set_union (find_terminals right) goods in
    if (not (List.mem i good_rule_nums)) && (subset right newgoods)
      then scan_rules rules next ((N (fst (List.nth rules i))) :: newgoods) i (i :: good_rule_nums)
      else scan_rules rules next newgoods last_good good_rule_nums;;

let rec filter_by_sym rules allowed =
  match rules with
  | [] -> []
  | head :: tail ->
      if (List.mem (N (fst head)) allowed) && (subset (snd head) allowed)
        then head :: (filter_by_sym tail allowed)
        else filter_by_sym tail allowed;;

let rec filter_blind_alleys g =
  let rules = (snd g) in
  let good_syms = scan_rules rules 0 [] ((List.length rules) - 1) [] in
  ((fst g), (filter_by_sym rules good_syms))
