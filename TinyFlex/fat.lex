
TINY COMPILATION: fat.ty
	5: reserved word: read
	5: ID, name= x
	5: ;
	6: reserved word: if
	6: NUM, val= 0
	6: <
	6: ID, name= x
	6: reserved word: then
	7: ID, name= fact
	7: :=
	7: NUM, val= 1
	7: ;
	8: reserved word: repeat
	9: ID, name= fact
	9: :=
	9: ID, name= fact
	9: *
	9: ID, name= x
	9: ;
	10: ID, name= x
	10: :=
	10: ID, name= x
	10: -
	10: NUM, val= 1
	11: reserved word: until
	11: ID, name= x
	11: =
	11: NUM, val= 0
	11: ;
	12: reserved word: write
	12: ID, name= fact
	13: reserved word: end
	14: EOF
