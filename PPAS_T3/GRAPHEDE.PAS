Program grapdemo;

{ GRAPDEMO.PAS is a pascal source text demonstrating }
{ how  to use some  of the  Turtlegraphics routines. }

USES crt,turbo3,graphEGA;

{$I ppas_t3.inc Hent andre standard erklaeringer }

{$K-,R-}

{ *** }

VAR
  screencenterx,screencentery: integer;
  ExitSave: pointer;

{$F+} PROCEDURE error; {$F-}    { Error handler }
BEGIN
  ExitProc:=ExitSave;
  TextMode;
END;

PROCEDURE initialize;
BEGIN
  colormode(0);
  pencolor(99);
  window(0,0,999,999);
  window(screencenterx-160,screencentery-100,
         screencenterx+160,screencentery+100);
  fillscreen(0);
END;

PROCEDURE deltawindow(x1,y1,x2,y2: integer);
VAR x0,y0: integer;
BEGIN
  x0:=screencenterx-160;
  y0:=screencentery-100;
  window(x0+x1,y0+y1,x0+x2,y0+y2);
END;

PROCEDURE rect(x1,y1,w,h: integer);
BEGIN
  moveto(x1,y1);
  lineby(0,h-1); lineby(w-1,0); lineby(0,1-h); lineby(1-w,0);
END;

PROCEDURE frame(dx,dy: integer);
VAR n: integer;
BEGIN
  FOR n:=0 TO 2 DO rect(160-dx+n,100-dy+n,2*(dx-n),2*(dy-n));
END;

PROCEDURE waitkey(ms100: integer);
{ Wait ms100 times 100 mSec }
VAR
  ch: char;
  d,timerval: integer;
  timerlow: integer Absolute $0040:$006C;
BEGIN
  FOR d:=1 TO 2*ms100 DO
  BEGIN
    timerval:=timerlow;
    REPEAT UNTIL (timerval<>timerlow) OR KeyPressed;
  END;
  WHILE KeyPressed DO
  BEGIN
    read(kbd,ch);
    IF ch=^M THEN halt;
  END;
END;

{ *** }

VAR
  quart: integer;       { Global for demo1 }

PROCEDURE demo1;        { Sales }
CONST
  month = 3;
  divisions = 3;
  xmin = 72;
  ymin = 35;
  xmax = 290;
  ymax = 140;
  mon: ARRAY[1..12] OF STRING[3] =
    ('Jan','Feb','Mar','Apr','May','Jun',
     'Jul','Aug','Sep','Oct','Nov','Dec');
  qustr: ARRAY[0..3] OF STRING[3] = ('1st','2nd','3rd','4th');
  divisiontext: ARRAY[1..divisions] OF STRING[5]=('North','East','West');
  pat: ARRAY[1..divisions,0..7] OF byte =
    (($03,$84,$48,$30,$30,$48,$84,$03),
     ($AA,$55,$AA,$55,$AA,$55,$AA,$55),
     ($44,$88,$11,$22,$44,$88,$11,$22));

TYPE
  str255= STRING[255];

VAR
  m,n,x,y: integer;
  quarterstring,s: STRING[80];
  data: ARRAY[1..month,0..divisions] OF integer;

PROCEDURE writetext(x,y: integer; s:str255);
CONST textcolor=11;
BEGIN
  moveto(x,y); pencolor(textcolor);
  writestring(s);
END;

PROCEDURE bar(x1,y1,w,h,p,color: integer);
BEGIN
  pencolor(color);
  pattern(pat[p]);
  rect(x1,y1,w,h);
  rectfill(x1+1,y1+1,x1+w-2,y1+h-2);
END;

PROCEDURE pie(x,y,ang,rad,col: integer);
BEGIN
  IF ang<4 THEN ang:=4;
  pencolor(col);
  moveto(x,y);
  line(rad);
  turn(90);
  arc(ang,rad);
  turn(90);
  movedist(rad); line(-rad);    { Always plot from center }
  turn(45); movedist(3);
  paint(turtlex,turtley,col,col);
  turn(180-45);
END;

