/* ����� ������������� ���:3085
����������� ������� ���:3175
*/



/* allsubjwithoutdupl: ���������� ����� �� ��� �� �������� ��� ���������������� ��� ��������,������������ ��� ����� ��������� */

allsubjects(L) :- findall(X, attends(_,X), L).
allsubjwithoutdupl(Z) :- allsubjects(X), sort(X,Z).

/* allstudentssorted: ���������� �� ����� ����  �������� ��� ������������� ��������, ������������ �������� ��������� */

allstudents(L) :- findall(X, attends(X,_), L).
allstudentssorted(Z) :- allstudents(X), sort(X,Z).

/* ���������� ��� ����� �� ���� ��� ������� ���������� ��� ��������� */

permutatedlist(L):-  allsubjwithoutdupl(X),permutation(X,L).
/*
 listdivider: ������� ��� ����� �� ���� ��������, ��� ��� ���� ������� */
listdivider([X,Y], [X], [Y], []).
listdivider([X,Y,Z|Tail],[X|Xtail],[Y|Ytail],[Z|Ztail]) :-
listdivider(Tail,Xtail,Ytail,Ztail).


schedule(A, B, C) :-   permutatedlist(L),  listdivider(L, A, B, C).

/* ���������� true �� ���� �������� ������������ ���� ��� ��������� ��� ��� ����� */

attendsall(_F,[]).
attendsall(F,[D|T]) :- attends(F,D), attendsall(F,T).

/* ���������� ����� �������� ��� ��� ����� �������� ������������� ���� ��� ��������� ��� ��� ����� ��������� */

attendall([],_Lect,E,E).
attendall([F|T],Lect,Temp,E):- attendsall(F,Lect),
E1 is Temp+1,
attendall(T,Lect,E1,E).
attendall([F|T],Lect,Temp,E):- not(attendsall(F,Lect)),
attendall(T,Lect,Temp,E).


/*���������� ��� ������ ��� �������� ��� ����� �������������� �� ��� ������������ ���������*/
schedule_errors(A,B,C,E):-
    schedule(A,B,C),
    allstudentssorted(Z),
    attendall(Z, A, 0, X),
     attendall(Z, B, 0, Y),
    E is X+Y.

/* ������� ��� �������� ������ �������������� �������� ��� ����������� �� ������ ���������� (E) ��� �� ��������� ��� ����������� �� ����� ��� ������ (A,B,C,E) */

minimal_schedule_errors(A,B,C,E) :-
    findall(X,schedule_errors(_,_,_,X),L),
    min_list(L,E),
    schedule_errors(A,B,C,E).

/*���������� �� ����� �������� ���� ������, �� ��� ��������� ���� */
first_element([H|_],H).
/* ���������� �� ������� �������� ���� ������, �� ��� ��������� ���� */
second_element([_H|T],S):- first_element(T,S).


/*���������� ��� ������ ��� ��������� ��� ������������ ���� �������� ��� ��� ����� ���������*/
onestudentoneweek(_S,[],R,R).
onestudentoneweek(S,[W|T],Temp,R):- attends(S,W),
	Temp1 is Temp+1,
	onestudentoneweek(S,T,Temp1,R).
onestudentoneweek(S,[W|T],Temp,R):-
	not(attends(S,W)),
	onestudentoneweek(S,T,Temp,R).

/* ��������� ��������� ��� ��� studentweekscore */
my_score(_S,_Sec,R,Score):- R=:=3,Score is -7.
my_score(_S,_Sec,R,Score):- R=:=0,Score is 0.
my_score(_S,_Sec,R,Score):- R=:=1, Score is 7.
my_score(S,Sec,R,Score) :- R=:=2, attends(S,Sec), Score is 1.
my_score(S,Sec,R,Score) :- R=:=2, not(attends(S,Sec)),
Score is 3.

/* ���������� �� ���� ��� ������� ��� ��� ��������*/
studentweekscore(S,W,Score):- onestudentoneweek(S,W,0,R),
second_element(W,Sec),
my_score(S,Sec,R,Score).

/*���������� �� ���� ���� ������ �������� ��� ��� ��������, ����������� �� ���� ���� ��� �������� ��� ������ */
allstudentsoneweek([],_W,R,R).
allstudentsoneweek([S|T], W, Temp, R) :-
studentweekscore(S,W,Score),
Temp1 is Temp+Score,
allstudentsoneweek(T,W,Temp1,R).

/* ���������� �� �������� ���� ��� ��� ������������ ��������� �� ��������� A,B,C, ����������� �� ���� ��� ���� �������� */
score_schedule(A,B,C,S):-
schedule(A,B,C),
allstudentssorted(L),
allstudentsoneweek(L,A,0,R1),
allstudentsoneweek(L,B,0,R2),
allstudentsoneweek(L,C,0,R3),
Temp is R1+R2,
S is Temp+R3.

/*���������� �� ����(S) ��� �� ��������� (A,B,C) ��� ������������ �� ���������� ��������������� �������� */
voithitiko(A,B,C,E,S):-
minimal_schedule_errors(A,B,C,E),
score_schedule(A,B,C,S).


/*������� �� ������� ���� ��� ������ �� ���������� ������� (��������) ��� �������� ������ �������������� ��������, ��� �� ���������(A,B,C) ��� ����������� ��� ���� ���� */

maximum_score_schedule(A,B,C,E,S):-
findall(X,voithitiko(_,_,_,_,X),L),
max_list(L,S),
voithitiko(A,B,C,E,S).












