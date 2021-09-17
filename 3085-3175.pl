/* Ηλίας Παπαδημητρίου ΑΕΜ:3085
Καρυοφυλλιά Πριάκου ΑΕΜ:3175
*/



/* allsubjwithoutdupl: επιστρέφει λίστα με όλα τα μαθήματα που παρακολουθούνται απο φοιτητές,ταξινομημένη και χωρίς αντίγραφα */

allsubjects(L) :- findall(X, attends(_,X), L).
allsubjwithoutdupl(Z) :- allsubjects(X), sort(X,Z).

/* allstudentssorted: επιστρέφει με όλους τους  φοιτητές που παρακολουθούν μαθήματα, ταξινομημένη καιχωρίς αντίγραφα */

allstudents(L) :- findall(X, attends(X,_), L).
allstudentssorted(Z) :- allstudents(X), sort(X,Z).

/* επιστρέφει μια λίστα με όλες τις πιθανές μεταθέσεις των μαθημάτων */

permutatedlist(L):-  allsubjwithoutdupl(X),permutation(X,L).
/*
 listdivider: χωρίζει την λίστα σε τρία κομμάτια, ένα για κάθε βδομάδα */
listdivider([X,Y], [X], [Y], []).
listdivider([X,Y,Z|Tail],[X|Xtail],[Y|Ytail],[Z|Ztail]) :-
listdivider(Tail,Xtail,Ytail,Ztail).


schedule(A, B, C) :-   permutatedlist(L),  listdivider(L, A, B, C).

/* επιστρεφει true αν ένας φοιτητής παρακολουθεί όλες τις διαλέξεις απο μια λίστα */

attendsall(_F,[]).
attendsall(F,[D|T]) :- attends(F,D), attendsall(F,T).

/* επιστρέφει πόσοι φοιτητές απο μια λίστα φοιτητών παρακολουθούν όλες τις διαλέξεις απο μια λίστα μαθημάτων */

attendall([],_Lect,E,E).
attendall([F|T],Lect,Temp,E):- attendsall(F,Lect),
E1 is Temp+1,
attendall(T,Lect,E1,E).
attendall([F|T],Lect,Temp,E):- not(attendsall(F,Lect)),
attendall(T,Lect,Temp,E).


/*επιστρέφει τον αριθμό των φοιτητών που είναι δυσαρεστημένοι με ένα συγκεκριμένο πρόγραμμα*/
schedule_errors(A,B,C,E):-
    schedule(A,B,C),
    allstudentssorted(Z),
    attendall(Z, A, 0, X),
     attendall(Z, B, 0, Y),
    E is X+Y.

/* βρίσκει τον ελάχιστο αριθμό δυσαρεστημένων φοιτητών που αντιστοιχεί σε κάποιο ππρόγραμμα (E) και το πρόγραμμα που αντιστοιχεί σε αυτόν τον αριθμό (A,B,C,E) */

minimal_schedule_errors(A,B,C,E) :-
    findall(X,schedule_errors(_,_,_,X),L),
    min_list(L,E),
    schedule_errors(A,B,C,E).

/*επιστρέφει το πρώτο στοιχείο μιας λίστας, θα μας χρειαστεί μετά */
first_element([H|_],H).
/* επιστρέφει το δεύτερο στοιχείο μιας λίστας, θα μας χρειαστεί μετά */
second_element([_H|T],S):- first_element(T,S).


/*επιστρέφει τον αριθμό των διαλέξεων που παρακολουθεί ένας φοιτητής απο μια λίστα μαθημάτων*/
onestudentoneweek(_S,[],R,R).
onestudentoneweek(S,[W|T],Temp,R):- attends(S,W),
	Temp1 is Temp+1,
	onestudentoneweek(S,T,Temp1,R).
onestudentoneweek(S,[W|T],Temp,R):-
	not(attends(S,W)),
	onestudentoneweek(S,T,Temp,R).

/* βοηθητική συνάρτηση για την studentweekscore */
my_score(_S,_Sec,R,Score):- R=:=3,Score is -7.
my_score(_S,_Sec,R,Score):- R=:=0,Score is 0.
my_score(_S,_Sec,R,Score):- R=:=1, Score is 7.
my_score(S,Sec,R,Score) :- R=:=2, attends(S,Sec), Score is 1.
my_score(S,Sec,R,Score) :- R=:=2, not(attends(S,Sec)),
Score is 3.

/* επιστρέφει το σκορ του φοιτητή για μία εβδομάδα*/
studentweekscore(S,W,Score):- onestudentoneweek(S,W,0,R),
second_element(W,Sec),
my_score(S,Sec,R,Score).

/*επιστρέφει το σκορ μιας λίστας φοιτητών για μια εβδομάδα, αθροίζοντας το σκορ όλων των φοιτητών της λίστας */
allstudentsoneweek([],_W,R,R).
allstudentsoneweek([S|T], W, Temp, R) :-
studentweekscore(S,W,Score),
Temp1 is Temp+Score,
allstudentsoneweek(T,W,Temp1,R).

/* επιστρέφει το συνολικό σκορ για ενα συγκεκριμένο πρόγραμμα με εβδομάδες A,B,C, αθροίζοντας τα σκορ της κάθε βδομάδας */
score_schedule(A,B,C,S):-
schedule(A,B,C),
allstudentssorted(L),
allstudentsoneweek(L,A,0,R1),
allstudentsoneweek(L,B,0,R2),
allstudentsoneweek(L,C,0,R3),
Temp is R1+R2,
S is Temp+R3.

/*επιστρέφει το σκόρ(S) και το πρόγραμμα (A,B,C) που αντιστοιχουν σε ελάχιστους δυσαρεστημένους φοιτητές */
voithitiko(A,B,C,E,S):-
minimal_schedule_errors(A,B,C,E),
score_schedule(A,B,C,S).


/*βρίσκει το μέγιστο σκορ που μπορεί να επιτευχθεί έχοντας (δεδομένο) τον ελάχιστο αριθμό δυσαρεστημένων φοιτητών, και το πρόγραμμα(A,B,C) που αντιστοιχεί στο σκορ αυτό */

maximum_score_schedule(A,B,C,E,S):-
findall(X,voithitiko(_,_,_,_,X),L),
max_list(L,S),
voithitiko(A,B,C,E,S).












