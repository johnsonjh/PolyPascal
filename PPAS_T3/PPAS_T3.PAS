program ConvertPPAStoTurbo3;

CONST
  DiscFile='PPAS_T3.DAT';       { ‘ndres til det ›nskede        }
                                { f.eks. 'C:\PPAS\PPAS_T3.DAT'  }

  DiscError='Fejl i beskriver fil';
  MinString=0;  MaxString=75;   { Antal linjer i beskriver fil  }

TYPE
  strL=         string[130];    { linje buffer etc }
  XchgT=        RECORD
                  s1,s2,s3: strL;
                  typ: char;
                  antal: integer;
                END;
  StringT=      array[MinString..MaxString] of XchgT;
  TokT=(_OTHER,_CODE,_KOMMA,_SEMIKOLON,_KOMMENTAR,_COMMAT,_EOF);

VAR
  lastCh: char;
  inpLine,NextLineComment,OutString: strL;
  inpLinePtr: integer;
  token: RECORD
           orgStr: strL;
           UpperStr: strL;
           tok: tokT;
           searchNo: integer;
         END;
  KommentarAktiv: (notActiv,Tuborg,Dobbel);
  digits,letters,diglet: set of char;
  StringBuf: ^StringT;
  StringNo: integer;
  DiscF,InpF,OutF: text;

procedure Error(err: boolean; s: strL);
begin
  if err then
  begin
    writeln('ERROR: ',s);
    write('Tryk "Enter" '); read;
    halt;
  end;
end;

procedure ErrorHandler(a,b: integer);
begin
  writeln(a,' ',b);
  error(true,'Internal error');
end;

procedure UpCase(var s: strL);
var
  n: integer;
begin
  for n:=1 to len(s) do
    case s[n] of
    'a'..'z': s[n]:=chr(ord(s[n])-32)
    end
end;

procedure InitTable;
var
  i: integer;
  ch: char;
  S: XchgT;

function readStr: strL;
var
  ch: char;
  s: strL;
begin
  s:='';
  if not seoln(DiscF) then
  repeat
    read(DiscF,ch);
    if (ch in [@9,' ']) then ch:=@0 else s:=s+ch;
  until (ch=@0) or eoln(DiscF);
  readStr:=s;
end;

begin
  new(StringBuf); StringNo:=MinString;
  assign(DiscF,DiscFile);
  {$I-} reset(DiscF); {$I+}
  Error((iores<>0),'Beskriver fil ikke fundet');
  while not seof(DiscF) do
  begin
    if not seoln(DiscF) then
    begin
      fill(s,size(s),@0);
      read(DiscF,ch);
      Error(not (ch in ['#']),DiscError);
      Error(eoln(DiscF),DiscError);
      read(DiscF,s.typ);
      Error(not (s.typ in ['1','2','3',' ',@9]),DiscError+'('+s.typ+')');
      if s.typ in ['1','2','3'] then
      begin
        s.s1:=readStr;        { laes PPAS navn }
        UpCase(s.s1);
        s.s2:=readStr;        { laes Turbo navn }
        if seoln(DiscF) then
          s.s3:='' else read(DiscF,s.s3); { laes kommentar }
        StringBuf^[StringNo]:=s;
        StringNo:=succ(StringNo);
      end;
    end;
    readln(DiscF);
  end;
  close(DiscF);
end;

function searchFor(s: strL): integer;
var n: integer;
begin
  n:=StringNo;
  repeat
    n:=pred(n);
  until (StringBuf^[n].s1=s) or (n=MinString);
  if StringBuf^[n].s1=s then
  begin
    searchFor:=n;
    StringBuf^[n].antal:=StringBuf^[n].antal+1;
  end else
    SearchFor:=MinString-1;
end;

procedure flushLit;
begin
  writeln(OutF,OutString);
  OutString:='';
end;

procedure writeLit(s: strL);
begin
  if len(outstring)+len(s)>127 then flushLit;
  outString:=outString+s;
  if OutString[len(OutString)]=@13 then
  begin
    delete(outString,len(outString),1);
    flushLit;
    if NextLineComment<>'' then
    begin
      writeln(OutF,NextLineComment);
      NextLineComment:='';
    end;
  end;
end;

procedure writeTok;
begin
  writeLit(token.orgStr);
end;

procedure nextLine;
begin
  fill(inpLine,size(inpLine),@0);
  if not eof(InpF) then
  begin
    readln(InpF,inpLine);
    inpLine:=inpLine+@13;
  end;
  inpLinePtr:=1;
end;

function nextCh: char;   { return both in function and in lastCh }
begin
  if inpLine[inpLinePtr]=@0 then nextLine;
  lastCh:=inpLine[inpLinePtr];
  inpLinePTR:=inpLinePtr+1;
  nextCh:=lastCh;
end;
procedure skipCh; var ch: char; begin ch:=nextCh end;
function peekNextCh: char;
begin
  peekNextCh:=inpLine[inpLinePtr];
end;

procedure scan;
var
  ok: boolean;
  s: strL;
