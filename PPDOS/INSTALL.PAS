PROGRAM install; {$K-,R-}

CONST
  maxterm = 40;

TYPE
  str2    = STRING[2];
  str3    = STRING[3];
  str4    = STRING[4];
  str5    = STRING[5];
  str8    = STRING[8];
  str12   = STRING[12];
  str24   = STRING[24];
  str31   = STRING[31];
  str36   = STRING[36];
  str48   = STRING[48];
  str64   = STRING[64];
  charset = SET OF char;
  datarec = RECORD
              f1: byte;
              edofs,pstwd: integer;
              f2: ARRAY[1..27] OF byte;
              termname: str31;
              width,height: byte;
              gxyls: str8;
              gxyss,gxyts: str4;
              colblin,coorofs,coorfmt: byte;
              clhs,cess,cels,ilns,dlns,rons,rofs,
              ions,iofs,uons,uofs,bons,bofs,aofs: str8;
              txtatb,slnatb,tlnatb,erratb,
              ovfatb,blkatm,ctlatm: byte;
              f3: ARRAY[1..22] OF byte;
              vdws: integer;
              f4: ARRAY[1..644] OF byte;
              rdelay: integer;
              altkey: ARRAY[0..255] OF byte;
              xstep,backf,insmf,autof,tabsf,errmod: byte;
              hlpstr,ermstr,wrkstr: str31;
              pasext,bakext,comext,chnext: str4;
            END;
  pdatrec = ARRAY[1..1115] OF byte;

VAR
  cf,hf: FILE;
  tf: FILE OF str31;
  df: FILE OF pdatrec;
  cfn: str64;
  data: datarec;
  tnam: ARRAY[1..maxterm] OF str31;
  i: integer;
  insfile: boolean;
  ch: char;

PROCEDURE errhand(errno,errofs: integer);
BEGIN
  IF errno=1 THEN
  BEGIN
    writeln('^C'); halt(1);
  END;
END;

FUNCTION upcase(s: str24): str24;
VAR
  i: integer;
  u: str24;
BEGIN
  u:='';
  FOR i:=1 TO len(s) DO
  IF (s[i]>='a') AND (s[i]<='z') THEN
  u:=u+chr(ord(s[i])-32) ELSE u:=u+s[i];
  upcase:=u;
END;

FUNCTION hex(number,digits: integer): str4;
CONST
  hexdigits: ARRAY[0..15] OF char = '0123456789ABCDEF';
VAR
  d: integer;
  h: str4;
BEGIN
  h[0]:=chr(digits);
  FOR d:=digits DOWNTO 1 DO
  BEGIN
    h[d]:=hexdigits[number AND 15];
    number:=number SHR 4;
  END;
  hex:=h;
END;

FUNCTION hexseq(seq: str8): str24;
VAR
  i: integer;
  s: str24;
BEGIN
  IF seq='' THEN hexseq:='Unconfigured' ELSE
  BEGIN
    s:='';
    FOR i:=1 TO len(seq) DO s:=s+hex(ord(seq[i]),2)+' ';
    hexseq:=copy(s,1,len(s)-1);
  END;
END;

FUNCTION yesno(flag: integer): str4;
BEGIN
  IF flag<>0 THEN yesno:='YES' ELSE yesno:='NO';
END;

PROCEDURE backsp(n: integer);
VAR
  i: integer;
BEGIN
  FOR i:=1 TO n DO write(^H' '^H);
END;

FUNCTION readnum(min,max: integer): integer;
VAR
  n,p: integer;
  ok: boolean;
  s: str5;
BEGIN
  REPEAT
    buflen:=5; read(s);
    IF s='' THEN ok:=false ELSE
    BEGIN
      val(s,n,p);
      ok:=(p=0) AND (n>=min) AND (n<=max);
    END;
    IF NOT ok THEN backsp(len(s));
  UNTIL ok;
  writeln; readnum:=n;
END;

FUNCTION readseq(maxlen: integer): str8;
CONST
  hexdigits: SET OF '0'..'f' = ['0'..'9','A'..'F','a'..'f'];
VAR
  h,i,n,p: integer;
  error: boolean;
  seq: str8;
  s: str24;
BEGIN
  REPEAT
    buflen:=maxlen*3-1; read(s); s:=s+^M;
    error:=false; p:=1; n:=0;
    REPEAT
      WHILE s[p]=' ' DO p:=succ(p);
      IF s[p]=^M THEN i:=0 ELSE
      BEGIN
        i:=p; WHILE NOT(s[p] IN [' ',^M]) DO p:=succ(p);
        val('$'+copy(s,i,p-i),h,i);
        n:=succ(n); seq[n]:=chr(h);
      END;
    UNTIL (s[p]=^M) OR (i<>0);
    IF i<>0 THEN backsp(len(s)-1);
  UNTIL i=0;
  seq[0]:=chr(n); writeln;
  readseq:=seq;
END;

FUNCTION readyn: integer;
VAR
  s: str4;
BEGIN
  REPEAT
    buflen:=3; read(s); s:=upcase(s);
    IF (s<>'YES') AND (s<>'NO') THEN backsp(len(s));
  UNTIL (s='YES') OR (s='NO');
  IF s='YES' THEN readyn:=255 ELSE readyn:=0;
  writeln;
END;

FUNCTION select(prompt: str48; okch: charset): char;
VAR
  ch: char;
BEGIN
  write(prompt,': ');
  REPEAT
    read(kbd,ch);
    IF (ch>='a') AND (ch<='z') THEN ch:=chr(ord(ch)-32);
  UNTIL ch IN okch;
  IF ch=^M THEN backsp(len(prompt)+2) ELSE
  BEGIN
    writeln(ch); writeln;
  END;
  select:=ch;
END;

PROCEDURE pressreturn;
VAR
  ch: char;
