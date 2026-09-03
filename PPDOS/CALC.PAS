PROGRAM calculator; {$K-,R-}

{ This program acts like a calculator - You type an expression	}
{ and the program calculates its value. Each time the calcula-	}
{ tor is ready to accept an input line, it prints an asterisk.	}
{ You must then type the expression and end it by pressing the	}
{ RETURN key, and shortly after, the result is displayed. If	}
{ the calculator finds an error, it displays a pointer, which	}
{ points at the error. There are five different operators (^,	}
{ *, /, +, and -), and seven standard functions (ABS, SQRT,	}
{ SIN, COS, ARCTAN, LN, and EXP). Parentheses within expres-	}
{ sions are allowed. A special variable, called X, always	}
{ holds the value of the last computation. To end the program,	}
{ type QUIT when the calculator prompts for an input line.	}

CONST
  strlen = 48;
TYPE
  str = STRING[strlen];
VAR
  e: integer;
  r: real;
  s: str;

PROCEDURE upcase(VAR s: str);
VAR
  i: integer;
BEGIN
  FOR i:=1 TO len(s) DO
  IF (s[i]>='a') AND (s[i]<='z') THEN s[i]:=chr(ord(s[i])-32);
END;

PROCEDURE evaluate(VAR expr: str; VAR value: real; VAR errpos: integer);
CONST
  errch = '?';
  eofline = @13;
VAR
  pos: integer;
  ch: char;

PROCEDURE nextchar;
BEGIN
  REPEAT
    pos:=pos+1;
    IF pos<=len(expr) THEN
    ch:=expr[pos] ELSE
    ch:=eofline;
  UNTIL ch<>' ';
END;

FUNCTION expression: real;
VAR
  e: real;
  opr: char;

FUNCTION simexpr: real;
VAR
  s: real;
  opr: char;

FUNCTION term: real;
VAR
  t: real;

FUNCTION signedfactor: real;

FUNCTION factor: real;
TYPE
  stdf = (fabs,fsqrt,fsin,fcos,farctan,fln,fexp);
  stdflist = ARRAY[stdf] OF STRING[6];
CONST
  stdfun: stdflist = ('ABS','SQRT','SIN','COS','ARCTAN','LN','EXP');
VAR
  p,e,sl: integer;
  found: boolean;
  f: real;
  sf: stdf;
BEGIN
  IF ch IN ['0'..'9'] THEN
  BEGIN
    p:=pos;
    REPEAT nextchar UNTIL NOT(ch IN ['0'..'9','.']);
    IF ch IN ['E','e'] THEN
    BEGIN
      nextchar;
      IF ch IN ['+','-'] THEN nextchar;
      WHILE ch IN ['0'..'9'] DO nextchar;
    END;
    val(copy(expr,p,pos-p),f,e);
    IF e<>0 THEN
    BEGIN
      pos:=p+e-1; ch:=errch;
    END;
  END ELSE
  IF ch='(' THEN
  BEGIN
    nextchar;
    f:=expression;
    IF ch=')' THEN nextchar ELSE ch:=errch;
  END ELSE
  IF ch='X' THEN
  BEGIN
    nextchar; f:=value;
  END ELSE
  BEGIN
    found:=false;
    FOR sf:=fabs TO fexp DO
    IF NOT found THEN
    BEGIN
      sl:=len(stdfun[sf]);
      IF copy(expr,pos,sl)=stdfun[sf] THEN
      BEGIN
        pos:=pos+sl-1; nextchar;
        f:=factor;
        CASE sf OF
          fabs: f:=abs(f);
          fsqrt: f:=sqrt(f);
          fsin: f:=sin(f);
          fcos: f:=cos(f);
          farctan: f:=arctan(f);
          fln: f:=ln(f);
          fexp: f:=exp(f);
        END;
        found:=true;
      END;
    END;
    IF NOT found THEN ch:=errch;
  END;
  factor:=f;
END {factor};

BEGIN {signedfactor}
  IF ch='-' THEN
  BEGIN
    nextchar; signedfactor:=-factor;
  END ELSE
  signedfactor:=factor;
END {signedfactor};

BEGIN {term}
  t:=signedfactor;
  WHILE ch='^' DO
  BEGIN
    nextchar; t:=exp(ln(t)*signedfactor);
  END;
  term:=t;
END {term};

BEGIN {simexpr}
  s:=term;
  WHILE ch IN ['*','/'] DO
  BEGIN
    opr:=ch; nextchar;
    CASE opr OF
      '*': s:=s*term;
      '/': s:=s/term;
    END;
  END;
  simexpr:=s;
END {simexpr};

BEGIN {expression}
  e:=simexpr;
  WHILE ch IN ['+','-'] DO
  BEGIN
    opr:=ch; nextchar;
    CASE opr OF
      '+': e:=e+simexpr;
      '-': e:=e-simexpr;
    END;
  END;
  expression:=e;
END {expression};

BEGIN {evaluate}
  pos:=0; nextchar;
  value:=expression;
  IF ch=eofline THEN errpos:=0 ELSE errpos:=pos;
END {evaluate};

BEGIN {calculator}
  REPEAT
    write('* '); buflen:=strlen; read(s); upcase(s);
    IF (s<>'') AND (s<>'QUIT') THEN
    BEGIN
      evaluate(s,r,e);
      IF e=0 THEN write(' =',r) ELSE
      BEGIN
        writeln;
        write('^ ERROR':e+8);
      END;
    END;
    writeln;
  UNTIL s='QUIT';
END {calculator}.
