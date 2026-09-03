PROGRAM primes; {$R-}

{ This program will calculate and display all prime numbers     }
{ between 1 and 30000. The algorithm of the program is to start }
{ out with an array containing representatives for all odd num- }
{ bers between 3 and 29999. Starting from 3 and working upwards }
{ each odd number is then tested. If a number is still a member }
{ of the list when it is tested, it is a prime number, and thus }
{ it is printed, and all odd multiples of the number are elimi- }
{ nated from the list. As can be expected, the program is quite }
{ slow on calculating the very first primes, but from then on   }
{ it gets faster and faster. Note that 1 and 2 are assumed to   }
{ be primes, and not actually calculated.                       }

CONST
  max2 = 15000;   {maxprime/2}
  max3 = 10000;   {maxprime/3}

VAR
  i,j,k: integer;
  test: ARRAY[2..max2] OF boolean;

BEGIN
  write(1:8,2:8);
  FOR i:=2 TO max2 DO test[i]:=true;
  FOR i:=2 TO max2 DO
  IF test[i] THEN
  BEGIN
    j:=i+i-1; write(j:8);
    IF j<max3 THEN
    BEGIN
      k:=i+j;
      WHILE k<=max2 DO
      BEGIN
	test[k]:=false; k:=k+j;
      END;
    END;
  END;
  writeln;
END.
