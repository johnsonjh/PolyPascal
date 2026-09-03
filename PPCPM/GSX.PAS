CONST
  maxintin  = 80;	{ Maximum number of input integers }
  maxptsin  = 4;	{ Maximum number of input points }
  maxintout = 80;	{ Maximum number of output integers }
  maxptsout = 2;	{ Maximum number of output points }

TYPE
  coor      = RECORD
		x,y: integer;
	      END;
  stringin  = STRING[maxintin];
  stringout = STRING[maxintout];

VAR
  contrl    : ARRAY[1..9] OF integer;
  intin     : ARRAY[1..maxintin] OF integer;
  ptsin     : ARRAY[1..maxptsin] OF coor;
  intout    : ARRAY[1..maxintout] OF integer;
  ptsout    : ARRAY[1..maxptsout] OF coor;
  wsintout  : ARRAY[1..45] OF integer;
  wsptsout  : ARRAY[1..6] OF coor;
  actual    : integer;

{$R-,K-}

PROCEDURE gsx(VAR ctrl,inti,ptsi,into,ptso);
TYPE
  gsxpb = RECORD
	    ctrlp,intip,ptsip,intop,ptsop: ^integer;
	  END;
  rpack = RECORD
	    ax,bx,cx,dx,bp,si,di,ds,es,flags: integer;
	  END;
VAR
  pb: gsxpb;
  rp: rpack;
BEGIN
  pb.ctrlp:=addr(ctrl);
  pb.intip:=addr(inti); pb.ptsip:=addr(ptsi);
  pb.intop:=addr(into); pb.ptsop:=addr(ptso);
  rp.cx:=$473; rp.dx:=ofs(pb); rp.ds:=seg(pb);
  swint(224,rp);
END;

PROCEDURE gsxc(func,npts,nint: integer);
BEGIN
  contrl[1]:=func; contrl[2]:=npts; contrl[4]:=nint;
  gsx(contrl,intin,ptsin,intout,ptsout);
END;

PROCEDURE gsxp(func,npts: integer; VAR ptsin);
BEGIN
  contrl[1]:=func; contrl[2]:=npts; contrl[4]:=0;
  gsx(contrl,intin,ptsin,intout,ptsout);
END;

PROCEDURE gsxi(func,value: integer);
BEGIN
  intin[1]:=value; gsxc(func,0,1); actual:=intout[1];
END;

PROCEDURE gsxx(func,value: integer);
BEGIN
  ptsin[1].x:=value; ptsin[1].y:=0;
  gsxc(func,1,0); actual:=ptsout[1].x;
END;

PROCEDURE gsxy(func,value: integer);
BEGIN
  ptsin[1].x:=0; ptsin[1].y:=value;
  gsxc(func,1,0); actual:=ptsout[1].y;
END;

PROCEDURE openws(id: integer);
CONST
  wsinti: ARRAY[2..10] OF integer = (1,1,1,1,1,1,1,1,1);
BEGIN
  intin[1]:=id; move(wsinti,intin[2],18);
  contrl[1]:=1; contrl[2]:=0; contrl[4]:=10;
  gsx(contrl,intin,ptsin,wsintout,wsptsout);
END;

PROCEDURE initws(VAR wsintin);
BEGIN
  contrl[1]:=1; contrl[2]:=0; contrl[4]:=10;
  gsx(contrl,wsintin,ptsin,wsintout,wsptsout);
END;

PROCEDURE closews;
BEGIN
  gsxc(2,0,0);
END;

PROCEDURE clearws;
BEGIN
  gsxc(3,0,0);
END;

PROCEDURE updatews;
BEGIN
  gsxc(4,0,0);
END;

PROCEDURE polyline(npts: integer; VAR ptsin);
BEGIN
  gsxp(6,npts,ptsin);
END;

PROCEDURE linetype(typ: integer);
BEGIN
  gsxi(15,typ);
END;

PROCEDURE linewidth(width: integer);
BEGIN
  gsxx(16,width);
END;

PROCEDURE polymark(npts: integer; VAR ptsin);
BEGIN
  gsxp(7,npts,ptsin);
END;

PROCEDURE marktype(typ: integer);
BEGIN
  gsxi(18,typ);
END;

PROCEDURE markscale(scale: integer);
BEGIN
  gsxy(19,scale);
END;