BEGIN
  write('Press RETURN...');
  REPEAT read(kbd,ch) UNTIL ch=^M;
  backsp(15);
END;

PROCEDURE clear1;
BEGIN
  fill(data.termname,$359,0);
  WITH data DO
  BEGIN
    width:=79; height:=24; gxyls:=@27'='; coorofs:=32;
    clhs:=@26; slnatb:=1; tlnatb:=2; ovfatb:=2; erratb:=2;
    blkatm:=2; ctlatm:=1;
  END;
END;

PROCEDURE clear2;
BEGIN
  fill(data.rdelay,$17C,0);
  WITH data DO
  BEGIN
    rdelay:=1000; xstep:=16; backf:=255;
    insmf:=255; autof:=255; errmod:=2; hlpstr:='PPAS.HLP';
    ermstr:='PPAS.ERM'; wrkstr:='WORK.PAS'; pasext:='.PAS';
    bakext:='.BAK'; comext:='.COM'; chnext:='.CHN';
  END;
END;

PROCEDURE configure;
VAR
  ch: char;

PROCEDURE crt;
CONST
  pa1: str36 = 'A. Screen width (in characters)...: ';
  pb1: str36 = 'B. Screen height (in lines).......: ';
  pc1: str36 = 'C. GOTOXY lead-in sequence........: ';
  pd1: str36 = 'D. GOTOXY separator sequence......: ';
  pe1: str36 = 'E. GOTOXY terminator sequence.....: ';
  pf1: str36 = 'F. Line before column (YES/NO)....: ';
  pg1: str36 = 'G. Coordinate offset..............: ';
  ph1: str36 = 'H. Coordinate format (0/2/3)......: ';
  pa2: str36 = 'A. CLRHOM sequence................: ';
  pb2: str36 = 'B. CLREOS sequence................: ';
  pc2: str36 = 'C. CLREOL sequence................: ';
  pd2: str36 = 'D. INSLIN sequence................: ';
  pe2: str36 = 'E. DELLIN sequence................: ';
  pa3: str36 = 'A. RVSON sequence.................: ';
  pb3: str36 = 'B. RVSOFF sequence................: ';
  pc3: str36 = 'C. INTON sequence.................: ';
  pd3: str36 = 'D. INTOFF sequence................: ';
  pe3: str36 = 'E. ULNON sequence.................: ';
  pf3: str36 = 'F. ULNOFF sequence................: ';
  pg3: str36 = 'G. BLKON sequence.................: ';
  ph3: str36 = 'H. BLKOFF sequence................: ';
  pi3: str36 = 'I. ALLOFF sequence................: ';

VAR
  sec: integer;
  ch,mc,first,last: char;

PROCEDURE help1;
BEGIN
  writeln('All  fields  on this submenu must be filled in for PolyPascal  to');
  writeln('operate correctly.');
  writeln;
  writeln('SCREEN WIDTH.  This  field defines the number of  characters  per');
  writeln('line  on your video display.  If the display scrolls when writing');
  writeln('to the bottom right character position,  then specify the  screen');
  writeln('width less one.');
  writeln;
  writeln('SCREEN HEIGHT.  This  field defines the number of lines  on  your');
  writeln('video display. Always specify the exact value.');
  writeln;
  writeln('Character  sequences are entered as sequences of hex values  bet-');
  writeln('ween  00 and FF.  Each hex value must be separated from the  sur-');
  writeln('rounding ones by at least one blank.  To enter an empty sequence,');
  writeln('simply enter a blank line.');
  writeln;
  writeln('GOTOXY LEAD-IN SEQUENCE. The character sequence sent prior to the');
  writeln('coordinates. The maximum length is 8.');
  writeln;
  pressreturn;
  writeln('GOTOXY SEPARATOR SEQUENCE.  The character sequence  sent  between');
  writeln('the coordinates. The maximum length is 4.');
  writeln;
  writeln('GOTOXY TERMINATOR SEQUENCE. The character sequence sent after the');
  writeln('coordinates. The maximum length is 4.');
  writeln;
  writeln('LINE BEFORE COLUMN. This field should be set to YES if your video');
  writeln('display  requires  the line coordinate (Y) to be sent before  the');
  writeln('column coordinate (X). Otherwise it should be set to NO.');
  writeln;
  writeln('COORDINATE OFFSET.  This field defines the value (in decimal)  to');
  writeln('be  added to the coordinates before they are transmitted.  If the');
  writeln('coordinate format (see below) is 0,  then 32 is normally used. If');
  writeln('the coordinate format is 2 or 3, then 0 or 1 is normally used.');
  writeln;
  writeln('COORDINATE FORMAT.  A value of 0 in this field indicates that the');
  writeln('coordinates  are  to be transmitted as single bytes using  binary');
  writeln('format.  Other values (2 or 3) indicate that the coordinates  are');
  writeln('to  be transmitted as decimal character strings of 2 or 3 charac-');
  writeln('ters.');
  writeln;
  pressreturn;
END;

PROCEDURE help2;
BEGIN
  writeln('CLRHOM SEQUENCE.  The  function sequence which clears the  screen');
  writeln('and returns the cursor to the top left corner.  The maximum is 8.');
  writeln('This  function  sequence must be specified for PolyPascal to ope-');
  writeln('rate correctly.');
  writeln;
  writeln('All of the following function sequences are optional. The maximum');
  writeln('length is 8 for all sequences.');
  writeln;
  writeln('CLREOS SEQUENCE. The function sequence which clears all character');
  writeln('positions from the cursor to the end of the screen.');
  writeln;
  writeln('CLREOL SEQUENCE. The function sequence which clears all character');
  writeln('positions from the cursor to the end of the current line.');
  writeln;
  writeln('INSLIN SEQUENCE.  The function sequence which scrolls the current');
  writeln('line, and all lines below it, down, and clears the current line.');
  writeln;
  writeln('DELLIN SEQUENCE.  The function sequence which deletes the current');
  writeln('line,  and  scrolls up all lines below it,  with a blank line ap-');
  writeln('pearing at the bottom. The maximum length is 8.');
  writeln;
  pressreturn;
