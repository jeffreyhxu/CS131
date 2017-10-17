type ('nonterminal, 'terminal) symbol =
  | N of 'nonterminal
  | T of 'terminal

let convert_grammar gram =
  let rec prod_fun rule_list n =
    match rule_list with
    | [] -> []
    | rule :: rest ->
        if (fst rule) = n
          then (snd rule) :: prod_fun rest n
          else prod_fun rest n
  in (fst gram, prod_fun (snd gram))

let rec parse_prefix gram acceptor fragment =
  let rec parse_nt nt try_i acnt dent frant =
    if try_i >= List.length ((snd gram) nt)
      then None
      else let rec try_rule rule ri acru deru fraru =
        if ri >= List.length (snd rule)
          then acru deru fraru
          else match List.nth (snd rule) ri with
          | N nonterm ->
            if ri = 0
              then parse_nt nonterm 0 (try_rule rule (ri + 1) acru) (deru @ [rule]) fraru
              else parse_nt nonterm 0 (try_rule rule (ri + 1) acru) deru fraru
          | T term ->
            match fraru with
            | hd :: tl -> 
              if hd = term
                then if ri = 0
                  then try_rule rule (ri + 1) acru (deru @ [rule]) tl
                  else try_rule rule (ri + 1) acru deru tl
                else None
            | _ -> None in
      let result = try_rule (nt, List.nth ((snd gram) nt) try_i) 0 acnt dent frant in
      match result with
      | None -> parse_nt nt (try_i + 1) acnt dent frant
      | _ -> result in
  parse_nt (fst gram) 0 acceptor [] fragment
