PROGRAM list; {$C-,K-,R-}

{ LIST is a very useful all-purpose list program. It can output }
{ listings of all sorts of text files, with headers, line num-  }
{ bers, and full control of page length, line length, left mar- }
{ gin and bottom margin. LIST obtains all its parameters from   }
{ the command line. The command line format is:                 }
{                                                               }
{    LIST <filename><options>,...,<filename><options>           }
{                                                               }
{ where <filename> is a file name acceptable to the operating   }
{ system, and <options> are one or more options, selected from  }
{ the following list:                                           }
{                                                               }
{    Pnn     Set page length to nn.                             }
{    Lnn     Set line length to nn.                             }
{    Inn     Indent each line printed by nn blanks.             }
{    Snn     Skip nn lines at the bottom of each page.          }
{    H       Print file name and page number on top of          }
{            each page.                                         }
{    Hsssss  Print header string and page number on top         }
{            of each page.                                      }
{    N       Print line number before each line.                }
{    F       Form-feed. Skip to top of next page.               }
{                                                               }
{ Each option must be preceded by a forward slash. An example   }
{ of a LIST command line:                                       }
{                                                               }
{    LIST WORK.PAS/I8/N/HWorkfile Listing,CALC.PAS,/F           }
{                                                               }
{ This line will cause WORK.PAS to be listed with an indenta-   }
{ tion (left margin) of 8, line numbers and a user specified    }
{ heading. Following this, CALC.PAS is listed using the default }
{ page format parameters, and finally a form-feed is output.    }

CONST
  dpagelen = 72;                {Default page length}
  dlinelen = 74;                {Default line length}
  dindent  = 0;                 {Default indentation}
  dskip    = 6;                 {Default bottom skip}
  cr       = @13;               {Carriage return}
  lf       = @10;               {Linefeed}
  ht       = @9;                {Horizontal tab}
  ff       = @12;               {Formfeed}
  esc      = @27;               {Escape}

VAR
  i,pos,pagelen,linelen,indent,skip,arg,
  pageno,lineno,lin,col,width: integer;
  ch,opt: char;
  printhdr,linenumbers: boolean;
  ns: STRING[4];
  filename,header: STRING[64];
  line: STRING[127];
  infile: text;
  cmdlin: STRING[127] AT cseg:$80;

FUNCTION cap(ch: char): char;
BEGIN
  IF (ch>='a') AND (ch<='z') THEN
  cap:=chr(ord(ch)-32) ELSE cap:=ch;
END;

BEGIN
  pagelen:=dpagelen; linelen:=dlinelen; indent:=dindent;
  skip:=dskip; header:=''; printhdr:=false; linenumbers:=false;
  filename:=''; line:=cmdlin+@0; pos:=1;
  REPEAT
    WHILE line[pos] IN [' ',','] DO pos:=succ(pos);
    WHILE NOT(line[pos] IN [' ',',','/',@0]) DO
    BEGIN
      filename:=filename+line[pos]; pos:=succ(pos);
    END;
    WHILE line[pos]=' ' DO pos:=succ(pos);
    WHILE line[pos]='/' DO
    BEGIN
      pos:=succ(pos); opt:=cap(line[pos]); pos:=succ(pos);
      CASE opt OF
        'P','L','I','S':
        BEGIN
          arg:=0;
          WHILE line[pos] IN ['0'..'9'] DO
          BEGIN
            arg:=arg*10+ord(line[pos])-ord('0');
            pos:=succ(pos);
          END;
          CASE opt OF
            'P': pagelen:=arg;
            'L': linelen:=arg;
            'I': indent:=arg;
            'S': skip:=arg;
          END;
        END;
        'H':
        BEGIN
          WHILE NOT(line[pos] IN [',','/',@0]) DO
          BEGIN
            header:=header+line[pos]; pos:=succ(pos);
          END;
          printhdr:=true;
        END;
        'N': linenumbers:=true;
        'F': FOR i:=1 TO pagelen DO write(lst,lf);
      OTHERWISE
        writeln('Unknown option identifier: "',opt,'"');
        halt;
      END;
      WHILE line[pos]=' ' DO pos:=succ(pos);
    END;
    IF filename<>'' THEN
    BEGIN
      assign(infile,filename);
      {$I-} reset(infile) {$I+};
      IF iores<>0 THEN
      BEGIN
        writeln('File not found: "',filename,'"');
        halt;
      END;
      IF header='' THEN header:='File '+filename;
      pageno:=1; lineno:=1; lin:=0; width:=linelen-indent;
      IF linenumbers THEN width:=width-6;
      WHILE NOT eof(infile) DO
      BEGIN
        IF keypress THEN
        BEGIN
          read(kbd,ch);
          IF ch=esc THEN
          BEGIN
            writeln('Interrupted');
            IF lin<>0 THEN
            FOR i:=lin TO pred(pagelen) DO write(lst,lf);
            halt;
          END;
        END;
        IF printhdr AND (lin=0) THEN
        BEGIN
          write(lst,'':indent,header);
          writeln(lst,'':linelen-indent-len(header)-8,'Page ',pageno);
          write(lst,lf,lf); lin:=3;
        END;
        write(lst,'':indent);
        IF linenumbers THEN
        BEGIN
          str(lineno,ns); write(lst,copy('000',1,4-len(ns)),ns,'  ');
        END;
        col:=0;
        WHILE NOT eoln(infile) DO
        BEGIN
          read(infile,ch);
          CASE ch OF
            @32..@126:
            BEGIN
              IF col<width THEN write(lst,ch);
              col:=succ(col);
            END;
            ht:
            REPEAT
              IF col<width THEN write(lst,' ');
              col:=succ(col);
            UNTIL col MOD 8=0;
            ff:
            IF lin<>0 THEN
            BEGIN
              FOR i:=lin TO pred(pagelen) DO write(lst,lf);
              pageno:=succ(pageno); lin:=0;
            END;
          END;
        END;
        readln(infile); writeln(lst);
        lineno:=succ(lineno); lin:=succ(lin);
        IF lin=pagelen-skip THEN
        BEGIN
          FOR i:=1 TO skip DO write(lst,lf);
          pageno:=succ(pageno); lin:=0;
        END;
      END;
      IF lin<>0 THEN
      FOR i:=lin TO pred(pagelen) DO write(lst,lf);
      filename:=''; header:='';
      printhdr:=false; linenumbers:=false;
    END;
  UNTIL line[pos]=@0;
END.