END;

PROCEDURE help3;
BEGIN
  writeln('All of the following function sequences are optional. The maximum');
  writeln('length is 8 for all sequences.');
  writeln;
  writeln('RVSON SEQUENCE. Turns on reverse video.');
  writeln;
  writeln('RVSOFF SEQUENCE. Turns off reverse video.');
  writeln;
  writeln('INTON SEQUENCE. Turns on increased/decreased intensity.');
  writeln;
  writeln('INTOFF SEQUENCE. Turns off increased/decreased intensity.');
  writeln;
  writeln('ULNON SEQUENCE. Turns on underlining.');
  writeln;
  writeln('ULNOFF SEQUENCE. Turns off underlining.');
  writeln;
  writeln('BLKON SEQUENCE. Turns on character blink.');
  writeln;
  writeln('BLKOFF SEQUENCE. Turns off character blink.');
  writeln;
  writeln('ALLOFF SEQUENCE. Turns off all character attributes.');
  writeln;
  pressreturn;
END;

BEGIN {crt}
  sec:=1;
  WITH data DO
  REPEAT
    writeln('CRT CONFIGURATION TABLE (SECTION ',sec,'):');
    writeln;
    CASE sec OF
      1: BEGIN
           writeln(pa1,width);
           writeln(pb1,height);
           writeln(pc1,hexseq(gxyls));
           writeln(pd1,hexseq(gxyss));
           writeln(pe1,hexseq(gxyts));
           writeln(pf1,yesno(255-colblin));
           writeln(pg1,coorofs);
           writeln(ph1,coorfmt);
           mc:='H';
         END;
      2: BEGIN
           writeln(pa2,hexseq(clhs));
           writeln(pb2,hexseq(cess));
           writeln(pc2,hexseq(cels));
           writeln(pd2,hexseq(ilns));
           writeln(pe2,hexseq(dlns));
           mc:='E';
         END;
      3: BEGIN
           writeln(pa3,hexseq(rons));
           writeln(pb3,hexseq(rofs));
           writeln(pc3,hexseq(ions));
           writeln(pd3,hexseq(iofs));
           writeln(pe3,hexseq(uons));
           writeln(pf3,hexseq(uofs));
           writeln(pg3,hexseq(bons));
           writeln(ph3,hexseq(bofs));
           writeln(pi3,hexseq(aofs));
           mc:='I';
         END;
    END;
    writeln;
    writeln('Press RETURN to view more');
    writeln;
    ch:=select('Edit(A-'+mc+'), All(Z), Exit(X), Help(Y)',
      ['A'..mc,'Z','X','Y',^M]);
    IF ch=^M THEN
    IF sec=3 THEN sec:=1 ELSE sec:=sec+1 ELSE
    BEGIN
      IF ch='Z' THEN
      BEGIN
        first:='A'; last:=mc;
      END ELSE
      BEGIN
        first:=ch; last:=ch;
      END;
      FOR ch:=first TO last DO
      CASE sec OF
        1: CASE ch OF
             'A': BEGIN
                    write(pa1); width:=readnum(40,255);
                  END;
             'B': BEGIN
                    write(pb1); height:=readnum(8,255);
                  END;
             'C': BEGIN
                    write(pc1); gxyls:=readseq(8);
                  END;
             'D': BEGIN
                    write(pd1); gxyss:=readseq(4);
                  END;
             'E': BEGIN
                    write(pe1); gxyts:=readseq(4);
                  END;
             'F': BEGIN
                    write(pf1); colblin:=255-readyn;
                  END;
             'G': BEGIN
                    write(pg1); coorofs:=readnum(0,255);
                  END;
             'H': BEGIN
                    write(ph1); coorfmt:=readnum(0,3);
                  END;
             'Y': help1;
           END;
        2: CASE ch OF
             'A': BEGIN
                    write(pa2); clhs:=readseq(8);
                  END;
             'B': BEGIN
                    write(pb2); cess:=readseq(8);
                  END;
             'C': BEGIN
                    write(pc2); cels:=readseq(8);
                  END;
             'D': BEGIN
                    write(pd2); ilns:=readseq(8);
                  END;
             'E': BEGIN
                    write(pe2); dlns:=readseq(8);
                  END;
             'Y': help2;
           END;
        3: CASE ch OF
             'A': BEGIN
                    write(pa3); rons:=readseq(8);
                  END;
             'B': BEGIN
                    write(pb3); rofs:=readseq(8);
                  END;
             'C': BEGIN
                    write(pc3); ions:=readseq(8);
                  END;
             'D': BEGIN
                    write(pd3); iofs:=readseq(8);
                  END;
             'E': BEGIN
                    write(pe3); uons:=readseq(8);
                  END;
             'F': BEGIN
                    write(pf3); uofs:=readseq(8);
                  END;
             'G': BEGIN
                    write(pg3); bons:=readseq(8);
                  END;
             'H': BEGIN
                    write(ph3); bofs:=readseq(8);
                  END;
             'I': BEGIN
                    write(pi3); aofs:=readseq(8);
                  END;
             'Y': help3;
           END;
      END;
      IF ch IN ['A'..mc] THEN writeln;
    END;
  UNTIL ch='X';
END;

PROCEDURE keyboard;
TYPE
  keyrec = RECORD
             val: byte; str: str12;
           END;
