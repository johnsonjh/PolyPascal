{
         ษอออออออออออออออออออออออออออออออออออออออออออออออออออออป
         บ PolyPascal Hercules rutiner for Turbo Pascal ver 4  บ
         บ Copyright (C) 1987 PolyTech A/S                     บ
         ศอออออออออออออออออออออออออออออออออออออออออออออออออออออผ
}

{
 Font tabellen er blever includeret in .Tpu filen.
 Den kan i det endelige program findes ved at sge
 efter de 8 tegn 'Font9x16'.
}

UNIT Hercules;

{$D-,I-,S-}

interface

uses crt;     { DirectVideo:=false }

procedure grafmode(m: integer);
procedure textmode;
procedure disppage(p: integer);
procedure workpage(p: integer);
procedure window(x1,y1,x2,y2: integer);
procedure pencolor(c: integer);
procedure fillscreen(c: integer);
procedure moveto(x,y: integer);
procedure moveby(dx,dy: integer);
procedure lineto(x,y: integer);
procedure lineby(dx,dy: integer);
procedure plotat(x,y: integer);
procedure plotby(dx,dy: integer);
procedure paint(x,y,c: integer);
procedure pattern(VAR p);
procedure rectfill(x1,y1,x2,y2: integer);
procedure chartype(t: integer);
procedure grafwrite(s: string);
function point(x,y: integer): integer;

implementation

{$L hercules}

procedure grafmode(m: integer); external;
procedure textmode; external;
procedure disppage(p: integer);external;
procedure workpage(p: integer);external;
procedure window(x1,y1,x2,y2: integer); external;
procedure pencolor(c: integer); external;
procedure fillscreen(c: integer); external;
procedure moveto(x,y: integer); external;
procedure moveby(dx,dy: integer); external;
procedure lineto(x,y: integer); external;
procedure lineby(dx,dy: integer); external;
procedure plotat(x,y: integer); external;
procedure plotby(dx,dy: integer); external;
procedure paint(x,y,c: integer); external;
procedure pattern(VAR p); external;
procedure rectfill(x1,y1,x2,y2: integer); external;
procedure chartype(t: integer); external;
procedure grafwrite(s: string); external;
function point(x,y: integer): integer; external;

end.
