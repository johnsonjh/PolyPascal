
{*******************************************************}
{                                                       }
{            PolyFile Version 1.10 (MS-DOS)             }
{                                                       }
{                     DATMAN module                     }
{                                                       }
{                  Copyright (C) 1986                   }
{              PolyTech International A/S               }
{                                                       }
{*******************************************************}

{$I-,K-,R-}

TYPE
  p_str64 = STRING[64];
  datafile = RECORD
               CASE integer OF
                 0: (f: FILE;
                     ffre,nfre,int1,int2,nrec: integer);
                 1: (fill: ARRAY[1..12] OF byte;
                     fnam: ARRAY[1..64] OF char);
             END;
  p_keystr = STRING[maxksize];
  p_idxrec = RECORD
               dr,nr: integer;
               key: p_keystr;
             END;
  p_nodrec = RECORD
               ne: 0..nodesize;
               nr0: integer;
               e: ARRAY[1..nodesize] OF p_idxrec;
             END;
  p_nodrcp = ^p_nodrec;
  p_pthrec = RECORD
                nr,ep: integer;
              END;
  p_pthlst = ARRAY[1..maxdepth] OF p_pthrec;
  indexfile = RECORD
                d: datafile;
                dupkey: boolean;
                klen,rr,pp: integer;
                path: p_pthlst;
              END;
  p_indxfp = ^indexfile;
  p_nbfrec = RECORD
                n: p_nodrec;
                ifp: p_indxfp;
                nr: integer;
                upd: boolean;
              END;
  p_nbfrcp = ^p_nbfrec;
  p_nodbuf = ARRAY[1..nbufsize] OF p_nbfrec;
  p_nodmap = ARRAY[1..nbufsize] OF integer;
  p_recbuf = RECORD
                  CASE integer OF
                    0: (n: p_nbfrec);
                    1: (r: ARRAY[1..maxrsize] OF byte);
                    2: (i: integer);
                END;

VAR
  iosts: integer;
  ok: boolean;
  p_rbuf: p_recbuf;
  p_nbuf: p_nodbuf;
  p_nmap: p_nodmap;

PROCEDURE iocheck(VAR datf: datafile; r: integer);
VAR
  p: integer;
BEGIN
  IF iosts<>0 THEN WITH datf DO
  BEGIN
    writeln;
    writeln('PolyFile I/O Error ',iosts);
    write('File '); p:=1;
    WHILE fnam[p]<>@0 DO
    BEGIN
      write(fnam[p]); p:=p+1;
    END;
    writeln(' Record ',r);
    writeln('Program terminated');
    halt;
  END;
END;

PROCEDURE getrec(VAR datf: datafile; r: integer; VAR buffer);
VAR
  n: integer;
BEGIN
  seek(datf.f,r); blockread(datf.f,buffer,1,n);
  IF n=0 THEN iosts:=12 ELSE iosts:=iores;
  iocheck(datf,r);
END;

PROCEDURE putrec(VAR datf: datafile; r: integer; VAR buffer);
VAR
  n: integer;
BEGIN
  seek(datf.f,r); blockwrite(datf.f,buffer,1,n);
  IF n=0 THEN iosts:=13 ELSE iosts:=iores;
  iocheck(datf,r);
END;

PROCEDURE makefile(VAR datf: datafile; fnam: p_str64; reclen: integer);
BEGIN
  assign(datf.f,fnam); rewrite(datf.f,reclen); iosts:=iores;
  IF iosts=3 THEN ok:=false ELSE
  BEGIN
    iocheck(datf,0); datf.ffre:=-1; datf.nfre:=0;
    datf.int1:=0; datf.int2:=0;
    move(datf.ffre,p_rbuf,8); putrec(datf,0,p_rbuf);
    datf.nrec:=1; ok:=true;
  END;
END;

PROCEDURE openfile(VAR datf: datafile; fnam: p_str64; reclen: integer);
BEGIN
  assign(datf.f,fnam); reset(datf.f,reclen); iosts:=iores;
  IF iosts=2 THEN ok:=false ELSE
  BEGIN
    iocheck(datf,0);
    getrec(datf,0,p_rbuf); move(p_rbuf,datf.ffre,8);
    datf.nrec:=length(datf.f); ok:=true;
  END;
END;

PROCEDURE closefile(VAR datf: datafile);
BEGIN
  move(datf.ffre,p_rbuf,8); putrec(datf,0,p_rbuf);
  close(datf.f); iosts:=iores; iocheck(datf,0);
END;

PROCEDURE p_newr(VAR datf: datafile; VAR r: integer);
BEGIN
  IF datf.ffre=-1 THEN
  BEGIN
    r:=datf.nrec; datf.nrec:=datf.nrec+1;
  END ELSE
  BEGIN
    r:=datf.ffre; getrec(datf,r,p_rbuf);
    datf.ffre:=p_rbuf.i; datf.nfre:=datf.nfre-1;
  END;
END;

PROCEDURE addrec(VAR datf: datafile; VAR r: integer; VAR buffer);
BEGIN
  p_newr(datf,r); putrec(datf,r,buffer);
END;

PROCEDURE deleterec(VAR datf: datafile; r: integer);
BEGIN
  p_rbuf.i:=datf.ffre; putrec(datf,r,p_rbuf);
  datf.ffre:=r; datf.nfre:=datf.nfre+1;
END;

FUNCTION filelen(VAR datf: datafile): integer;
BEGIN
  filelen:=datf.nrec;