CONST
  stdkey: ARRAY[1..43] OF str2 = (
    ^J,^S,^D,^A,^F,^Q^S,^Q^D,^E,^X,^Q^E,^Q^X,^R,^C,^Q^R,^Q^C,
    ^H,^G,^Q^H,^Q^Y,^T,^Y,^M,^I,^N,^P,^V,^Z,^B,^W,^Q^F,^Q^A,
    ^L,^K^B,^K^K,^K^Y,^K^C,^K^V,^K^P,^K^R,^K^W,^K^H,^K^D,^K^X);
VAR
  c,i,n,m: integer;
  ch,mc: char;
  s: str12;
  akey: ARRAY[1..50] OF keyrec;

FUNCTION keystr(ch: char): str3;
BEGIN
  CASE ch OF
    @32..@126,@128..@255: keystr:='"'+ch+'"';
    @8: keystr:='BS';
    @13: keystr:='CR';
    @27: keystr:='ESC';
    @127: keystr:='DEL';
  OTHERWISE
    keystr:='^'+chr(ord(ch)+64);
  END;
END;

FUNCTION keyseq(ks: str12): str48;
VAR
  i: integer;
  s: str48;
BEGIN
  s:='';
  FOR i:=1 TO len(ks) DO s:=s+keystr(ks[i])+' ';
  keyseq:=copy(s,1,len(s)-1);
END;

PROCEDURE delakey(i: integer);
VAR
  p: integer;
BEGIN
  FOR p:=i+1 TO n DO akey[p-1]:=akey[p]; n:=n-1;
END;

PROCEDURE addakey;
VAR
  i,sl: integer;
  ch: char;
  s: str12;
BEGIN
  sl:=0; FOR i:=1 TO n DO sl:=sl+len(akey[n].str)+2;
  IF (n=50) OR (sl>240) THEN
  writeln('No room for further definitions') ELSE
  BEGIN
    cbreak:=false; write('Standard: ');
    REPEAT
      read(kbd,ch);
      i:=1; WHILE (i<43) AND (ch<>stdkey[i][1]) DO i:=i+1;
      IF stdkey[i][1]=ch THEN
      BEGIN
        s:=ch; write(keyseq(ch),' '); sl:=len(keyseq(ch))+1;
        IF len(stdkey[i])=2 THEN
        BEGIN
          read(kbd,ch); s:=s+ch;
          i:=1; WHILE (i<43) AND (s<>stdkey[i]) DO i:=i+1;
          IF s=stdkey[i] THEN
          BEGIN
            s:=s+ch; write(keyseq(ch),' '); sl:=sl+len(keyseq(ch))+1;
          END ELSE
          BEGIN
            s:=''; backsp(sl);
          END;
        END;
      END ELSE s:='';
    UNTIL s<>'';
    write('':9-sl,'Alternate: ');
    s:='';
    REPEAT
      read(kbd,ch);
      IF (len(s)<12) AND (ch<>^M) THEN
      BEGIN
        IF len(s)>=1 THEN
        IF ch IN [^A..^Z] THEN ch:=chr(ord(ch)+64) ELSE
        IF ch IN ['a'..'z'] THEN ch:=chr(ord(ch)-32);
        write(keystr(ch),' '); s:=s+ch;
      END;
    UNTIL ch=^M;
    n:=n+1; akey[n].val:=i; akey[n].str:=s;
    writeln; cbreak:=true;
  END;
  writeln;
END;

PROCEDURE help;
BEGIN
  writeln('To be able to benefit fully from the special keys offered by your');
  writeln('keyboard,  PolyPascal allows you to define alternate keys to  in-');
  writeln('voke  selected editor functions.  A typical example  of alternate');
  writeln('keys is defining your  cursor arrows to do the same as ^S, ^D, ^E');
  writeln('and ^X.');
  writeln;
  writeln('To  add  an alternate key definition,  you must first select  the');
  writeln('function for which you want to create an alternative. This you do');
  writeln('by entering the standard key sequence,  i.e.  the sequence listed');
  writeln('in  the manual.  Once you have selected a function,  you will  be');
  writeln('prompted for an alternate key sequence,  to which you must answer');
  writeln('by entering the alternate sequence.  To end the alternate sequen-');
  writeln('ce, press RETURN.');
  writeln;
  writeln('Note  that it is actually possible to override the  standard  key');
  writeln('sequences.  If  you for instance define ^J to be an alternate key');
  writeln('for the ^X function,  the original ^J function will become  inac-');
  writeln('cessible unless you define an alternate sequence for it as well.');
  writeln;
  pressreturn;
END;

BEGIN {keyboard}
  WITH data DO
  BEGIN
    i:=0; n:=0; c:=1;
    WHILE altkey[i]<>0 DO
    BEGIN
      n:=n+1;
      move(altkey[i],akey[n],altkey[i+1]+2);
      i:=i+altkey[i+1]+2;
    END;
    REPEAT
      writeln('ALTERNATE KEY DEFINITIONS:');
      writeln;
      IF n=0 THEN
      BEGIN
        writeln('No alternate keys defined'); writeln;
        ch:=select('Add(Z), Exit(X), Help(Y)',['Z','X','Y']);
      END ELSE
      BEGIN
        IF c+9>n THEN m:=n-c ELSE m:=9;
        FOR i:=0 TO m DO
        BEGIN
          s:=keyseq(stdkey[akey[c+i].val]);
          write(chr(i+65),'. Standard: ',s,'':9-len(s));
          writeln('Alternate: ',keyseq(akey[c+i].str));
        END;
        IF n>10 THEN
        BEGIN
          writeln; writeln('Press RETURN to view more');
        END;
        writeln;
        mc:=chr(m+65);
        ch:=select('Delete(A-'+mc+'), Add(Z), Exit(X), Help(Y)',
          ['A'..mc,'Z','X','Y',^M]);
      END;
      CASE ch OF
        'A'..'J': BEGIN
                    delakey(c+ord(ch)-65);
                    IF (n>0) and (c>n) THEN c:=c-10;
                  END;
        'Z': BEGIN
               addakey; c:=n-((n-1) MOD 10);
             END;
        'Y': help;
        ^M: BEGIN
              c:=c+10; IF c>n THEN c:=1;
            END;
      END;
    UNTIL ch='X';
    i:=0;
    FOR n:=1 TO n DO
    BEGIN
      move(akey[n],altkey[i],len(akey[n].str)+2);
      i:=i+len(akey[n].str)+2;
    END;
    fill(altkey[i],256-i,0);
  END;