BEGIN   { demo 1 }
  waitkey(20);
  initialize;
  pencolor(15);
  frame(160,100);
  quart:=(succ(quart) MOD 4+4) MOD 4;
  quarterstring:='Sales '+qustr[quart]+' Quarter';
  FOR m:=1 TO month DO
  BEGIN
    x:=0;
    FOR n:=1 TO divisions DO
    BEGIN
      y:=random(ymax-ymin-10)+10; x:=x+y; data[m,n]:=y;
    END;
    data[m,0]:=x;
  END;
  charstyle(1); charsize(2);
  writetext((320-2*Length(quarterstring)*8)DIV 2,ymax+25,quarterstring);
  charstyle(0); charsize(1);
  FOR m:=0 TO 11 DO
  BEGIN
    str(m:3,s);
    writetext(xmin-44,ymin-4+m*8,s+' -');
  END;
  writetext(xmin-44-2*8,ymax-10,'$1000');
  moveto(xmin+25-48,ymax+10);
  FOR m:=1 TO month DO
    writetext(turtlex+48,turtley,mon[quart*3+m]);
  FOR m:=1 TO month DO FOR n:=1 TO divisions DO
    bar(pred(m)*72+pred(n)*16+xmin+16,ymin+1,12,data[m,n]+1,n,n);
  moveto(xmin,ymax); lineto(xmin,ymin); lineto(xmax,ymin);
  writetext(32-14,16,'Division: ');
  FOR m:=1 TO divisions DO
  BEGIN
    writetext(turtlex+14,turtley,divisiontext[m]);
    bar(turtlex+4,turtley,8,8,m,m);
  END;
  waitkey(20);
  deltawindow(10,ymin-10,xmax,ymax+20);
  fillscreen(0);
  deltawindow(0,0,999,999);
  moveto(xmin+25-66,ymax+10);
  FOR m:=1 TO month DO
    writetext(turtlex+48,turtley,mon[quart*3+m]);
  FOR m:=1 TO month DO
  BEGIN
    turnto(0);
    FOR n:=1 TO divisions DO
      pie(m*72-54+xmin,(ymin+ymax)DIV 2,round(360.0*data[m,n]/data[m,0]),30,n);
  END;
  waitkey(20);
  deltawindow(6,6,313,193);
  colormode(3); fillscreen(15);
END;

{ *** }

PROCEDURE demo2;        { Circle }
VAR
  m: integer;
  demo2tab: ARRAY[0..120] OF integer;
BEGIN   { demo 2 }
  FOR m := 0 TO 120 DO demo2tab[m]:=round(sin(m/20)*sin(m/10)*50+100);
  waitkey(10);
  initialize;
  frame(160,100);
  pencolor(2);
  FOR m := 120 DOWNTO 0 DO circle(m*2+10,demo2tab[m],m DIV 3);
  IF KeyPressed THEN exit;
  waitkey(10);
  deltawindow(6,6,313,193);
  colormode(3); 
  FOR m:=1 TO 4 DO
  BEGIN
    fillscreen(15);
    IF KeyPressed THEN exit;
    waitkey(10);
  END;
END;

{ *** }

{ Global for demo3 }
CONST
  demo3max = 220;
VAR
  calculatedemo3: boolean;
  demo3tab: ARRAY [0..demo3max] OF integer;

PROCEDURE demo3;        { PolyPascal }
CONST
  polypascal: ARRAY[1..2] OF STRING[7]=('  Poly',' Pascal');
  solid: ARRAY[0..3] OF integer=(-1,-1,-1,-1);
VAR
  m,n: integer;
  buf: ARRAY [1..2,-5..594] OF byte;    { 6+((64+1)div 2)*18 }
BEGIN   { demo 3 }
  IF calculatedemo3 THEN
  BEGIN
    calculatedemo3:=false;
    FOR n:=0 TO demo3max DO
      demo3tab[n]:=round(sin(-n/20)*sin(n/10)*40);
  END ELSE
    waitkey(20);
  initialize;
  FOR n:=1 TO 2 DO
  BEGIN
    pencolor(0);
    pattern(solid);
    rectfill(5,3,64,18);        { Clear field with color 0 }
    pencolor(1);
    moveto(8,8);                { Baseline of text }
    writestring(polypascal[n]); { Write text using color 1 }
    rect(5,3,64,18);            { Box around }
    getpic(buf[n],5,3,68,20);   { Take copy }
  END;
  initialize;
  frame(160,100);
  pencolor(15);
  FOR m := 0 TO demo3max DO putpic(buf[2],m+20,50-demo3tab[m]);
  IF KeyPressed THEN exit;
  waitkey(5);
  FOR m := 0 TO demo3max DO putpic(buf[1],m+20,demo3tab[m]+68-1-m DIV 3+73);
  waitkey(10);
  deltawindow(6,6,313,193);
  colormode(3);
  FOR m:=1 TO 5 DO
  BEGIN
    palette(random(4));
    fillscreen(random(3)+1);
    waitkey(10);
  END;
END;

{ *** }

PROCEDURE demo4;        { Get/Put picture }
VAR
  i,m,n,x,y: integer;
  picbuf: ARRAY [-5..4950] OF byte; { 6+((99+1)div 2)*99 }
  kbdwait: integer;
  randtab: ARRAY [0..23] OF integer;
