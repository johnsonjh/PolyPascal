Program grapdemo;
{$R+,K+}

{ GRAPDEMO.PAS is a pascal source text demonstrating }
{ how  to use some  of the  Turtlegraphics routines. }

USES crt,turbo3,graphics;

{$I ppas_t3.inc Hent andre standard erklaeringer }

CONST
  demo3nomax = 220; { Global for demo3 }

VAR
  demo3no: integer;
  demo3tab: ARRAY [0..demo3nomax] OF integer;
  quart: integer; { Global for demo1 }

PROCEDURE rect(x1,y1,w,h: integer);
BEGIN
  moveto(x1,y1); lineto(x1,y1+h-1); lineto(x1+w-1,y1+h-1);
  lineto(x1+w-1,y1); lineto(x1,y1);
END;

PROCEDURE rect320;
BEGIN
  rect(0,0,320,200); rect(1,1,318,198); rect(2,2,316,196);
END;

PROCEDURE calcdemo3;
BEGIN
  demo3tab[demo3no]:=round(sin(-demo3no/20)*sin(demo3no/10)*40);
  IF demo3no<demo3nomax THEN demo3no:=succ(demo3no);
END;

PROCEDURE waitkey(delay: integer);
VAR 
  ch: char;
BEGIN
  FOR delay:=1 TO delay*10 DO
  BEGIN
    calcdemo3;
    IF keypressed THEN
    BEGIN
      read(kbd,ch);
      IF ch=^M THEN
      BEGIN
        crtmode(3); halt;
      END;
    END;
  END;
END;

PROCEDURE demo1;
CONST
  month = 3;
  divisions = 3;
  xmin = 72;
  ymin = 44;
  xmax = 290;
  ymax = 150;
  mon: ARRAY[1..12] OF STRING[3] =
    ('Jan','Feb','Mar','Apr','May','Jun',
     'Jul','Aug','Sep','Oct','Nov','Dec');
  qustr: ARRAY[0..3] OF STRING[5] = ('1st','2nd','3rd','4th');
  pat: ARRAY[1..divisions,0..7] OF byte =
    (($03,$84,$48,$30,$30,$48,$84,$03),
     ($AA,$55,$AA,$55,$AA,$55,$AA,$55),
     ($44,$88,$11,$22,$44,$88,$11,$22));
VAR
  m,n,x,y: integer;
  data: ARRAY[1..month,0..divisions] OF integer;

PROCEDURE bar(x1,y1,w,h,p: integer);
BEGIN
  rect(x1,y1,w,h);
  pattern(pat[p]); rectfill(x1+1,y1+1,x1+w-1,y1+h-1);
END;

PROCEDURE pie(ang,rad,col: integer);
CONST
  offs = 0;
BEGIN
  IF ang<4 THEN ang:=4;
  pencolor(col);
  turn(ang DIV 2); movedist(offs); turn(-ang DIV 2);
  line(rad); turn(90); arc(ang,rad); turn(90); line(rad);
  turn(180-(ang DIV 2)); movedist(rad-2);
  paint(turtlex,turtley,col,col);
  movedist(2-rad-offs); turn(ang DIV 2);
END;

BEGIN   { demo 1 }
  waitkey(5);
  crtmode(4);
  quart:=(succ(quart) MOD 4+4) MOD 4;
  FOR m:=1 TO month DO
  BEGIN
    x:=0;
    FOR n:=1 TO divisions DO
    BEGIN
      y:=random(ymax-ymin-10)+10; x:=x+y; data[m,n]:=y;
    END;
    data[m,0]:=x;
  END;
  rect320;
  PPASGotoXY(12,2); write('Turnover ',qustr[quart],' Quarter');
  PPASGotoXY(3,5); writeln('$1000');
  FOR m:=0 TO 12 DO
  BEGIN
    PPASGotoXY(3,m+7); write(12-m:3,' -');
  END;
  moveto(xmin,ymax); lineto(xmin,ymin); lineto(xmax,ymin);
  PPASGotoXY(xmin DIV 8+1,5); FOR m:=1 TO month DO write(mon[quart*3+m]:5,'    ');
  FOR m:=1 TO month DO FOR n:=1 TO divisions DO
  BEGIN
    pencolor(n); bar(m*72+n*16+xmin-72,ymin+1,12,data[m,n]+1,n);
  END;
  PPASGotoXY(4,22); write('Division: North   East   West');
  FOR m:=1 TO divisions DO
  BEGIN
    pencolor(m); bar(20*8+m*56-56,16,8,8,m);
  END;
  waitkey(5);
  window(10,40,300,150); PPASGotoXY(3,5); write(' ':5); fillscreen(0);
  PPASGotoXY(10,2); write('Turnover ',qustr[quart],' Quarter  ');
  PPASGotoXY(xmin DIV 8-1,5); FOR m:=1 TO month DO write(mon[quart*3+m]:5,'    ');
  FOR m:=1 TO month DO
  BEGIN
    moveto(m*72-54+xmin,(ymin+ymax)DIV 2); turnto(0);
    FOR n:=1 TO divisions DO pie(round(360.0*data[m,n]/data[m,0]),30,n);
  END;
  waitkey(5);
  window(6,6,313,193); colormap(1,2,3,0); fillscreen(-1);
END;

PROCEDURE demo2;
VAR
  m: integer;
  demo2tab: ARRAY[0..120] OF integer;
BEGIN   { demo 2 }
  FOR m := 120 DOWNTO 0 DO demo2tab[m]:=round(sin(m/20)*sin(m/10)*50+100);
  waitkey(2);
  crtmode(4);
  rect320;
  pencolor(2);
  FOR m := 120 DOWNTO 0 DO circle(m*2+10,demo2tab[m],m DIV 3);
  IF KeyPressed THEN exit;
  waitkey(2);
  window(6,6,313,193);
  colormap(1,2,3,0);
  FOR m:=1 TO 4 DO
  BEGIN
    fillscreen(-1);
    IF KeyPressed THEN exit;
    waitkey(2);
  END;