END;

PROCEDURE editor;
CONST
  pa1: str36 = 'A. Insert mode on (YES/NO)........: ';
  pb1: str36 = 'B. Auto-indent on (YES/NO)........: ';
  pc1: str36 = 'C. Taulate mode on (YES/NO).......: ';
  pd1: str36 = 'D. Replace prompt delay...........: ';
  pe1: str36 = 'E. Side scroll step value.........: ';
  pa2: str36 = 'A. Text attributes................: ';
  pb2: str36 = 'B. Status line attributes.........: ';
  pc2: str36 = 'C. Prompt line attributes.........: ';
  pd2: str36 = 'D. Error message attributes.......: ';
  pe2: str36 = 'E. Overflow marker attributes.....: ';
  pf2: str36 = 'F. Block attributes...............: ';
  pg2: str36 = 'G. Control character attributes...: ';

VAR
  sec: integer;
  ch,mc,first,last: char;

FUNCTION attrs(atb: integer): str4;
CONST
  atbch: ARRAY[0..3] OF char = 'RIUB';
VAR
  i: integer;
  s: str4;
BEGIN
  IF data.vdws<>0 THEN attrs:=hex(atb,2) ELSE
  BEGIN
    s:='';
    FOR i:=0 TO 3 DO
    IF atb AND (1 SHL i)<>0 THEN s:=s+atbch[i];
    attrs:=s;
  END;
END;

FUNCTION readatb: integer;
VAR
  a,i,p: integer;
  error: boolean;
  s: str4;
BEGIN
  REPEAT
    IF data.vdws<>0 THEN
    BEGIN
      buflen:=2; read(s); val('$'+s,a,i); error:=i<>0;
    END ELSE
    BEGIN
      buflen:=4; read(s); s:=upcase(s); a:=0; error:=false;
      FOR i:=1 TO len(s) DO
      BEGIN
        p:=pos(s[i],'RIUB');
        IF p<>0 THEN a:=a OR (1 SHL (p-1)) ELSE error:=true;
      END;
    END;
    IF error THEN backsp(len(s));
  UNTIL NOT error;
  writeln; readatb:=a;
END;

PROCEDURE help1;
BEGIN
  writeln('INSERT MODE ON.  This  field defined the  initial  state  of  the');
  writeln('insert mode (INS) when PolyPascal is started.');
  writeln;
  writeln('AUTO-INDENT ON. This field defines the initial state of the auto-');
  writeln('indent tabulator (AUT) when PolyPascal is started.');
  writeln;
  writeln('TABS MODE ON. This field defines the initial state of the tabula-');
  writeln('tor mode (TAB) when PolyPascal is started.');
  writeln;
  writeln('REPLACE PROMPT DELAY. This field is used only by the find/replace');
  writeln('function in the editor. It defines the delay used when moving the');
  writeln('cursor  alternately  between  the replace prompt  and  the  text.');
  writeln('Experiment  to find a suitable value (typical values  range  from');
  writeln('200 to 2000).');
  writeln;
  writeln('SIDE SCROLL STEP VALUE.  This field defines the step size used by');
  writeln('the editor when it scrolls sidewards.  The minimum value is 1 and');
  writeln('the maximum value is the screen width less one.');
  writeln;
  pressreturn;
END;

PROCEDURE help2;
BEGIN
  writeln('The  fields  that follow define the character attributes used  to');
  writeln('display  different kinds of text on the  screen.  Four  character');
  writeln('attributes are supported:  Reverse (R),  Intensity (I), Underline');
  writeln('(U) and Blink (B).  If,  for instance, the string "IU" is entered');
  writeln('in  the PROMPT LINE ATTRIBUTES field,  then prompt lines will  be');
  writeln('intensified  and underlined.  The function sequences required  to');
  writeln('turn  the attributes on and off are installed in the CRT configu-');
  writeln('ration table.');
  writeln;
  writeln('TEXT ATTRIBUTES. The attributes used for ordinary text.');
  writeln;
  writeln('STATUS LINE ATTRIBUTES. The attributes used for the status line.');
  writeln;
  writeln('PROMPT LINE ATTRIBUTES. The attributes used for prompt lines.');
  writeln;
  writeln('ERROR MESSAGE ATTRIBUTES.  The  attributes  used  for  displaying');
  writeln('error messages.');
  writeln;
  writeln('OVERFLOW MARKER ATTRIBUTES.  The attributes used for displaying a');
  writeln('"+" at the end of lines that are wider than the screen.');
  writeln;
  pressreturn;
  writeln('BLOCK ATTRIBUTES. The attributes listed in this field are not the');
  writeln('actual attributes used,  but instead they indicate the attributes');
  writeln('to flip (invert) when displaying text within a marked block.  If,');
  writeln('for  instance,  the  TEXT ATTRIBUTES field is set to "I" and  the');
  writeln('BLOCK ATTRIBUTES field is set to "IR", then blocks will appear in');
  writeln('reverse,  but not intensified,  since the intensify (I) attribute');
  writeln('is switched from on to off.');
  writeln;
  writeln('CONTROL CHARACTER ATTRIBUTES.  The  attributes to  flip  (invert)');
  writeln('when displaying control characters.');
  writeln;
  pressreturn;
END;