END;

FUNCTION usedrecs(VAR datf: datafile): integer;
BEGIN
  usedrecs:=datf.nrec-datf.nfre-1;
END;

PROCEDURE initindex;
VAR
  i: integer;
BEGIN
  FOR i:=1 TO nbufsize DO
  BEGIN
    p_nbuf[i].ifp:=NIL; p_nbuf[i].upd:=false; p_nmap[i]:=i;
  END;
END;

PROCEDURE p_pack(VAR n: p_nodrec; klen: integer);
VAR
  i: integer;
  p: ARRAY[0..maxint] OF byte AT n;
BEGIN
  IF klen<>maxksize THEN
  FOR i:=1 TO nodesize DO
  move(n.e[i],p[(i-1)*(klen+5)+3],klen+5);
END;

PROCEDURE p_unpack(VAR n: p_nodrec; klen: integer);
VAR
  i: integer;
  p: ARRAY[0..maxint] OF byte AT n;
BEGIN
  IF klen<>maxksize THEN
  FOR i:=nodesize DOWNTO 1 DO
  move(p[(i-1)*(klen+5)+3],n.e[i],klen+5);
END;

PROCEDURE makeindex(VAR idxf: indexfile; fnam: p_str64; keylen,s: integer);
VAR
  k: integer;
BEGIN
  k:=(keylen+5)*nodesize+3;
  makefile(idxf.d,fnam,k);
  idxf.dupkey:=s<>0; idxf.klen:=keylen;
  idxf.rr:=0; idxf.pp:=0;
END;

PROCEDURE openindex(VAR idxf: indexfile; fnam: p_str64; keylen,s: integer);
VAR
  k: integer;
BEGIN
  k:=(keylen+5)*nodesize+3;
  openfile(idxf.d,fnam,k);
  idxf.dupkey:=s<>0; idxf.klen:=keylen;
  idxf.rr:=idxf.d.int1; idxf.pp:=0;
END;

PROCEDURE closeindex(VAR idxf: indexfile);
VAR
  i: integer;
BEGIN
  FOR i:=1 TO nbufsize DO WITH p_nbuf[i] DO
  IF ifp=addr(idxf) THEN
  BEGIN
    ifp:=NIL;
    IF upd THEN
    BEGIN
      p_pack(n,idxf.klen); putrec(idxf.d,nr,n); upd:=false;
    END;
  END;
  idxf.d.int1:=idxf.rr; closefile(idxf.d);
END;

PROCEDURE p_last(i: integer);
VAR
  j,k: integer;
BEGIN
  j:=1; WHILE (p_nmap[j]<>i) AND (j<nbufsize) DO j:=j+1;
  FOR k:=j TO nbufsize-1 DO p_nmap[k]:=p_nmap[k+1];
  p_nmap[nbufsize]:=i;
END;

PROCEDURE p_getn(VAR idxf: indexfile; r: integer; VAR np: p_nodrcp);
VAR
  i: integer;
  found: boolean;
BEGIN
  i:=0;
  REPEAT
    i:=i+1;
    WITH p_nbuf[i] DO found:=(ifp=addr(idxf)) AND (nr=r);
  UNTIL found OR (i=nbufsize);
  IF NOT found THEN
  BEGIN
    i:=p_nmap[1];
    WITH p_nbuf[i] DO
    BEGIN
      IF upd THEN
      BEGIN
        p_pack(n,ifp^.klen); putrec(ifp^.d,nr,n);
      END;
      getrec(idxf.d,r,n); p_unpack(n,idxf.klen);
      ifp:=addr(idxf); nr:=r; upd:=false;
    END;
  END;
  p_last(i); np:=addr(p_nbuf[i]);
END;

PROCEDURE p_newn(VAR idxf: indexfile; VAR r: integer; VAR np: p_nodrcp);
VAR
  i: integer;
BEGIN
  i:=p_nmap[1];
  WITH p_nbuf[i] DO
  BEGIN
    IF upd THEN
    BEGIN
      p_pack(n,ifp^.klen); putrec(ifp^.d,nr,n);
    END;
    p_newr(idxf.d,r); ifp:=addr(idxf);
    nr:=r; upd:=false;
  END;
  p_last(i); np:=addr(p_nbuf[i]);
END;

PROCEDURE p_updn(np: p_nodrcp);
VAR
  p: p_nbfrcp AT np;
BEGIN
  p^.upd:=true;
END;

PROCEDURE p_retn(VAR np: p_nodrcp);
VAR
  p: p_nbfrcp AT np;
BEGIN
  WITH p^ DO
  BEGIN
    deleterec(ifp^.d,nr); ifp:=NIL; upd:=false;
  END;
END;

PROCEDURE p_xkey(VAR k; klen: integer);
VAR
  key: p_keystr AT k;
BEGIN
  IF ord(key[0])>klen THEN key[0]:=chr(klen);
END;

FUNCTION p_ckey(VAR k1,k2; dr1,dr2: integer; dup: boolean): integer;
VAR
  key1: p_keystr AT k1;
  key2: p_keystr AT k2;
BEGIN
  IF key1=key2 THEN
  IF dup THEN p_ckey:=dr1-dr2 ELSE p_ckey:=0 ELSE
  IF key1>key2 THEN p_ckey:=1 ELSE p_ckey:=-1;
END;

PROCEDURE clearkey(VAR idxf: indexfile);
BEGIN
  idxf.pp:=0;
END;