begin
  s:=lastCh;
  if KommentarAktiv=notActiv then
  begin
    token.tok:=_OTHER;
    case lastCh of
    '''':
    begin
      while not (nextCh in ['''',@13]) do s:=s+lastch;
      s:=s+lastch;
      SkipCh;
    end;
    '@': begin token.tok:=_COMMAT; SkipCh; end;
    ',': begin token.tok:=_KOMMA; SkipCh; end;
    ';': begin token.tok:=_SEMIKOLON; SkipCh; end;
    '{': begin token.tok:=_KOMMENTAR; KommentarAktiv:=Tuborg; SkipCh; end;
    '(':
    begin
      if nextCh='*' then
      begin
        s:='(*';
        token.tok:=_KOMMENTAR;
        KommentarAktiv:=Dobbel;
        SkipCh; 
      end;
    end;
    'a'..'z','_','A'..'Z':
    begin
      while nextCh in diglet do s:=s+lastCh;
    end;
    '0'..'9':   while nextCh in digits do s:=s+lastCh;
    ' ',@9:     while nextCh in [' ',@9] do s:=s+lastCh;
    @0:         token.tok:=_EOF;
    otherwise   skipCh;
    end;
    token.orgstr:=s;
    token.upperStr:=s;
    if token.upperStr[1] in letters then
    begin
      UpCase(token.upperStr);
      token.searchNo:=searchFor(token.upperStr);
    end else token.searchNo:=MinString-1;
    if token.upperStr='CODE' then token.tok:=_CODE;
  end else begin
    if KommentarAktiv=Tuborg then
    begin
      if lastCh<>'}' then
      begin
        while not(nextCh in ['}',@0,@13]) do s:=s+lastCh;
        s:=s+lastCh;
      end;
      if lastCh='}' then
      begin
        KommentarAktiv:=notActiv;
      end;
      SkipCh;
    end else begin
      while not((lastCh='*') and (peekNextCh=')')) and not (lastCh in [@0,@13]) do
        s:=s+nextCh;
      if not (lastCh in [@0,@13]) then
      begin
        KommentarAktiv:=NotActiv;
        s:=s+nextCh;
      end;
      SkipCh;
    end;
    token.orgstr:=s;
  end;
end;

procedure ClearUsedFlags;
var n: integer;
begin
  for n:=MinString to StringNo-1 do
    StringBuf^[n].antal:=0;
end;

procedure TestUsedFlags;
var n: integer;
begin
  for n:=MinString to StringNo-1 do
    case StringBuf^[n].typ of
    '1': ;
    '2': if StringBuf^[n].antal>0 then
    begin
      write('PPAS navn: ',StringBuf^[n].s1,' er brugt ');
      if StringBuf^[n].antal=1 then
        writeln(' en enkelt gang')
      else
        writeln(StringBuf^[n].antal,' gange');
    end;
    '3': if StringBuf^[n].antal=0 then writeln('PPAS navn: ',StringBuf^[n].s1,' er ikke brugt ved konverteringen');
    end;
end;

procedure cvtCode;
begin
  writeTok; writeLit('(');
  repeat
    scan;
    case token.tok of
    _KOMMA:     writeLit('/');
    _SEMIKOLON: writeLit(');');
    _EOF: Error(true,'Kildeteksten kan ikke slutte her!');
    otherwise   writeTok;
    end;
  until token.tok=_SEMIKOLON;
end;

procedure convertFile(InpName,OutName: strL);
var
  ok: boolean;
  ch: char;
begin
  ClearUsedFlags;
  Upcase(InpName);
  Upcase(OutName);
  Error(InpName=OutName,'ind og ud-filnavn er den samme');
  assign(InpF,InpName);
  {$I-} reset(InpF); {$I+}
  Error((iores<>0),'Input fil: "'+InpName+'" ikke fundet');
  assign(OutF,OutName);
  {$I-} reset(OutF); {$I+}
  if iores=0 then
  begin
    repeat
      write('Filen: ',OutName,' findes allerede, skal den overskrives (J/N)? ');
      readln(ch);
    until ch in ['j','J','n','N','y','Y'];
    if ch in ['n','N'] then halt;
  end;
  close(OutF);
  
  {$I-} rewrite(OutF); {$I+}
  Error((iores<>0),'Output fil: "'+OutName+'" kan ikke laves paa disken');
  digits:=['0'..'9'];
  letters:=['a'..'z','A'..'Z','_'];
  diglet:=letters+digits;
  KommentarAktiv:=notActiv;
  NextLineComment:='';
  OutString:='';
  inpLinePtr:=1; inpLine[inpLinePtr]:=@0;
  writeLit('{$R+ Standard i PPAS }'@13);
  SkipCh;
  ok:=false;
  repeat
    scan;
    if token.searchNo>=MinString then
    begin
      token.orgstr:=StringBuf^[token.searchNo].s2;
      if StringBuf^[token.searchNo].s3<>'' then
        NextLineComment:=StringBuf^[token.searchNo].s3;
    end;
    case token.tok of
    _CODE:      cvtCode;
    _COMMAT:    writeLit('#');
    _EOF:       ok:=true;
    otherwise   writeTok;
    end;
    case KommentarAktiv of
    notActiv:           write(inton);
    Tuborg,Dobbel:      write(intoff);
    end;
  until ok or (lastCh=@0);
  if OutString<>'' then flushLit;
  close(InpF);
  close(OutF);
  TestUsedFlags;
end;

begin
  ehofs:=ofs(errorHandler);
  Error(argcnt<2,'For f† argumenter til programmet');
  InitTable;
  convertFile(argstr(1),argstr(2));
end.