PROCEDURE help3;
BEGIN
  writeln('The attribute fields define the character attributes used to dis-');
  writeln('play  different kinds of text on the screen.  Since  the  current');
  writeln('configuration  has a customized machine code driver installed  to');
  writeln('do  high-speed  output  of characters to the screen,  each  field');
  writeln('contains a byte value,  which is passed on to the driver with  no');
  writeln('interpretation.  The  attribute values are displayed and  entered');
  writeln('in hex. For further details, please refer to the INSTALL.DOC text');
  writeln('file on the distribution disk.');
  writeln;
  pressreturn;
END;

BEGIN {editor}
  sec:=1;
  WITH data DO
  REPEAT
    writeln('EDITOR CONFIGURATION TABLE (SECTION ',sec,'):');
    writeln;
    CASE sec OF
      1: BEGIN
           writeln(pa1,yesno(insmf));
           writeln(pb1,yesno(autof));
           writeln(pc1,yesno(tabsf));
           writeln(pd1,rdelay);
           writeln(pe1,xstep);
           mc:='E';
         END;
      2: BEGIN
           writeln(pa2,attrs(txtatb));
           writeln(pb2,attrs(slnatb));
           writeln(pc2,attrs(tlnatb));
           writeln(pd2,attrs(erratb));
           writeln(pe2,attrs(ovfatb));
           writeln(pf2,attrs(blkatm));
           writeln(pg2,attrs(ctlatm));
           mc:='G';
         END;
    END;
    writeln;
    writeln('Press RETURN to view more');
    writeln;
    ch:=select('Edit(A-'+mc+'), All(Z), Exit(X), Help(Y)',
      ['A'..mc,'Z','X','Y',^M]);
    IF ch=^M THEN sec:=3-sec ELSE
    BEGIN
      IF ch='Z' THEN
      BEGIN
        first:='A'; last:=mc;
      END ELSE
      BEGIN
        first:=ch; last:=ch;
      END;
      FOR ch:=first TO last DO
      CASE sec OF
        1: CASE ch OF
             'A': BEGIN
                    write(pa1); insmf:=readyn;
                  END;
             'B': BEGIN
                    write(pb1); autof:=readyn;
                  END;
             'C': BEGIN
                    write(pc1); tabsf:=readyn;
                  END;
             'D': BEGIN
                    write(pd1); rdelay:=readnum(0,32767);
                  END;
             'E': BEGIN
                    write(pe1); xstep:=readnum(1,pred(width));
                  END;
             'Y': help1;
           END;
        2: CASE ch OF
             'A': BEGIN
                    write(pa2); txtatb:=readatb;
                  END;
             'B': BEGIN
                    write(pb2); slnatb:=readatb;
                  END;
             'C': BEGIN
                    write(pc2); tlnatb:=readatb;
                  END;
             'D': BEGIN
                    write(pd2); erratb:=readatb;
                  END;
             'E': BEGIN
                    write(pe2); ovfatb:=readatb;
                  END;
             'F': BEGIN
                    write(pf2); blkatm:=readatb;
                  END;
             'G': BEGIN
                    write(pg2); ctlatm:=readatb;
                  END;
             'Y': IF vdws=0 THEN help2 ELSE help3;
           END;
      END;
      IF ch IN ['A'..mc] THEN writeln;
    END;
  UNTIL ch='X';
END;

PROCEDURE misc;
CONST
  pa: str36 = 'A. Use backup files (YES/NO)......: ';
  pb: str36 = 'B. Error message mode (0/1/2).....: ';
  pc: str36 = 'C. Help file name.................: ';
  pd: str36 = 'D. Error message file name........: ';
  pe: str36 = 'E. Default workfile name..........: ';
  pf: str36 = 'F. Default text file type.........: ';
  pg: str36 = 'G. Default backup file type.......: ';
  ph: str36 = 'H. Default program file type......: ';
  pi: str36 = 'I. Default object file type.......: ';
  pj: str36 = 'J. Configuration name.............: ';

VAR
  ch: char;

PROCEDURE readfn(VAR fn: str31);
BEGIN
  buflen:=31; readln(fn); fn:=upcase(fn);
END;

PROCEDURE readext(VAR ext: str4);
BEGIN
  buflen:=3; readln(ext);
  IF ext<>'' THEN ext:='.'+upcase(ext);
END;

PROCEDURE help;
BEGIN
  writeln('USE BAK FILES.  This field must be either YES or NO. If it is set');
  writeln('to YES,  duplicate files will have their type changed to BAK when');
  writeln('the SAVE command is used to save a file.  Otherwise,  such  files');
  writeln('are simply deleted.');
  writeln;
  writeln('ERROR MESSAGE MODE.  The error message mode can be either 0, 1 or');
  writeln('2.  0 means that the error message file should never be loaded. 1');
  writeln('means  that the error message file should only be loaded  if  the');
  writeln('user  confirms it (by answering yes to the prompt when PolyPascal');
  writeln('is  started),  and  2 means that the error  message  file  should');
  writeln('always  be  loaded.  If the error message file is not loaded  the');
  writeln('compiler will output only error numbers and not messages.');
  writeln;
  writeln('HELP FILE NAME. The name of the PolyPascal help file.');
  writeln;
  writeln('ERROR MESSAGE FILE NAME. The name of the PolyPascal error message');
  writeln('file.');
  writeln;
  writeln('DEFAULT WORKFILE NAME. The workfile name is set to this file name');
  writeln('when PolyPascal is started and when the ZAP command is used.');
  writeln;
  pressreturn;
  writeln('DEFAULT TEXT FILE TYPE.  The default type used by the LOAD,  SAVE');
  writeln('and NAME commands.');
  writeln;
  writeln('DEFAULT BACKUP FILE TYPE.  The  type used by the SAVE command  to');
  writeln('create backup files.');
  writeln;
  writeln('DAFAULT PROGRAM FILE TYPE.  The default type used by the  PROGRAM');
  writeln('command.');
  writeln;
  writeln('DEFAULT OBJECT FILE TYPE.  The  default type used by  the  OBJECT');
  writeln('command.');
  writeln;
  writeln('CONFIGURATION NAME.  This function is used to define the name  of');
  writeln('the current  configuration.  If no name is installed,  PolyPascal');
  writeln('will not run, since this indicates an unconfigured copy.');
  writeln;
  pressreturn;
