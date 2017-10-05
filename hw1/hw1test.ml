let my_subset_test0 = subset [3; 2; 4; 3; 3] [5; 4; 3; 2; 1];;
let my_subset_test1 = subset [] [5; 4; 3; 2; 1];;
let my_subset_test2 = not (subset [5; 4; 3; 6] [5; 4; 3; 2; 1]);;

let my_equal_sets_test0 = equal_sets [1; 5; 3; 5; 2; 5; 3; 4] [5; 4; 3; 2; 1];;
let my_equal_sets_test1 = not (equal_sets [5; 4; 3; 6] [5; 4; 3; 2; 1]);;

let my_set_union_test0 = equal_sets (set_union [1; 2] [2; 3]) [1; 2; 3];;
let my_set_union_test1 = equal_sets (set_union [1; 2; 3] []) [1; 2; 3];;

let my_set_intersection_test0 = equal_sets (set_intersection [1; 3; 5] [2; 3; 4; 5]) [3; 5];;
let my_set_intersection_test1 = equal_sets (set_intersection [] [1; 2; 3; 4; 5]) [];;

let my_set_diff_test0 = equal_sets (set_diff [1; 3; 5; 7] [2; 3; 4; 5]) [1; 7];;
let my_set_diff_test1 = equal_sets (set_diff [] []) [];;

let my_computed_fixed_point_test0 = (computed_fixed_point (=) (fun x -> x * (5 - x)) 1) = 4;;

let my_computed_periodic_point_test0 = (computed_periodic_point (=) (fun x -> (-. (abs_float x)) *. (sqrt (abs_float x)) /. x) 2 4.) = -1.;;

let my_while_away_test0 = (while_away succ ((>) 5) 0) = [0; 1; 2; 3; 4];;
let my_while_away_test1 = (while_away succ ((=) 1) 0) = [];;

let my_rle_decode_test0 = (rle_decode [1, "a"; 2, "b"; 0, "nope"; 5, "5x"]) = ["a"; "b"; "b"; "5x"; "5x"; "5x"; "5x"; "5x"];;

type test_grammar_N =
  | Start | A | B | UnreachableGood | UnreachableBad | Deadend

let my_filter_blind_alleys_test0 = (filter_blind_alleys (Start,
 [Start, [N A];
  Start, [N Deadend; T "trap!"];
  Start, [N A; N Deadend];
  A,     [N B; N A];
  A,     [N A];
  A,     [T "only way out"];
  B,     [N B; N B; N B];
  B,     [N A];
  B,     [N A; N B; N Deadend];
  B,     [N Deadend];
  UnreachableGood, [N A; T "secret exit"];
  UnreachableGood, [N Deadend];
  UnreachableBad,  [N UnreachableBad; N Deadend];
  Deadend,         [N Deadend]]))
  =
 (Start,
 [Start, [N A];
  A,     [N B; N A];
  A,     [N A];
  A,     [T "only way out"];
  B,     [N B; N B; N B];
  B,     [N A];
  UnreachableGood, [N A; T "secret exit"]]);;