END;

PROCEDURE demo3;
CONST
  demo3no3 = 73;
VAR
  m,n: integer;
  buf: ARRAY [1..2,-5..288] OF byte; { 2*(6+(64+3)mod 4*18) }
BEGIN   { demo 3 }
  waitkey(5);
  crtmode(4);
  rect(5,3,64,18);
  PPASGotoXY(1,23); write('  Poly'); getpic(buf[1],5,3,68,20);
  PPASGotoXY(1,23); write(' Pascal'); getpic(buf[2],5,3,68,20);
  crtmode(4);
  rect320;
  WHILE demo3no<demo3nomax DO calcdemo3; calcdemo3; { Compute rest of table }
  colormap(0,1,1,1);
  pencolor(-1);
  FOR m := 0 TO demo3nomax DO
  BEGIN
    putpic(buf[2],m+20,50-demo3tab[m]);
    IF KeyPressed THEN exit;
  END;
  waitkey(1);
  colormap(0,2,2,2);
  FOR m := 0 TO demo3nomax DO
  BEGIN
    putpic(buf[1],m+20,demo3tab[m]+68-1-m DIV 3+demo3no3);
    IF KeyPressed THEN exit;
  END;
  waitkey(3);
  window(6,6,313,193);
  colormap(1,2,3,0);
  FOR m:=1 TO 4 DO
  BEGIN
    palette(random(2));
    fillscreen(-1);
    IF KeyPressed THEN exit;
    waitkey(2);
  END;
END;

PROCEDURE demo4;
VAR
  m,n,x,y: integer;
  picbuf: ARRAY [-5..576] OF byte; { 6+(48+3)div 4*48 }
  kbdwait: integer;
  randtab: ARRAY [0..23] OF integer;
BEGIN   { demo 4 }
  waitkey(5);
  crtmode(4);
  rect(15,3,290,194); rect(13,1,294,198); rect(14,2,292,196);
  colormap(0,2,3,1);
  FOR kbdwait:=1 TO 10 DO
  BEGIN
    palette(random(2));
    pencolor(0);
    rectfill(135,75,185,125);
    m:=random(3)+1; pencolor(m);
    turnto(0);
    n:=random(30)+5;
    REPEAT
      moveto(160,100);
      arc(180,n);
      IF n<15 THEN turn(-10) ELSE turn(-6);
    UNTIL turtleang=0;
    pencolor(-1);
    window(135,75,185,125);
    REPEAT n:=random(3)+1 UNTIL n<>m;
    IF KeyPressed THEN exit;
    waitkey(1);
    paint(160,100,n,0);
    waitkey(1);
    getpic(picbuf,136,76,183,123);
    window(16,4,303,195);
    colormap(0,1,2,3);
    FOR x:=0 TO 23 DO randtab[x]:=x;
    FOR x:=0 TO 23 DO
    BEGIN
      m:=random(24); n:=random(24);
      y:=randtab[m]; randtab[m]:=randtab[n]; randtab[n]:=y;
    END;
    m:=random(4);
    FOR x:=0 TO 23 DO
    BEGIN
      IF m=0 THEN colormap(random(4),random(4),random(4),random(4));
      putpic(picbuf,(randtab[x] MOD 6)*48+16,(randtab[x] DIV 6)*48+4);
    END;
    IF KeyPressed THEN exit;
    waitkey(3);
  END;
END;

PROCEDURE demo5;
VAR
  xx: ARRAY [0..50] OF integer;
  yy: ARRAY [0..50] OF integer;
  n,up,down,downstep,upstep,pl,pc: integer;

PROCEDURE drawpic(down,up,downstep,upstep : integer);
VAR
  nr,y: integer;
BEGIN
  FOR nr:=1 TO 50 DO
  BEGIN
    y:=yy(.nr.);
    moveto(160,down); lineto(xx(.nr.),y); lineto(160,up);
    moveto(160,down); lineto(320-xx(.nr.),y); lineto(160,up);
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
  waitkey(1);
  crtmode(4);
  FOR pl:=0 TO 1 DO FOR pc:=1 TO 3 DO
  BEGIN
    palette(pl); pencolor(pc);
    down:=random(200); downstep:=random(10);
    up:=random(200); upstep:=-random(10);
    drawpic(down,up,downstep,upstep);
    IF pc=2 THEN
    BEGIN
      waitkey(1);
      paint(160,up,1,0);
      paint(160,down,1,0);
    END;
    IF KeyPressed THEN exit;
    waitkey(2);
    pencolor(0);
    drawpic(down,up,downstep,upstep);
  END;
END;

PROCEDURE demo6;
VAR
  i,j: integer;
BEGIN   { demo 6 }
  waitkey(5);
  crtmode(4);
  FOR j:=1 TO 45 DO
  BEGIN
    FOR i:=1 TO 3 DO
    BEGIN
      line(40); arc(360+120,20);
    END;
    turn(8);
    IF KeyPressed THEN exit;
  END;
  moveto(160,0); turnto(0);
  FOR j:=1 TO 24 DO
  BEGIN
    FOR i:=3 TO 8 DO
    BEGIN
      arc(360,i); arc(-360,i);
    END;
    arc (15,100);
    IF KeyPressed THEN exit;
  END;
  paint(160,20,2,3);
  paint(160,100,1,0);
END;

BEGIN   { Main program }
  demo3no:=0;
  REPEAT
    demo1; demo2; demo3; demo4; demo5; demo6;
  UNTIL false;
END.