END;

BEGIN {misc}
  WITH data DO
  REPEAT
    writeln('MISCELLANEOUS DATA:');
    writeln;
    writeln(pa,yesno(backf));
    writeln(pb,errmod);
    writeln(pc,hlpstr);
    writeln(pd,ermstr);
    writeln(pe,wrkstr);
    writeln(pf,copy(pasext,2,3));
    writeln(pg,copy(bakext,2,3));
    writeln(ph,copy(comext,2,3));
    writeln(pi,copy(chnext,2,3));
    writeln(pj,termname);
    writeln;
    ch:=select('Edit(A-J), Exit(X), Help(Y)',['A'..'J','X','Y']);
    CASE ch OF
      'A': BEGIN
             write(pa); backf:=readyn;
           END;
      'B': BEGIN
             write(pb); errmod:=readnum(0,2);
           END;
      'C': BEGIN
             write(pc); readfn(hlpstr);
           END;
      'D': BEGIN
             write(pd); readfn(ermstr);
           END;
      'E': BEGIN
             write(pe); readfn(wrkstr);
           END;
      'F': BEGIN
             write(pf); readext(pasext);
           END;
      'G': BEGIN
             write(pg); readext(bakext);
           END;
      'H': BEGIN
             write(ph); readext(comext);
           END;
      'I': BEGIN
             write(pi); readext(chnext);
           END;
      'J': BEGIN
             write(pj); buflen:=31; readln(termname);
           END;
      'Y': help;
    END;
    IF ch IN ['A'..'J'] THEN writeln;
  UNTIL ch='X';
END;

PROCEDURE clear;
BEGIN
  write('Clear configuration data (YES/NO)? ');
  IF readyn<>0 THEN
  BEGIN
    clear1; clear2;
  END;
  writeln;
END;

PROCEDURE help;
BEGIN
  writeln('To do a complete installation of PolyPascal you should go through');
  writeln('all functions of this menu (the order in which you do it is of no');
  writeln('importance,  as  long as you make sure that all fields within all');
  writeln('menus have be inspected and modified if necessary).');
  writeln;
  writeln('CRT CONFIGURATION.  This function is used to view  and/or  modify');
  writeln('the CRT configuration table.');
  writeln;
  writeln('KEYBOARD CONFIGURATION.  This  function  is used to  view  and/or');
  writeln('modify alternate key definitions.');
  writeln;
  writeln('EDITOR CONFIGURATION. This function is used to view and/or modify');
  writeln('the editor configuration table.');
  writeln;
  writeln('MISCELLANEOUS DATA.  This  function  allows you  to  view  and/or');
  writeln('modify various system parameters.');
  writeln;
  pressreturn;
  writeln('CLEAR CONFIGURATION DATA.  This function will initialize all con-');
  writeln('figuration data fields to some appropriate default values. If you');
  writeln('are about to install a new terminal, use this function before the');
  writeln('above ones - this will save you the trouble of manually  removing');
  writeln('the existing values.');
  writeln;
  pressreturn;
END;

BEGIN {configure}
  WITH data DO
  REPEAT
    writeln('MAIN CONFIGURATION MENU:');
    writeln;
    writeln('1. CRT configuration');
    writeln('2. Keyboard configuration');
    writeln('3. Editor configuration');
    writeln('4. Miscellaneous data');
    writeln('5. Clear configuration data');
    writeln;
    ch:=select('Function(1-5), Exit(X), Help(Y)',['1'..'5','X','Y']);
    CASE ch OF
      '1': crt;
      '2': keyboard;
      '3': editor;
      '4': misc;
      '5': clear;
      'Y': help;
    END;
  UNTIL ch='X';
END;

PROCEDURE noinst;
BEGIN
  writeln('The INSTALL.TRM and INSTALL.DAT data files are not present on the');
  writeln('default  drive,  and therefore you cannot load or  save  standard');
  writeln('configurations.');
  writeln;
  pressreturn;
END;

PROCEDURE lsconfig(load: boolean);
VAR
  i,c,cc: integer;
  ch: char;
  done: boolean;
  ls: str4;

PROCEDURE loadc;
VAR
  ch: char;
  p: ^pdatrec;
BEGIN
  IF tnam[c]<>'' THEN
  BEGIN
    p:=addr(data.termname); seek(df,c-1); read(df,p^);
    done:=true;
  END ELSE
  BEGIN
    write('ERROR: Undefined configuration. Press RETURN...');
    REPEAT read(kbd,ch) UNTIL ch=^M;
    backsp(47);
  END;
END;

PROCEDURE savec;
VAR
  p: ^pdatrec;
BEGIN
  seek(tf,c-1); write(tf,data.termname);
  p:=addr(data.termname); seek(df,c-1); write(df,p^);
  tnam[c]:=data.termname; done:=true;
END;

PROCEDURE help1;
BEGIN
  writeln('To  load a standard configuration,  simply press the letter deno-');
  writeln('ting that configuration.  If none of the standard  configurations');
  writeln('mentioned  match your computer system,  you will have to  install');
  writeln('PolyPascal manually (using function 2 on the main menu).');
  writeln;
  pressreturn;
END;

