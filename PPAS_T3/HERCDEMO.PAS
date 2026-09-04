program hercdemo; {$C-,K-,R-}

{$I HERCULES}

const
  pat: array[0..2,0..7] of byte =
    (($03,$84,$48,$30,$30,$48,$84,$03),
     ($AA,$55,$AA,$55,$AA,$55,$AA,$55),
     ($44,$88,$11,$22,$44,$88,$11,$22));
  mon: array[0..5] of string[8] =
    ('January','February','March','April','May','June');

type
  grafpage = array[0..32767] of byte;

var
  i,j,x,y: integer;
  s: string[3];
  data: array[0..5,0..2] of integer;
  page1: grafpage at $B000:0;
  page2: grafpage at $B800:0;

procedure box(x1,y1,x2,y2: integer);
begin
  moveto(x1,y1); lineto(x1,y2); lineto(x2,y2);
  lineto(x2,y1); lineto(x1,y1);
end;

procedure bar(x1,y1,x2,y2,s: integer);
begin
  box(x1,y1,x2,y2); pattern(pat[s]);
  rectfill(x1+1,y1+1,x2-1,y2-1);
end;

begin
  grafmode(2); chartype(2);
  for i:=0 to 5 do for j:=0 to 2 do
  data[i,j]:=50+random(200);
  box(0,0,719,347); box(1,1,718,346); box(2,2,717,345);
  moveto(248,15); grafwrite(' Turnover 1st Six Months ');
  moveto(249,15); grafwrite(' Turnover 1st Six Months ');
  for i:=0 to 10 do
  begin
    y:=i*25+40; moveto(55,y); lineto(685,y);
  end;
  moveto(55,40); lineto(55,290);
  moveto(685,40); lineto(685,290);
  for i:=0 to 10 do
  begin
    str(100-i*10:3,s); moveto(21,i*25+34); grafwrite(s);
  end;
  moveto(12,15); grafwrite('$1000');
  for i:=0 to 5 do
  begin
    moveto(i*105+108-len(mon[i])*9 div 2,294);
    grafwrite(mon[i]);
  end;
  for j:=0 to 2 do for i:=0 to 5 do
  begin
    x:=i*105+j*30+65; y:=data[i,j];
    bar(x,290-y,x+26,290,j);
  end;
  moveto(190,317);
  grafwrite('Division:      North      East      West');
  bar(289,314,314,332,0);
  bar(388,314,413,332,1);
  bar(478,314,503,332,2);
  page2:=page1; workpage(2);
  window(5,5,714,342); fillscreen(2);
  readln;
  disppage(2);
  readln;
  textmode;
end.
