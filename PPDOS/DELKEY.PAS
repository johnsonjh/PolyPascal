
{*******************************************************}
{                                                       }
{                 PolyFile Version 1.10                 }
{                                                       }
{                     DELKEY module                     }
{                                                       }
{                  Copyright (C) 1986                   }
{              PolyTech International A/S               }
{                                                       }
{*******************************************************}

{$I-,K-,R-}

PROCEDURE deletekey(VAR idxf: indexfile; VAR pdr: integer; VAR pk);
VAR
  pkey: p_keystr AT pk;
  usize: boolean;
  n: p_nodrcp;

PROCEDURE delb(npr: integer);
VAR
  c,i,k,l,r,xpr: integer;
  n: p_nodrcp;

PROCEDURE uflow(npr,mpr,r: integer);
VAR
  i,k,le,lpr: integer;
  n,m,l: p_nodrcp;
BEGIN
  p_getn(idxf,npr,n); p_getn(idxf,mpr,m);
  IF r<n^.ne THEN
  BEGIN
    r:=r+1; lpr:=n^.e[r].nr; p_getn(idxf,lpr,l);
    k:=(l^.ne-nodehalf+1) DIV 2;
    m^.e[nodehalf]:=n^.e[r]; m^.e[nodehalf].nr:=l^.nr0;
    IF k>0 THEN
    BEGIN
      FOR i:=1 TO k-1 DO m^.e[i+nodehalf]:=l^.e[i];
      n^.e[r]:=l^.e[k]; n^.e[r].nr:=lpr;
      l^.nr0:=l^.e[k].nr; l^.ne:=l^.ne-k;
      FOR i:=1 TO l^.ne DO l^.e[i]:=l^.e[i+k];
      m^.ne:=nodehalf-1+k; usize:=false; p_updn(l);
    END ELSE
    BEGIN
      FOR i:=1 TO nodehalf DO m^.e[i+nodehalf]:=l^.e[i];
      FOR i:=r TO n^.ne-1 DO n^.e[i]:=n^.e[i+1];
      m^.ne:=nodesize; n^.ne:=n^.ne-1; p_retn(l);
      usize:=n^.ne<nodehalf;
    END;
    p_updn(m);
  END ELSE
  BEGIN
    IF r=1 THEN lpr:=n^.nr0 ELSE lpr:=n^.e[r-1].nr; p_getn(idxf,lpr,l);
    le:=l^.ne+1; k:=(le-nodehalf) DIV 2;
    IF k>0 THEN
    BEGIN
      FOR i:=nodehalf-1 DOWNTO 1 DO m^.e[i+k]:=m^.e[i];
      m^.e[k]:=n^.e[r]; m^.e[k].nr:=m^.nr0; le:=le-k;
      FOR i:=k-1 DOWNTO 1 DO m^.e[i]:=l^.e[i+le];
      m^.nr0:=l^.e[le].nr; n^.e[r]:=l^.e[le]; n^.e[r].nr:=mpr;
      l^.ne:=le-1; m^.ne:=nodehalf-1+k; usize:=false; p_updn(m);
    END ELSE
    BEGIN
      l^.e[le]:=n^.e[r]; l^.e[le].nr:=m^.nr0;
      FOR i:=1 TO nodehalf-1 DO l^.e[i+le]:=m^.e[i];
      l^.ne:=nodesize; n^.ne:=n^.ne-1; p_retn(m);
      usize:=n^.ne<nodehalf;
    END;
    p_updn(l);
  END;
  p_updn(n);
END;

PROCEDURE dela(mpr: integer);
VAR
  c,xpr: integer;
  m: p_nodrcp;
BEGIN
  p_getn(idxf,mpr,m);
  WITH m^ DO
  BEGIN
    xpr:=e[ne].nr;
    IF xpr<>0 THEN
    BEGIN
      c:=ne; dela(xpr); IF usize THEN uflow(mpr,xpr,c);
    END ELSE
    BEGIN
      p_getn(idxf,npr,n);
      e[ne].nr:=n^.e[k].nr; n^.e[k]:=e[ne];
      ne:=ne-1; usize:=ne<nodehalf;
      p_updn(n); p_updn(m);
    END;
  END;
END;

BEGIN
  IF npr=0 THEN
  BEGIN
    ok:=false; usize:=false;
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
      UNTIL l>r;
      IF r=0 THEN xpr:=nr0 ELSE xpr:=e[r].nr;
      IF l-r>1 THEN
      BEGIN
	pdr:=e[k].dr;
	IF xpr=0 THEN
	BEGIN
	  ne:=ne-1; usize:=ne<nodehalf;
	  FOR i:=k TO ne DO e[i]:=e[i+1];
	  p_updn(n);
	END ELSE
	BEGIN
	  dela(xpr); IF usize THEN uflow(npr,xpr,r);
	END;
      END ELSE
      BEGIN
        delb(xpr); IF usize THEN uflow(npr,xpr,r);
      END;
    END;
  END;
END;

BEGIN
  WITH idxf DO
  BEGIN
    p_xkey(pkey,klen); ok:=true; delb(rr);
    IF usize THEN
    BEGIN
      p_getn(idxf,rr,n);
      IF n^.ne=0 THEN
      BEGIN
        rr:=n^.nr0; p_retn(n);
      END;
    END;
    pp:=0;
  END;
END;