PROCEDURE help2;
BEGIN
  writeln('To  save  the current configuration as a standard  configuration,');
  writeln('use  the RETURN key to move to a section that contains  an  empty');
  writeln('entry,  and enter the letter of that entry.  You may, if you wish');
  writeln('save  the  current  configuration on top of  an  existing  confi-');
  writeln('guration,  in which case that cofiguration is lost.  Note that if');
  writeln('the name of the configuration you save is empty,  you will not be');
  writeln('able to load the configuration again.');
  writeln;
  pressreturn;
END;

BEGIN {lsconfig}
  IF insfile THEN
  BEGIN
    cc:=1; done:=false; IF load THEN ls:='Load' ELSE ls:='Save';
    REPEAT
      writeln('STANDARD CONFIGURATIONS (MENU ',(cc+9) DIV 10,'):');
      writeln;
      FOR i:=0 TO 9 DO
      writeln(chr(i+65),'. ',tnam[cc+i]);
      writeln;
      writeln('Press RETURN to view more');
      writeln;
      ch:=select(ls+'(A-J), Exit(X), Help(Y)',['A'..'J','X','Y',^M]);
      CASE ch OF
        'A'..'J': BEGIN
                    c:=cc+ord(ch)-65; IF load THEN loadc ELSE savec;
                  END;
        'X': done:=true;
        'Y': IF load THEN help1 ELSE help2;
        ^M: BEGIN
              cc:=cc+10; IF cc>maxterm THEN cc:=1;
            END;
      END;
    UNTIL done;
  END ELSE noinst;
END;

PROCEDURE getdata;
VAR
  n: integer;
BEGIN
  seek(cf,0); blockread(cf,data,$379,n);
  IF data.pstwd=$9090 THEN
  BEGIN
    seek(cf,data.edofs+6); blockread(cf,data.rdelay,$17C,n);
  END ELSE clear2;
END;

PROCEDURE putdata;
VAR
  n: integer;
BEGIN
  seek(cf,0); blockwrite(cf,data,$379,n);
  IF data.pstwd=$9090 THEN
  BEGIN
    seek(cf,data.edofs+6); blockwrite(cf,data.rdelay,$17C,n);
  END;
END;

PROCEDURE help;
BEGIN
  writeln('LOAD STANDARD CONFIGURATION.  This  function is used  to  load  a');
  writeln('standard  configuration,  i.e.  to  load all the parameters  that');
  writeln('define  a specific computer system.  If your computer  system  is');
  writeln('among  the  standard configurations,  then all you need to do  to');
  writeln('install PolyPascal is to load that configuration and exit.  If it');
  writeln('is not,  you must define your computer system manually, using the');
  writeln('function described below.');
  writeln;
  writeln('EDIT CONFIGURATION PARAMETERS.  This function is used to  set  up');
  writeln('new  configurations  and to edit an  existing  configuration.  It');
  writeln('allows  you  to view and/or modify all parameters that  define  a');
  writeln('specific  computer system.  If your computer is not mentioned  in');
  writeln('the  list of standard configurations (see above),  you  must  use');
  writeln('this function to define it manually.');
  writeln;
  writeln('SAVE A STANDARD CONFIGURATION.  This function is used to  add  an');
  writeln('entry to the list of standard configurations.  Normally, you will');
  writeln('not need to use this function.');
  writeln;
  pressreturn;
END;

BEGIN
  ehofs:=ofs(errhand);
  writeln;
  writeln('              PolyPascal-86 V3.11 Install Program');
  writeln('                        MS-DOS version');
  writeln;
  writeln('                      Copyright (C) 1986');
  writeln('                  PolyTech International A/S');
  writeln;
  writeln;
  writeln('This  program is used to view and modify the adjustable parts  of');
  writeln('PolyPascal.  If your copy of PolyPascal is unconfigured, then be-');
  writeln('fore you can use it,  you must install it using this program.  If');
  writeln('your copy is already set up for a specific computer system, there');
  writeln('is no need to run this program,  unless you wish to make personal');
  writeln('adjustments.');
  writeln;
  assign(tf,'INSTALL.TRM'); assign(df,'INSTALL.DAT');
  {$I-} reset(tf); reset(df); {$I+}
  insfile:=iores=0;
  IF insfile THEN
  FOR i:=1 TO maxterm DO read(tf,tnam[i]) ELSE noinst;
  REPEAT
    write('Input file name (RETURN for PPAS.COM)? ');
    buflen:=64; readln(cfn); cfn:=upcase(cfn); writeln;
    IF (cfn='') OR (cfn[len(cfn)] IN [':','\']) THEN
    cfn:=cfn+'PPAS';
    IF pos('.',cfn)=0 THEN cfn:=cfn+'.COM';
    assign(cf,cfn); {$I-} reset(cf,1) {$I+};
    i:=iores;
    IF i<>0 THEN
    BEGIN
      writeln('That file does not exist. Please specify another filename.');
      writeln('You may insert another disk if you wish.');
      writeln;
    END;
  UNTIL i=0;
  getdata;
  REPEAT
    writeln('INSTALL PROGRAM MAIN MENU:');
    writeln;
    writeln('1. Load a standard configuration');
    writeln('2. Edit configuration parameters');
    writeln('3. Save a standard configuration');
    writeln;
    write('CURRENT CONFIGURATION: ');
    IF data.termname<>'' THEN
    writeln(data.termname) ELSE writeln('No terminal selected');
    writeln;
    ch:=select('Function(1-3), Exit(X), Help(Y)',['1'..'3','X','Y']);
    CASE ch OF
      '1': lsconfig(true);
      '2': configure;
      '3': lsconfig(false);
      'Y': help;
    END;
  UNTIL ch='X';
  write('Save configuration in ',cfn,' (YES/NO)? ');
  IF readyn<>0 THEN putdata; close(cf);
  IF insfile THEN
  BEGIN
    close(tf); close(df);
  END;
END.