PROCEDURE bar(x1,y1,x2,y2: integer);
BEGIN
  contrl[6]:=1;
  ptsin[1].x:=x1; ptsin[1].y:=y1;
  ptsin[2].x:=x2; ptsin[2].y:=y2;
  gsxc(11,2,0);
END;

PROCEDURE arc(startang,endang,xctr,yctr,xstart,ystart,
  xend,yend,radius: integer);
BEGIN
  contrl[6]:=2;
  intin[1]:=startang; intin[2]:=endang;
  ptsin[1].x:=xctr; ptsin[1].y:=yctr;
  ptsin[2].x:=xstart; ptsin[2].y:=ystart;
  ptsin[3].x:=xend; ptsin[3].y:=yend;
  ptsin[4].x:=radius; ptsin[4].y:=0;
  gsxc(11,4,2);
END;

PROCEDURE pie(startang,endang,xctr,yctr,xstart,ystart,
  xend,yend,radius: integer);
BEGIN
  contrl[6]:=3;
  intin[1]:=startang; intin[2]:=endang;
  ptsin[1].x:=xctr; ptsin[1].y:=yctr;
  ptsin[2].x:=xstart; ptsin[2].y:=ystart;
  ptsin[3].x:=xend; ptsin[3].y:=yend;
  ptsin[4].x:=radius; ptsin[4].y:=0;
  gsxc(11,4,2);
END;

PROCEDURE circle(xctr,yctr,radius: integer);
BEGIN
  contrl[6]:=4;
  ptsin[1].x:=xctr; ptsin[1].y:=yctr;
  ptsin[2].x:=xctr+radius; ptsin[2].y:=yctr;
  ptsin[3].x:=radius; ptsin[3].y:=0;
  gsxc(11,3,0);
END;

PROCEDURE polyfill(npts: integer; VAR ptsin);
BEGIN
  gsxp(9,npts,ptsin);
END;

PROCEDURE cellarray(rowlen,width,height,mode: integer;
  x1,y1,x2,y2: integer; VAR colorindex);
BEGIN
  contrl[1]:=10; contrl[2]:=2; contrl[4]:=1;
  contrl[6]:=rowlen; contrl[7]:=width;
  contrl[8]:=height; contrl[9]:=mode;
  ptsin[1].x:=x1; ptsin[1].y:=y1;
  ptsin[2].x:=x2; ptsin[2].y:=y2;
  gsx(contrl,colorindex,ptsin,intout,ptsout);
END;

PROCEDURE filltype(typ: integer);
BEGIN
  gsxi(23,typ);
END;

PROCEDURE fillstyle(index: integer);
BEGIN
  gsxi(24,index);
END;

PROCEDURE gtext(x,y: integer; s: stringin);
VAR
  i: integer;
BEGIN
  FOR i:=1 TO len(s) DO intin[i]:=ord(s[i]);
  ptsin[1].x:=x; ptsin[1].y:=y; gsxc(8,1,len(s));
END;

PROCEDURE charheight(height: integer;
  VAR charw,charh,cellw,cellh: integer);
BEGIN
  gsxy(12,height);
  charw:=ptsout[1].x; charh:=ptsout[1].y;
  cellw:=ptsout[2].x; cellh:=ptsout[1].y;
END;

PROCEDURE charupvec(angle: integer);
CONST
  f1800 = 0.001745329252; (* PI/1800 *)
BEGIN
  intin[1]:=angle;
  intin[2]:=round(100.0*cos(angle*f1800));
  intin[3]:=round(100.0*sin(angle*f1800));
  gsxc(13,0,3); actual:=intout[1];
END;

PROCEDURE textfont(font: integer);
BEGIN
  gsxi(21,font);
END;

PROCEDURE setcolor(index,red,green,blue: integer);
BEGIN
  intin[1]:=index; intin[2]:=red;
  intin[3]:=green; intin[4]:=blue;
  gsxc(14,0,4);
END;

PROCEDURE linecolor(index: integer);
BEGIN
  gsxi(17,index);
END;

PROCEDURE markcolor(index: integer);
BEGIN
  gsxi(20,index);
END;

PROCEDURE textcolor(index: integer);
BEGIN
  gsxi(22,index);
END;

PROCEDURE fillcolor(index: integer);
BEGIN
  gsxi(25,index);
END;

PROCEDURE writemode(mode: integer);
BEGIN
  gsxi(32,mode);
END;

PROCEDURE inputmode(device,mode: integer);
BEGIN
  intin[1]:=device; intin[2]:=mode; gsxc(33,0,2);
END;

