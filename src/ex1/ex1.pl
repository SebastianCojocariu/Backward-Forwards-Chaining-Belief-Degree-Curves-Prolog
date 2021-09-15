check_list_contained(List1, List2):- intersection(List1, List2, Common), Common=List1.

remove_negations([], []):-!.
remove_negations([n(P)|Q], [P|R]):- remove_negations(Q, R), !.


backward_chaining([], KB, 'yes'):-!.
backward_chaining([Positive_atom|Goals], KB, R):- member(Clause, KB), 
												  member(Positive_atom, Clause), 
												  not(n(_)=Positive_atom),
												  delete(Clause, Positive_atom, Clause_without_positive_atom),
												  remove_negations(Clause_without_positive_atom, Clause_without_negations),
												  append(Clause_without_negations, Goals, Concatenate),
												  backward_chaining(Concatenate, KB, R), !. 
backward_chaining(Senteces, KB, 'no'):- !.


forward_chaining_helper(Goals, KB, Solved, 'yes'):- check_list_contained(Goals, Solved), !.
forward_chaining_helper(Goals, KB, Solved, R):- member(Clause, KB), 
												member(Positive_atom, Clause), 
											    not(Positive_atom=n(_)), 
											    not(member(Positive_atom, Solved)),
											    delete(Clause, Positive_atom, Clause_without_positive_atom),
											    remove_negations(Clause_without_positive_atom, Clause_without_negations), 
											    check_list_contained(Clause_without_negations, Solved), 
											    forward_chaining_helper(Goals, KB, [Positive_atom|Solved], R), !.
forward_chaining_helper(Senteces, KB, Solved, 'no'):- !.	
forward_chaining(Sentences, KB, R):- forward_chaining_helper(Sentences, KB, [], R).										


read_file(Stream,[]) :- at_end_of_stream(Stream).
read_file(Stream,[L|R]) :- not(at_end_of_stream(Stream)), read(Stream, L), read_file(Stream, R).

read_KB(File_content):- open('ex1_own_kb.txt', read, Stream), read_file(Stream, File_content), close(Stream), !.

main():- read_KB(File), 
		 [Rules|_]=File,
		 repeat,
		 ask_questions(Goals), 
		 append(Rules, Goals, KB),
		 forward_chaining([trip], KB, Response_forward), writef("The output for Forward Chaining of whether you are going on a trip is: %w \n", [Response_forward]),
		 backward_chaining([trip], KB, Response_backward), writef("The output for Backward Chaining of whether you are going on a trip is: %w\n\n", [Response_backward]),
		 writeln('Should we continue? Please type stop to end or any other combination to continue!'),
		 read(Stop_response), nl,
		 (Stop_response = stop ->
		 	writef('You typed %w. Have a nice day! \n\n', [Stop_response]), !;
		 	writef('You typed %w. Start again\n\n', [Stop_response]), fail
		 	).



ask_questions([[Q1],[Q2],[Q3],[Q4],[Q5],[Q6]]):- math_question(Q1, G1),
												 romanian_question(Q2, G2),
												 informatics_question(Q3, G3),
												 pass_overall_condition(G1, G2, G3, Q4),
												 highest_grades_in_class_question(Q5),
												 olympic_question(Q6). 


at_least_5_condition(Grade, Subject_predicate, Subject_predicate):- Grade >= 5, !.
at_least_5_condition(Grade, Subject_predicate, n(Subject_predicate)):- !.

pass_overall_condition(Math_grade, Romanian_grade, Informatics_grade, pass_overall):- sum_list([Math_grade, Romanian_grade, Informatics_grade], Total), Total >= 18, !.
pass_overall_condition(_, _, _, n(pass_overall)):-!.

math_question(Predicate, Grade):-
	repeat,
	writeln('Which grade did you get at Math? (number from 1 to 10)'),
	read(Grade), nl,
	(number(Grade), Grade >= 1, 10 >= Grade ->
		writef('Your response to the last question is %w\n\n', [Grade]),
		at_least_5_condition(Grade, pass_math, Predicate), !;
		writeln('The input should be a number. Please try again.'), fail).
	

romanian_question(Predicate, Grade):-
	repeat,
	writeln('Which grade did you get Romanian? (number from 1 to 10)'),
	read(Grade), nl,
	(number(Grade), Grade >= 1, 10 >= Grade->
		writef('Your response to the last question is %w\n\n', [Grade]),
		at_least_5_condition(Grade, pass_romanian, Predicate), !;
		writeln('The input should be a number. Please try again.'), fail).

informatics_question(Predicate, Grade):-
	repeat,
	writeln('Which grade did you get at Informatics? (number from 1 to 10)'),
	read(Grade), nl,
	(number(Grade), Grade >= 1, 10 >= Grade ->
		writef('Your response to the last question is %w\n\n', [Grade]),
		at_least_5_condition(Grade, pass_informatics, Predicate), !;
		writeln('The input should be a number. Please try again.'), fail).



highest_grades_condition(yes, highest_grades):-!.
highest_grades_condition(no, n(highest_grades)):-!.

highest_grades_in_class_question(Predicate):-
	repeat,
	writeln('Do you have the highest grades among your collegues? (yes or no)'),
	read(Ans), nl,
	(member(Ans, [yes, no]) ->
		writef('Your response to the last question is %w\n\n', [Ans]),
		highest_grades_condition(Ans, Predicate), !;
		writeln('The input should be yes or no. Please try again.'), fail).


olympic_condition(yes, olympic):-!.
olympic_condition(no, n(olympic)):-!.

olympic_question(Predicate):-
	repeat,
	writeln('Are you olympic at some subject? (yes or no)'),
	read(Ans), nl,
	(member(Ans, [yes, no]) ->
		writef('Your response to the last question is %w\n\n', [Ans]),
		olympic_condition(Ans, Predicate), !;
		writeln('The input should be yes or no. Please try again.'), fail).

