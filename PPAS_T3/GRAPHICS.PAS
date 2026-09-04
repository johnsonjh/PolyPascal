{
         ษอออออออออออออออออออออออออออออออออออออออออออออออออออออป
         บ PolyPascal grafik rutiner for Turbo Pascal ver 4    บ
         บ Copyright (C) 1987 PolyTech A/S                     บ
         ศอออออออออออออออออออออออออออออออออออออออออออออออออออออผ
}

UNIT Graphics;

{$D-,I-,S-}

interface

uses crt;     { DirectVideo:=false }


procedure crtmode(m: integer);
procedure window(x1,y1,x2,y2: integer);
procedure background(c: integer);
procedure palette(c: integer);
procedure pencolor(c: integer);
procedure colormap(c0,c1,c2,c3: integer);
procedure moveto(x,y: integer);
procedure moveby(dx,dy: integer);
procedure movedist(x: integer);
procedure lineto(x,y: integer);
procedure lineby(dx,dy: integer);
procedure line(x: integer);
procedure plotat(x,y: integer);
procedure plotby(dx,dy: integer);
procedure turnto(x: integer);
procedure turn(x: integer);
procedure paint(x,y,fc,bc: integer);
procedure fillscreen(c: integer);
procedure pattern(VAR b);
procedure rectfill(x,y,w,h: integer);
procedure getpic(VAR b;x,y,w,h: integer);
procedure putpic(VAR b;x,y: integer);
procedure circle(x,y,r: integer);
procedure arc(a,r: integer);
function point(x,y: integer): integer;
function turtlex: integer;
function turtley: integer;
function turtleang: integer;

implementation

{$L Graphics}

procedure crtmode(m: integer); external;
procedure window(x1,y1,x2,y2: integer); external;
procedure background(c: integer); external;
procedure palette(c: integer); external;
procedure pencolor(c: integer); external;
procedure colormap(c0,c1,c2,c3: integer); external;
procedure moveto(x,y: integer); external;
procedure moveby(dx,dy: integer); external;
procedure movedist(x: integer); external;
procedure lineto(x,y: integer); external;
procedure lineby(dx,dy: integer); external;
procedure line(x: integer); external;
procedure plotat(x,y: integer); external;
procedure plotby(dx,dy: integer); external;
procedure turnto(x: integer); external;
procedure turn(x: integer); external;
procedure paint(x,y,fc,bc: integer); external;
procedure fillscreen(c: integer); external;
procedure pattern(VAR b); external;
procedure rectfill(x,y,w,h: integer); external;
procedure getpic(VAR b;x,y,w,h: integer); external;
procedure putpic(VAR b;x,y: integer); external;
procedure circle(x,y,r: integer); external;
procedure arc(a,r: integer); external;
function point(x,y: integer): integer; external;
function turtlex: integer; external;
function turtley: integer; external;
function turtleang: integer; external;

end.
