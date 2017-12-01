count_and_remove_leading([], _, 0, []).
count_and_remove_leading([E|T], E, C, R) :- count_and_remove_leading(T, E, Cminus, R), C is Cminus + 1.
count_and_remove_leading([H|T], E, 0, [H|T]) :- H \= E. 

signal_morse([], []).
signal_morse([0], []).
signal_morse([0,0], []).
signal_morse([H1|T1], [H2|T2]) :- count_and_remove_leading([H1|T1], H1, C, R),
(
  (H1 = 0 -> 
    (
      (C =< 2, signal_morse(R, [H2|T2]));
      (C >= 2, C =< 5, (H2 = (^), signal_morse(R, T2)));
      (C >= 5, (H2 = #, signal_morse(R, T2)))
    )
  );
  (H1 = 1 ->
    (
      (C =< 2, (H2 = ., signal_morse(R, T2)));
      (C >= 2, (H2 = (-), signal_morse(R, T2)))
    )
  )
).

morse(a, [.,-]).           % A
morse(b, [-,.,.,.]).	   % B
morse(c, [-,.,-,.]).	   % C
morse(d, [-,.,.]).	   % D
morse(e, [.]).		   % E
morse('e''', [.,.,-,.,.]). % É (accented E)
morse(f, [.,.,-,.]).	   % F
morse(g, [-,-,.]).	   % G
morse(h, [.,.,.,.]).	   % H
morse(i, [.,.]).	   % I
morse(j, [.,-,-,-]).	   % J
morse(k, [-,.,-]).	   % K or invitation to transmit
morse(l, [.,-,.,.]).	   % L
morse(m, [-,-]).	   % M
morse(n, [-,.]).	   % N
morse(o, [-,-,-]).	   % O
morse(p, [.,-,-,.]).	   % P
morse(q, [-,-,.,-]).	   % Q
morse(r, [.,-,.]).	   % R
morse(s, [.,.,.]).	   % S
morse(t, [-]).	 	   % T
morse(u, [.,.,-]).	   % U
morse(v, [.,.,.,-]).	   % V
morse(w, [.,-,-]).	   % W
morse(x, [-,.,.,-]).	   % X or multiplication sign
morse(y, [-,.,-,-]).	   % Y
morse(z, [-,-,.,.]).	   % Z
morse(0, [-,-,-,-,-]).	   % 0
morse(1, [.,-,-,-,-]).	   % 1
morse(2, [.,.,-,-,-]).	   % 2
morse(3, [.,.,.,-,-]).	   % 3
morse(4, [.,.,.,.,-]).	   % 4
morse(5, [.,.,.,.,.]).	   % 5
morse(6, [-,.,.,.,.]).	   % 6
morse(7, [-,-,.,.,.]).	   % 7
morse(8, [-,-,-,.,.]).	   % 8
morse(9, [-,-,-,-,.]).	   % 9
morse(., [.,-,.,-,.,-]).   % . (period)
morse(',', [-,-,.,.,-,-]). % , (comma)
morse(:, [-,-,-,.,.,.]).   % : (colon or division sign)
morse(?, [.,.,-,-,.,.]).   % ? (question mark)
morse('''',[.,-,-,-,-,.]). % ' (apostrophe)
morse(-, [-,.,.,.,.,-]).   % - (hyphen or dash or subtraction sign)
morse(/, [-,.,.,-,.]).     % / (fraction bar or division sign)
morse('(', [-,.,-,-,.]).   % ( (left-hand bracket or parenthesis)
morse(')', [-,.,-,-,.,-]). % ) (right-hand bracket or parenthesis)
morse('"', [.,-,.,.,-,.]). % " (inverted commas or quotation marks)
morse(=, [-,.,.,.,-]).     % = (double hyphen)
morse(+, [.,-,.,-,.]).     % + (cross or addition sign)
morse(@, [.,-,-,.,-,.]).   % @ (commercial at)

% Error.
morse(error, [.,.,.,.,.,.,.,.]). % error - see below

% Prosigns.
morse(as, [.,-,.,.,.]).          % AS (wait A Second)
morse(ct, [-,.,-,.,-]).          % CT (starting signal, Copy This)
morse(sk, [.,.,.,-,.,-]).        % SK (end of work, Silent Key)
morse(sn, [.,.,.,-,.]).          % SN (understood, Sho' 'Nuff)

is_letter(a).
is_letter(b).
is_letter(c).
is_letter(d).
is_letter(e).
is_letter('e''').
is_letter(f).
is_letter(g).
is_letter(h).
is_letter(i).
is_letter(j).
is_letter(k).
is_letter(l).
is_letter(m).
is_letter(n).
is_letter(o).
is_letter(p).
is_letter(q).
is_letter(r).
is_letter(s).
is_letter(t).
is_letter(u).
is_letter(v).
is_letter(w).
is_letter(x).
is_letter(y).
is_letter(z).

% Can punctuation be part of words? I asked on Piazza three times and got no
% answer. If not, this section should be removed.
is_letter(.).
is_letter(',').
is_letter(:).
is_letter(?).
is_letter('''').
is_letter(-).
is_letter(/).
is_letter('(').
is_letter(')').
is_letter('"').
is_letter(=).
is_letter(+).
is_letter(@).

% Can prosigns be part of words? I asked on Piazza three times and got no
% answer. If not, this section should be removed.
is_letter(as).
is_letter(ct).
is_letter(sk).
is_letter(sn).

take_seq([], [], []).
take_seq([^|T], [], T).
take_seq([#|T], [], [#|T]).
take_seq([H|T], [H|ST], Rest) :- H \= (^), H \= #, take_seq(T, ST, Rest).

take_letter([], _, []) :- fail.
take_letter([H|T], L, Rest) :- (H = #, L = #, Rest = T);
(H \= #, take_seq([H|T], S, Rest), morse(L, S)).

letter_list([], []).
letter_list(Sym, [L|R]) :- take_letter(Sym, L, Rest), letter_list(Rest, R).

% Processes the reversed letter list, trying to drop words after errors
% if possible.
drop_errors([], []).
drop_errors([X|T1], [X|T2]) :- X \= error, drop_errors(T1, T2).
drop_errors([error|T1], L) :- (drop_spaces(T1, [Letter|T2]), is_letter(Letter) ->
drop_word([Letter|T2], L)); (drop_errors(T1, LT), L = [error|LT]).

% Drops leading spaces before starting to find a word.
% Since the list is reversed, these spaces are actually after a word.
drop_spaces([X|T1], [X|T1]) :- X \= '#'.
drop_spaces([#|T1], T2) :- drop_spaces(T1, T2).

% We will check to make sure at least one letter is present to form the dropped
% word in drop_errors.
% Note that there is no base case handling an empty list because in that case
% there is no word to drop, so it should fail.
% This is not an issue because in drop_errors, drop_spaces will only succeed if
% it produces a list with at least one element.
drop_word([H|T], L) :- (is_letter(H) -> drop_word(T, L)); L = [H|T].

signal_message([], []).
signal_message(Sig, Mess) :- signal_morse(Sig, Sym), letter_list(Sym, Lets),
reverse(Lets, Rlets), drop_errors(Rlets, Rfix), reverse(Rfix, Mess).