BEGIN   { demo 4 }
  waitkey(20);
  initialize;
  frame(147,99);
  FOR kbdwait:=1 TO 5 DO
  BEGIN
    deltawindow(135,75,185,125);
    colormode(0); 
    fillscreen(0);
    palette(random(2));
    m:=random(3)+1;
    pencolor(m);
    turnto(0);
    n:=random(20)+5;
    FOR i:=0 TO 35 DO
    BEGIN
      turtlehome;
      turnto(10*i);
      arc(180,n);
    END;
    REPEAT n:=random(3)+1 UNTIL n<>m;
    IF KeyPressed THEN exit;
    waitkey(5);
    turtlehome;
    paint(turtlex,turtley,n,0);
    waitkey(5);
    getpic(picbuf,1,1,99,99);
    deltawindow(16,4,303,195);
    FOR x:=0 TO 23 DO randtab[x]:=x;
    FOR x:=0 TO 23 DO
    BEGIN
      m:=random(24); n:=random(24);
      y:=randtab[m]; randtab[m]:=randtab[n]; randtab[n]:=y;
    END;
    IF random(2)=0 THEN colormode(random(4)) ELSE colormode(0);
    FOR x:=0 TO 23 DO
      putpic(picbuf,(randtab[x] MOD 6)*48,(randtab[x] DIV 6)*48);
    IF KeyPressed THEN exit;
    waitkey(10);
  END;
END;

{ *** }

PROCEDURE demo5;        { Line }
VAR
  xx: ARRAY [0..50] OF integer;
  yy: ARRAY [0..50] OF integer;
  n,up,down,downstep,upstep,pl,pc: integer;

PROCEDURE drawpic(down,up,downstep,upstep : integer);
VAR
  nr: integer;
BEGIN
  FOR nr:=1 TO 50 DO
  BEGIN
    moveto(160,down); lineto(xx[nr],yy[nr]); lineto(160,up);
    moveto(160,down); lineto(320-xx[nr],yy[nr]); lineto(160,up);
    down:=down+downstep;
    IF (down>=200) OR (down<=0) THEN
    BEGIN
      down:=down-downstep; downstep:=-downstep;
    END;
    up:=up+upstep;
    IF (up<=0) OR (up>=200) THEN
    BEGIN
      up:=up-upstep; upstep:=-upstep;
    END;
  END;
END;

BEGIN   { demo5 }
  FOR n:=0 TO 50 DO
  BEGIN
    xx[n]:=round(sin(n/50*pi)*150)+160;
    yy[n]:=round((cos(n/50*pi)+1)*50)+25;
  END;
  waitkey(5);
  initialize;
  FOR pl:=0 TO 1 DO FOR pc:=1 TO 3 DO
  BEGIN
    palette(pl); pencolor(pc);
    down:=random(200); downstep:=random(10);
    up:=random(200); upstep:=-random(10);
    drawpic(down,up,downstep,upstep);
    IF pc=2 THEN
    BEGIN
      IF KeyPressed THEN exit;
      waitkey(5);
      paint(160,up,1,0);
      paint(160,down,1,0);
    END;
    IF KeyPressed THEN exit;
    waitkey(10);
    pencolor(0);
    drawpic(down,up,downstep,upstep);
  END;
END;

{ *** }

PROCEDURE demo6;        { Arc }
VAR
  i,j,paintypos: integer;
BEGIN   { demo 6 }
  waitkey(20);
  initialize;
  pencolor(3);
  turtlehome;
  FOR j:=1 TO 45 DO
  BEGIN
    FOR i:=1 TO 3 DO
    BEGIN
      line(40); arc(120,20);
    END;
    turn(8);
    IF KeyPressed THEN exit;
  END;
  turtlehome; turnto(270);
  movedist(80); paintypos:=turtley; movedist(20); turnto(0);
  FOR j:=1 TO 24 DO
  BEGIN
    FOR i:=3 TO 8 DO
    BEGIN
      arc(360,i); arc(-360,i);
    END;
    arc (15,100);
    IF KeyPressed THEN exit;
  END;
  turtlehome;
  paint(turtlex,paintypos,2,3);
  paint(turtlex,turtley,1,0);
END;

{ *** }

VAR
  cmode: integer;       { CrtMode (3,4,6,8,9,13,14,15,16,64 or 72) }

BEGIN   { Main program }
  ExitSave:=ExitProc;
  ExitProc:=@Error;
  cmode:=13;
  crtmode(cmode);
  CASE cmode OF
  4,5,13:       aspect(10,10);
  6,14:         aspect(18,10);
  8,9:          aspect(13,10);
  END;
  screencenterx:=turtlex;
  screencentery:=turtley;
  calculatedemo3:=true;
  REPEAT
    demo1; demo2; demo3; demo4; demo5; demo6;
  UNTIL false;
END.