PROCEDURE rqlocator(device,xin,yin: integer;
  VAR status,term,xout,yout: integer);
BEGIN
  inputmode(1,1); intin[1]:=device;
  ptsin[1].x:=xin; ptsin[1].y:=yin;
  gsxc(28,1,1);
  status:=contrl[5]; term:=intout[1];
  xout:=ptsout[1].x; yout:=ptsout[1].y;
END;

PROCEDURE smlocator(device: integer;
  VAR status,xout,yout: integer);
BEGIN
  inputmode(1,2); intin[1]:=device;
  gsxc(28,0,1); status:=contrl[5];
  xout:=ptsout[1].x; yout:=ptsout[1].y;
END;

PROCEDURE rqvaluator(device,vin: integer;
  VAR status,vout: integer);
BEGIN
  inputmode(2,1); intin[1]:=device; intin[2]:=vin;
  gsxc(29,0,2); status:=contrl[5]; vout:=intout[1];
END;

PROCEDURE smvaluator(device: integer;
  VAR status,vout: integer);
BEGIN
  inputmode(2,2); intin[1]:=device;
  gsxc(29,0,1); status:=contrl[5]; vout:=intout[1];
END;

PROCEDURE rqchoice(device,cin: integer;
  VAR status,cout: integer);
BEGIN
  inputmode(3,1); intin[1]:=device; intin[2]:=cin;
  gsxc(30,0,2); status:=contrl[5]; cout:=intout[1];
END;

PROCEDURE smchoice(device: integer;
  VAR status,cout: integer);
BEGIN
  inputmode(3,2); intin[1]:=device;
  gsxc(30,0,1); status:=contrl[5]; cout:=intout[1];
END;

PROCEDURE rqstring(device,maxlen,mode: integer;
  VAR s: stringout);
VAR
  i: integer;
BEGIN
  inputmode(4,1); intin[1]:=device;
  intin[2]:=maxlen; intin[3]:=mode;
  gsxc(31,0,3); s[0]:=chr(intout[5]);
  FOR i:=1 TO contrl[5] DO s[i]:=chr(intout[i]);
END;

PROCEDURE inqcolor(rindex,flag: integer;
  VAR sindex,red,green,blue: integer);
BEGIN
  intin[1]:=rindex; intin[2]:=flag;
  gsxc(26,0,2);
  sindex:=intout[1]; red:=intout[2];
  green:=intout[3]; blue:=intout[4];
END;

PROCEDURE escp(func,npts,nint: integer);
BEGIN
  contrl[6]:=func; gsxc(5,npts,nint);
END;

PROCEDURE escn(func: integer);
BEGIN
  contrl[6]:=func; gsxc(5,0,0);
END;

PROCEDURE inqcells(VAR row,col: integer);
BEGIN
  escn(1); row:=intout[1]; col:=intout[2];
END;

PROCEDURE entergraf;
BEGIN escn(2); END;

PROCEDURE exitgraf;
BEGIN escn(3); END;

PROCEDURE cursorup;
BEGIN escn(4); END;

PROCEDURE cursordown;
BEGIN escn(5); END;

PROCEDURE cursorright;
BEGIN escn(6); END;

PROCEDURE cursorleft;
BEGIN escn(7); END;

PROCEDURE cursorhome;
BEGIN escn(8); END;

PROCEDURE eraeos;
BEGIN escn(9); END;

PROCEDURE eraeol;
BEGIN escn(10); END;

PROCEDURE cursor(row,col: integer);
BEGIN
  intin[1]:=row; intin[2]:=col; escp(11,0,2);
END;

PROCEDURE ctext(s: stringin);
VAR
  i: integer;
BEGIN
  FOR i:=1 TO len(s) DO intin[i]:=ord(s[i]);
  escp(12,0,len(s));
END;

PROCEDURE reverseon;
BEGIN escn(13); END;

PROCEDURE reverseoff;
BEGIN escn(14); END;

PROCEDURE inqcursor(VAR row,col: integer);
BEGIN
  escn(15); row:=intout[1]; col:=intout[2];
END;

PROCEDURE inqtablet(VAR status: integer);
BEGIN
  escn(16); status:=intout[1];
END;

PROCEDURE hardcopy;
BEGIN escn(17); END;

PROCEDURE gcursor(x,y: integer);
BEGIN
  ptsin[1].x:=x; ptsin[1].y:=y; escp(18,1,0);
END;

PROCEDURE remgcur;
BEGIN escn(19); END;
          