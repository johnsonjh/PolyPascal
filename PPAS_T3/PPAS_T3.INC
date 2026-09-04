{
   ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
   บ                                                            บ
   บ Include fil for manglende konstanter og funktioner i Turbo บ
   บ                                                            บ
   ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
}

{ skaerm kontrol strenge fra PPAS }

CONST clrhom: string[1]='';     { string[6]=#27'Y  '#27'J';     }
CONST clreos: string[1]='';     { string[2]=#27'J';             }
CONST clreol: string[1]='';     { string[2]=#27'K';             }
CONST inslin: string[1]='';     { string[2]=#27'L';             }
CONST dellin: string[1]='';     { string[2]=#27'M';             }
CONST rvson : string[1]='';     { string[2]=#27'P';             }
CONST rvsoff: string[1]='';     { string[2]=#27'Q';             }
CONST inton : string[1]='';     { string[2]=#27'R';             }
CONST intoff: string[1]='';     { string[2]=#27'S';             }
CONST ulnon : string[1]='';     { string[2]=#27'V';             }
CONST ulnoff: string[1]='';     { string[2]=#27'W';             }
CONST blkon : string[1]='';     { string[2]=#27'T';             }
CONST blkoff: string[1]='';     { string[2]=#27'U';             }
CONST alloff: string[1]='';     { string[2]=#27'X';             }

{ ny funktion PwrTen                        }
{ er i PPAS men ikke i Turbo3               }
{ Kan ogs laves med PwrTen:=exp(n*ln(10)); }
{ Dette giver dog lavere njagtighed        }

function PwrTen(N: Integer): real; { Brug extended hvis Turbo4 & 8087 }
const UseLog=false;
var
  I: Integer;
  P: real;
begin
  if UseLog then
    PwrTen:=exp(N*ln(10)) { ln(10) er en konstant, burde indtastes som sdan! }
  else begin
    I:=0; P:=1.0;
    repeat
      if Odd(N) then
      case I of
        0: P:=P*1E1;
        1: P:=P*1E2;
        2: P:=P*1E4;
        3: P:=P*1E8;
        4: P:=P*1E16;
        5: P:=P*1E32;
        6: P:=P*1E32*1E32;                { Kan optimeres hvis 8087 bruges }
        7: P:=P*1E32*1E32*1E32*1E32;
        8: P:=P*1E32*1E32*1E32*1E32*1E32*1E32*1E32*1E32;
      end;
      N:=N shr 1; I:=Succ(I);
    until N=0;
    PwrTen:=P;
  end;
end;

{ ny gotoxy rutine                   }
{ TopLeft= 0,0 i PPAS                }
{ TopLeft=1,1 i Turbo3 (Turbo3 Unit) }

PROCEDURE PPASGotoXY(X,Y: integer);
begin
  GotoXY(succ(x),succ(y))
end;

