
{*******************************************************}
{                                                       }
{                 PolyFile Version 1.10                 }
{                                                       }
{                     ADDKEY module                     }
{                                                       }
{                  Copyright (C) 1986                   }
{              PolyTech International A/S               }
{                                                       }
{*******************************************************}

{$I-,K-,R-}

PROCEDURE addkey(VAR idxf: indexfile; VAR pdr: integer; VAR pk);
VAR
  pkey: p_keystr AT pk;
  npr,mpr,c,i,k,l: integer;
  passup: boolean;
  n,m: p_nodrcp;
  pe,te: p_idxrec;

PROCEDURE search(npr: integer);
VAR
  r: integer;

PROCEDURE insert;
BEGIN
  p_getn(idxf,npr,n);
  WITH n^ DO
  BEGIN
    IF ne<nodesize THEN
    BEGIN
      ne:=ne+1; FOR i:=ne DOWNTO r+2 DO e[i]:=e[i-1];
      e[r+1]:=pe; passup:=false;
    END ELSE
    BEGIN
      p_newn(idxf,mpr,m);
      IF r<=nodehalf THEN
      BEGIN
        IF r=nodehalf THEN te:=pe ELSE
        BEGIN
          te:=e[nodehalf];
          FOR i:=nodehalf DOWNTO r+2 DO e[i]:=e[i-1];
          e[r+1]:=pe;
        END;
        FOR i:=1 TO nodehalf DO m^.e[i]:=e[i+nodehalf];
      END ELSE
      BEGIN
        r:=r-nodehalf; te:=e[nodehalf+1];
        FOR i:=1 TO r-1 DO m^.e[i]:=e[i+nodehalf+1];
        m^.e[r]:=pe;
        FOR i:=r+1 TO nodehalf DO m^.e[i]:=e[i+nodehalf];
      END;
      ne:=nodehalf;
      m^.ne:=nodehalf; m^.nr0:=te.nr; te.nr:=mpr;
      pe:=te; p_updn(m);
    END;
  END;
  p_updn(n);
END;

BEGIN
  IF npr=0 THEN
  BEGIN
    passup:=true;
    WITH pe DO
    BEGIN
      key:=pkey; dr:=pdr; nr:=0;
    END;
  END ELSE
  BEGIN
    p_getn(idxf,npr,n);
    WITH n^ DO
    BEGIN
      l:=1; r:=ne;
      REPEAT
        k:=(l+r) DIV 2;
        c:=p_ckey(pkey,e[k].key,pdr,e[k].dr,idxf.dupkey);
        IF c<=0 THEN r:=k-1; IF c>=0 THEN l:=k+1;
      UNTIL r<l;
      IF l-r>1 THEN
      BEGIN
        ok:=false; passup:=false;
      END ELSE
      BEGIN
	IF r=0 THEN search(nr0) ELSE search(e[r].nr);
	IF passup THEN insert;
      END;
    END;
  END;
END;

BEGIN
  WITH idxf DO
  BEGIN
    p_xkey(pkey,klen); ok:=true; search(rr);
    IF passup THEN
    BEGIN
      npr:=rr; p_newn(idxf,rr,n);
      WITH n^ DO
      BEGIN
        ne:=1; nr0:=npr; e[1]:=pe;
      END;
      p_updn(n);
    END;
    pp:=0;
  END;
END;
