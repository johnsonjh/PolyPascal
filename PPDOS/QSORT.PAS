PROGRAM qsort; {$K-,R-}

{ This program demonstrates the quicksort algorithm, which      }
{ provides an extremely effecient method of sorting arrays in   }
{ memory. The program generates a list of 1000 random numbers   }
{ between 0 and 29999, and then sorts them using the QUICKSORT  }
{ procedure. Finally, the sorted list is output on the screen.  }
{ Note that stack and range checks are turned off (through the  }
{ compiler directive above) to optimize execution speed.        }

CONST
  max = 1000;

TYPE
  list = ARRAY[1..max] OF integer;

VAR
  data: list;
  i: integer;

{ QUICKSORT sorts elements in the array A with indices between  }
{ LO and HI (both inclusive). Note that the QUICKSORT proce-    }
{ dure provides only an "interface" to the program. The actual  }
{ processing takes place in the SORT procedure, which executes  }
{ itself recursively.                                           }

PROCEDURE quicksort(VAR a: list; lo,hi: integer);

PROCEDURE sort(l,r: integer);
VAR
  i,j,x,y: integer;
BEGIN
  i:=l; j:=r; x:=a[(l+r) DIV 2];
  REPEAT
    WHILE a[i]<x DO i:=i+1;
    WHILE x<a[j] DO j:=j-1;
    IF i<=j THEN
    BEGIN
      y:=a[i]; a[i]:=a[j]; a[j]:=y;
      i:=i+1; j:=j-1;
    END;
  UNTIL i>j;
  IF l<j THEN sort(l,j);
  IF i<r THEN sort(i,r);
END;

BEGIN {quicksort};
  sort(lo,hi);
END;

BEGIN {qsort}
  write('Now generating 1000 random numbers...');
  FOR i:=1 TO max DO data[i]:=random(30000);
  writeln;
  write('Now sorting random numbers...');
  quicksort(data,1,max);
  writeln;
  FOR i:=1 TO 1000 DO write(data[i]:8);
END.
