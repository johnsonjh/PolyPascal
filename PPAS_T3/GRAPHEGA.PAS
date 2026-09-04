{
         ษอออออออออออออออออออออออออออออออออออออออออออออออออออออป
         บ PolyPascal grafik rutiner for Turbo Pascal ver 4    บ
         บ EGA version (aldrig leveret sammen med PolyPascal)  บ
         บ Copyright (C) 1987 PolyTech A/S                     บ
         ศอออออออออออออออออออออออออออออออออออออออออออออออออออออผ
}

UNIT GraphEGA;

{$D-,I-,S-}

interface

uses crt;     { DirectVideo:=false }


type
  font=record
         case integer of
         0: (table: ^byte;      { ptr to CHR(0)         }
             bitoffset,         { bit offset            }
             bitcount,          { bit/character         }
             width,             { character width       }
             height,            { height                }
             ascent,            { topline-baseline      }
             size,              { scaling factor        }
             style,             { 0=normal, 1=Italic    }
             deltax,            { turtle increment X    }
             deltay: integer    { turtle increment Y    });
         1: (initializer: array[1..11] of word);
       end;

  paletterec=
    record
      color: array[0..15] of byte;
      overscan: byte
    end;

CONST
  romfont: font=(initializer:($FA6E,$F000,0,64,8,8,7,1,0,8,0));

procedure textmode;
procedure crtmode(m: integer);
procedure window(x1,y1,x2,y2: integer);
procedure background(c: integer);
procedure palette(c: integer);
procedure pencolor(c: integer);
procedure colormode(mode: integer);
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
function  point(x,y: integer): integer;
function  turtlex: integer;
function  turtley: integer;
function  turtleang: integer;
procedure egapalette(VAR pal: paletterec);
procedure workpage(page: integer);
procedure disppage(page: integer);
procedure copypage(src,dest: integer);
procedure writestring(s: string);
procedure charstyle(style: integer);
procedure charsize(size: integer);
procedure charfont(VAR font);
procedure aspect(xfac,yfac: integer);
procedure turtlehome;

implementation

{$L GraphEGA}

procedure textmode;                             external;
procedure crtmode(m: integer);                  external;
procedure window(x1,y1,x2,y2: integer);         external;
procedure background(c: integer);               external;
procedure palette(c: integer);                  external;
procedure pencolor(c: integer);                 external;
procedure colormode(mode: integer);             external;
procedure moveto(x,y: integer);                 external;
procedure moveby(dx,dy: integer);               external;
procedure movedist(x: integer);                 external;
procedure lineto(x,y: integer);                 external;
procedure lineby(dx,dy: integer);               external;
procedure line(x: integer);                     external;
procedure plotat(x,y: integer);                 external;
procedure plotby(dx,dy: integer);               external;
procedure turnto(x: integer);                   external;
procedure turn(x: integer);                     external;
procedure paint(x,y,fc,bc: integer);            external;
procedure fillscreen(c: integer);               external;
procedure pattern(VAR b);                       external;
procedure rectfill(x,y,w,h: integer);           external;
procedure getpic(VAR b;x,y,w,h: integer);       external;
procedure putpic(VAR b;x,y: integer);           external;
procedure circle(x,y,r: integer);               external;
procedure arc(a,r: integer);                    external;
function  point(x,y: integer): integer;         external;
function  turtlex: integer;                     external;
function  turtley: integer;                     external;
function  turtleang: integer;                   external;
procedure egapalette(VAR pal: paletterec);      external;
procedure workpage(page: integer);              external;
procedure disppage(page: integer);              external;
procedure copypage(src,dest: integer);          external;
procedure writestring(s: string);               external;
procedure charstyle(style: integer);            external;
procedure charsize(size: integer);              external;
procedure charfont(VAR font);                   external;
procedure aspect(xfac,yfac: integer);           external;
procedure turtlehome;                           external;

end.
