
{*******************************************************}
{                                                       }
{                 PolyFile Version 1.10                 }
{                                                       }
{                     NPFKEY module                     }
{                                                       }
{                  Copyright (C) 1986                   }
{              PolyTech International A/S               }
{                                                       }
{*******************************************************}

{$I-,K-,R-}

PROCEDURE nextkey(VAR idxf: indexfile; VAR pdr: integer; VAR pk);
VAR
  pkey: p_keystr AT pk;
  r: integer;
  n: p_nodrcp;
BEGIN
  WITH idxf DO
  BEGIN
    IF pp=0 THEN r:=rr ELSE
    WITH path[pp] DO
    BEGIN
      p_getn(idxf,nr,n); r:=n^.e[ep].nr;
    END;
    WHILE r<>0 DO
    BEGIN
      pp:=pp+1;
      WITH path[pp] DO
      BEGIN
        nr:=r; ep:=0;
      END;
      p_getn(idxf,r,n); r:=n^.nr0;
    END;
    IF pp<>0 THEN
    BEGIN
      WHILE (pp>1) AND (path[pp].ep=n^.ne) DO
      BEGIN
        pp:=pp-1; p_getn(idxf,path[pp].nr,n);
      END;
      IF path[pp].ep<n^.ne THEN WITH path[pp] DO
      BEGIN
        ep:=ep+1;
        WITH n^.e[ep] DO
        BEGIN
          pkey:=key; pdr:=dr;
        END;
      END ELSE pp:=0;
    END;
    ok:=pp<>0;
  END;
END;

PROCEDURE prevkey(VAR idxf: indexfile; VAR pdr: integer; VAR pk);
VAR
  pkey: p_keystr AT pk;
  r: integer;
  n: p_nodrcp;
BEGIN
  WITH idxf DO
  BEGIN
    IF pp=0 THEN r:=rr ELSE
    WITH path[pp] DO
    BEGIN
      p_getn(idxf,nr,n); ep:=ep-1;
      IF ep=0 THEN r:=n^.nr0 ELSE r:=n^.e[ep].nr;
    END;
    WHILE r<>0 DO
    BEGIN
      p_getn(idxf,r,n); pp:=pp+1;
      WITH path[pp] DO
      BEGIN
        nr:=r; ep:=n^.ne;
      END;
      WITH n^ DO r:=e[ne].nr;
    END;
    IF pp<>0 THEN
    BEGIN
      WHILE (pp>1) AND (path[pp].ep=0) DO
      BEGIN
        pp:=pp-1; p_getn(idxf,path[pp].nr,n);
      END;
      IF path[pp].ep>0 THEN WITH n^.e[path[pp].ep] DO
      BEGIN
        pkey:=key; pdr:=dr;
      END ELSE pp:=0;
    END;
    ok:=pp<>0;
  END;
END;

PROCEDURE p_finkey(VAR idxf: indexfile; VAR pdr: integer; VAR pk);
VAR
  pkey: p_keystr AT pk;
  npr,c,k,l,r: integer;
  rkey: p_keystr;
  n: p_nodrcp;
BEGIN
  WITH idxf DO
  BEGIN
    p_xkey(pkey,klen); ok:=false; pp:=0; npr:=rr;
    WHILE (npr<>0) AND NOT ok DO
    BEGIN
      pp:=pp+1; path[pp].nr:=npr; p_getn(idxf,npr,n);
      WITH n^ DO
      BEGIN
        l:=1; r:=ne;
        REPEAT
          k:=(l+r) DIV 2;
          c:=p_ckey(pkey,e[k].key,0,e[k].dr,dupkey);
          IF c<=0 THEN r:=k-1; IF c>=0 THEN l:=k+1;
        UNTIL r<l;
        IF l-r>1 THEN
        BEGIN
          pdr:=e[k].dr; r:=k; ok:=true;
        END;
        IF r=0 THEN npr:=nr0 ELSE npr:=e[r].nr;
      END;
      path[pp].ep:=r;
    END;
    IF NOT ok AND (pp>0) THEN
    BEGIN
      WHILE (pp>1) AND (path[pp].ep=0) DO pp:=pp-1;
      IF path[pp].ep=0 THEN pp:=0;
    END;
  END;
END;

PROCEDURE findkey(VAR idxf: indexfile; VAR pdr: integer; VAR pk);
VAR
  pkey: p_keystr AT pk;
  tkey: p_keystr;
BEGIN
  p_finkey(idxf,pdr,pkey);
  IF NOT ok AND idxf.dupkey THEN
  BEGIN
    tkey:=pkey; nextkey(idxf,pdr,pkey);
    ok:=ok AND (pkey=tkey);
  END;
END;

PROCEDURE searchkey(VAR idxf: indexfile; VAR pdr: integer; VAR pk);
VAR
  pkey: p_keystr AT pk;
BEGIN
  p_finkey(idxf,pdr,pkey);
  IF NOT ok THEN nextkey(idxf,pdr,pkey);
END;
