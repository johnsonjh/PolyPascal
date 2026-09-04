program MakeBatFileFromDirectoryList;
{ Dette program tager en fil der er lavet med
  DOS'ens DIR kommando, og omdanner den til en
  .bat fil der ser ud som f›lger:
  PPAS_T3 filnavn path\filnavn
  hvor filnavn udskiftes med hvad der st†r i filen
  i forvejen, og hvor path er det nuv‘rende bibliotek.
  Filer med l‘ngden 0 og filer med extention .BAK bruges ikke!
  
  Fra kommando linje udf›res:
  C:>DIR >batfil.bat
  k›r derefter dette program s†ledes:
  C:>MakeBatF batfil.bat
  Med PPAS editoren kan batfil.bat nu ‘ndres
  til det ›nskede. F.eks. kan path ‘ndres s†ledes at
  PPAS_T3 programmet vil fylde et nyt bibliotek med
  de ny konverterede pascal programmer.
  
  Et eksempel:
  C:>PROMPT $P$G
  C:\PSOURCE>DIR *.PAS >MAIN.BAT
  C:\PSOURCE>DIR *.INC >INC.BAT
  C:\PSOURCE>MAKEBATF MAIN.BAT
  C:\PSOURCE>MAKEBATF INC.BAT
  
  Nu vil MAIN.BAT f.eks. indeholde:
PPAS_T3 TEST.PAS       C:\PSOURCE\TEST.PAS
PPAS_T3 NYTEST.PAS     C:\PSOURCE\NYTEST.PAS
  
  Dette kan med editoren nu ‘ndres til
PPAS_T3 TEST.PAS       C:\TEST\TEST.PAS
PPAS_T3 NYTEST.PAS     C:\TEST\NYTEST.PAS
  hvis der f›rst er oprettet et nyt bibliotek TEST med
  C:\PSOURCE>md \TEST
  
  Det kunne ogs† v‘re ‘ndret til 
PPAS_T3 TEST.PAS       A:\TEST.PAS
PPAS_T3 NYTEST.PAS     A:\NYTEST.PAS
  hvis de nye filer skal anbringes p† floppy, medens harddisken
  lades ur›rt.
  
  Det kunne ogs† v‘re ‘ndret til 
PPAS_T3 TEST.PAS       C:\PSOURCE\TEST.PPA
PPAS_T3 NYTEST.PAS     C:\PSOURCE\NYTEST.PPA
  hvis de nye filer skal ligge i samme bibliotek som de gamle.
  
  P† samme m†de kan INC.BAT ‘ndres.
  
  Herefter startes konverteringen ved blot at skrive
  navnet p† bat filen p† kommandolinjen.
  C:\PSOURCE>MAIN
  C:\PSOURCE>INC
  
  Programmet kan desuden ‘ndres til at lave andre former 
  for filer. F.eks:
  RENAME TEST.PAS TEST.OLD              eller
  COPY   TEST.PAS A:                    etc

}

CONST
  MaxLines= 250;     { Max antal linjer i den indl‘ste fil! }

TYPE
  strL= string[127]; { Max l‘ngde for hver linje! }

VAR
  InLine,OutLine: array[0..MaxLines] of strL;
  inLineNo,outLineNo: integer;
  L,dir: strL;
  n: integer;
  F: text;

procedure error(error: boolean; s: strL);
begin
  if error then
  begin
    writeln(s);
    halt;
  end;
end;

procedure errorX(B: boolean);
begin
  error(B,'Filen ser ikke rigtig ud')
end;

begin
  gcdir(0,dir); if dir[len(dir)]<>'\' then dir:=dir+'\';
  
  error(argcnt<>1,'kun et argument til programmet tak');
  {$I-} assign(F,argstr(1)); reset(F); {$I+}
  error(iores<>0,'Fil kan ikke aabnes');
  
  { L‘s filen }
  InLineNo:=-1;
  while not eof(F) do
  begin
    InLineNo:=InLineNo+1;
    readln(F,inLine[InLineNo]);
  end;
  close(F);
  
  { Kontroller }
  errorX(inLine[0]<>'');
  errorX(copy(inLine[1],1,17)<>' Volume in drive ');
  errorX(copy(inLine[2],1,15)<>' Directory of  ');
  errorX(inLine[3]<>'');
  errorX(copy(inLine[InLineNo],11,7)<>'File(s)');
  
  { Udv‘lg gode linjer }
  outLineNo:=-1;
  for n:=0 to InLineNo do
  begin
    L:=inLine[n];
    if (L<>'') and
       (copy(L,1,1)<>' ') and           { skip kommentar linjer }
       (copy(L,14,1)=' ') and           { skip filer med m‘rke <DIR> etc }
       (copy(L,15,9)<>'      0  ') and  { Skip filer med l‘ngde 0 }
       (copy(L,10,3)<>'BAK') then       { Skip .BAK }
    begin
      L:=copy(L,1,12);
      while pos('  ',L)>0 do delete(L,pos(' ',L),1);
      if pos(' ',L)<>len(L) then L[pos(' ',L)]:='.';
      outLineNo:=outLineNo+1;
      outLine[outLineNo]:=L;
    end;
  end;
  error(outLineNo<0,'Ingen filer i listen');
  
  { Konverter alle gode linjer }
  for n:=0 to outLineNo do
  begin
    L:='PPAS_T3 '+outLine[n];
    while len(L)<25 do L:=L+' ';
    L:=L+@9' '; { Tab tegn+space (er god at s›ge p†) }
    outLine[n]:=L+dir+outLine[n]+@9; { Endnu et tab tegn }
  end;
  
  {$I-} assign(F,argstr(1)); rewrite(F); {$I+}
  error(iores<>0,'Fil kan ikke †bnes for skrivning');
  
  { Skriv tilbage i samme fil }
  for n:=0 to outLineNo do writeln(F,outLine[n]);
  close(F);
end.
