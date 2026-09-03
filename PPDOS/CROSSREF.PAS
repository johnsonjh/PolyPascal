PROGRAM crossref; {$R-,K-}

{ This program will generate a cross reference map of any Poly- }
{ Pascal program, i.e. a map that lists all identifiers used    }
{ within the program as well as the line numbers of all lines   }
{ that contain references to the identifiers. Optionally, a     }
{ source listing with line numbers may be output.               }

{ On processing the input file, all identifiers are extracted   }
{ and compared with the reserved words of PolyPascal. If an     }
{ identifier is not a reserved word, it is entered into a       }
{ binary tree. Each entry in the binary tree contains a pointer	}
{ to the identifier, and a left node and a right node pointer   }
{ to subsequent entries (or NIL if no entries follow). Further- }
{ more, an entry contains a pointer to the first record in a    }
{ line number reference chain, and a pointer to the last record }
{ in that chain. When an identifier is entered into the tree    }
{ for the first time, the program allocates both a new identi-  }
{ fier record and a line number reference record. Subsequent    }
{ references to that identifier will then expand the line num-  }
{ ber reference chain, provided that the line number is not the }
{ same as that of the last reference.                           }

{ When all lines have been processed, the program traverses the }
{ binary tree, printing all identifiers along with the numbers  }
{ of the lines within which they are referenced.                }

CONST

{ Various constants }

  maxdots = 50;		{ Max number of dots per line on CRT }
  nofrwords = 44;	{ Number of reserved words }
  formfeed = ^L;	{ Form-feed character }

{ Table of reserved words }

  rwords: ARRAY[1..nofrwords] OF STRING[9] = (
    'LABEL','ELSE','CASE','AT','AND','ARRAY','BEGIN','DIV','CODE',
    'CONST','DO','DOWNTO','FOR','EXTERNAL','END','EXOR','FILE','GOTO',
    'FORWARD','FUNCTION','IF','IN','REPEAT','OTHERWISE','NOT','MOD',
    'NIL','OF','OR','PROGRAM','PACKED','PROCEDURE','RECORD','TO','SHR',
    'SET','SHL','STRING','THEN','VAR','TYPE','UNTIL','WHILE','WITH');

TYPE

{ Identifier types }

  identptr = ^ident;
  ident = STRING[32];

{ Line record types. Each line record contains the number of a  }
{ line, within which a given identifier is referenced, and a    }
{ pointer to the next line record.                              }

  linerecptr = ^linerec;
  linerec = RECORD
	      number: integer;
	      next: linerecptr;
	    END;

{ Identifier record types. Each identifier record contains a    }
{ pointer to the identifier string, a pointer to the first and  }
{ the last line record in the reference chain, and a left node  }
{ and a right node pointer to subsequent entries in the binary  }
{ tree.                                                         }

  identrecptr = ^identrec;
  identrec = RECORD
	       id: identptr;
	       reserved: boolean;
	       firstline,lastline: linerecptr;
	       left,right: identrecptr;
	     END;

{ Source line type. The maximum length of a source line is 127  }
{ characters.                                                   }

  sourceline = STRING[127];

VAR

{ Global variables.						}

  linenumber,           { Current line number }
  nofidents,            { Number of identifiers processed }
  linepos,              { Position within current line }
  linelen: integer;     { Length of current line }
  ch: char;             { Current character }
  inopen,               { True if input file open }
  outopen,              { True if output file open }
  listing,              { True if source listing requested }
  error: boolean;       { Error flag }
  line: sourceline;     { Current source line }
  idtree: identrecptr;  { Root of cross reference tree }
  infile: text[4096];   { Input file }
  outfile: text;        { Output file }

{ FREEMEM returns the number of bytes available on the heap.    }
{ The result type is real to allow for values outside the inte- }
{ ger range.                                                    }

FUNCTION freemem: real;
BEGIN
  IF memavail>0 THEN
  freemem:=memavail*16.0 ELSE
  freemem:=65536.0-memavail*16.0;
END;

{ NEXTCH reads the next character from the input file into CH.  }
{ If a source listing was requested, NEXTCH lists input lines   }
{ to the output file as they are read. Otherwise, a dot is      }
{ printed on the console for each line read. A ^Z character is  }
{ returned on reaching the end of the input file.               }

PROCEDURE nextch;
VAR
  p,t: integer;
BEGIN
  IF (linepos<=linelen) THEN
  BEGIN
    ch:=line[linepos]; linepos:=linepos+1;
    IF (ch>='a') AND (ch<='z') THEN ch:=chr(ord(ch)-32);
  END ELSE
  IF NOT eof(infile) THEN
  BEGIN
    readln(infile,line); linenumber:=linenumber+1;
    IF listing THEN
    BEGIN
      write(outfile,'<',linenumber:5,'> ');
      t:=8;
      FOR p:=1 TO len(line) DO
      IF line[p]<>^I THEN
      BEGIN
	write(outfile,line[p]); t:=t-1; IF t=0 THEN t:=8;
      END ELSE
      BEGIN
	write(outfile,'':t); t:=8;
      END;
      writeln(outfile);
    END ELSE
    BEGIN
      write('.');
      IF linenumber MOD maxdots=0 THEN writeln;
    END;
    linelen:=len(line); linepos:=1; ch:=' ';
  END ELSE
  ch:=^Z;
END;

{ ENTERID enters NEWID into the cross reference binary tree.    }
{ Note that an identifier record is allocated only if the iden- }
{ tifier is not already within the tree. Also note the use of   }
{ the ALLOCATE procedure to allocate only the required number   }
{ of bytes for the identifier instead of the maximum length.    }

PROCEDURE enterid(newid: ident; rword: boolean);
VAR
  x: linerecptr;

PROCEDURE enter(VAR root: identrecptr);
BEGIN
  IF root=NIL THEN
  BEGIN
    new(root);
    WITH root^ DO
    BEGIN
      allocate(id,len(newid)+1); id^:=newid;
      reserved:=rword;
      IF NOT reserved THEN
      BEGIN
        new(firstline);
        firstline^.number:=linenumber; firstline^.next:=NIL;
        lastline:=firstline;
        nofidents:=nofidents+1;
      END;
      left:=NIL; right:=NIL;
    END;
  END ELSE
  IF newid<root^.id^ THEN enter(root^.left) ELSE
  IF newid>root^.id^ THEN enter(root^.right) ELSE
  WITH root^ DO
  IF NOT reserved THEN
  IF linenumber<>lastline^.number THEN
  BEGIN
    new(x); x^.number:=linenumber; x^.next:=NIL;
    lastline^.next:=x;
    lastline:=x;
  END;
END;

BEGIN {enterid}
  enter(idtree);
END;

{ INITIALIZE is used to initialize input and output files and   }
{ all global variables.                                         }

PROCEDURE initialize;
VAR
  i: integer;
  inname,outname: STRING[64];
  listyn: STRING[1];
BEGIN
  error:=false;
  writeln;
  writeln('      PolyPascal Cross Reference Generator');
  writeln;
  writeln('                  Version 1.1');
  writeln;
  writeln('               Copyright (C) 1986');
  writeln('           PolyTech International A/S');
  writeln;
  writeln;
  write('Input file name (default .PAS)? '); readln(inname);
  write('Output file name (default printer)? '); readln(outname);
  write('Print source listing (Y/N)? '); readln(listyn);
  writeln;
  inopen:=false; outopen:=false;
  IF pos('.',inname)=0 THEN inname:=inname+'.PAS';
  assign(infile,inname); {$I-} reset(infile) {$I+};
  IF iores>0 THEN
  BEGIN
    writeln('Input File Error');
    error:=true; exit;
  END;
  inopen:=true;
  IF outname='' THEN outname:='LST:';
  assign(outfile,outname); {$I-} rewrite(outfile) {$I+};
  IF iores>0 THEN
  BEGIN
    writeln('Output File Error');
    error:=true; exit;
  END;
  outopen:=true;
  listing:=(listyn='Y') OR (listyn='y');
  idtree:=NIL;
  FOR i:=1 TO nofrwords DO enterid(rwords[i],true);
  linenumber:=0; nofidents:=0;
  linepos:=1; linelen:=0; nextch;
END;

{ PROCESSFILE processes the input file, creating a cross refe-  }
{ rence binary tree.                                            }

PROCEDURE processfile;
VAR
  ifree: real;

{ GETSYMBOL reads the next symbol from the input file. If the   }
{ symbol is an identifier, it is processed using PROCESSIDENT   }
{ below.                                                        }

PROCEDURE getsymbol;
CONST
  alphanums: SET OF '0'..'_' = ['0'..'9','A'..'Z','_'];
  hexdigits: SET OF '0'..'F' = ['0'..'9','A'..'F'];

{ PROCESSIDENT reads an identifier and enters it into the cross }
{ reference tree.                                               }

PROCEDURE processident;
VAR
  newid: ident;
BEGIN
  newid:='';
  REPEAT
    newid:=newid+ch; nextch;
  UNTIL NOT(ch IN alphanums);
  enterid(newid,false);
END;

BEGIN {getsymbol}
  CASE ch OF
    'A'..'Z','_': processident;
    '''':
    REPEAT
      REPEAT nextch UNTIL (ch='''') OR (ch=^Z);
      nextch;
    UNTIL ch<>'''';
    '$':
    REPEAT nextch UNTIL NOT(ch IN hexdigits);
    '{':
    BEGIN
      REPEAT nextch UNTIL (ch='}') OR (ch=^Z);
      nextch;
    END;
    '(':
    BEGIN
      nextch;
      IF ch='*' THEN
      BEGIN
        nextch;
        REPEAT
          WHILE (ch<>'*') AND (ch<>^Z) DO nextch;
          nextch;
        UNTIL (ch=')') OR (ch=^Z);
        nextch;
      END;
    END;
  OTHERWISE
    nextch;
  END;
END;

BEGIN {processfile}
  ifree:=freemem;
  WHILE (ch<>^Z) AND (freemem>100.0) DO getsymbol;
  IF NOT listing THEN
  BEGIN
    IF (linenumber MOD maxdots<>0) THEN writeln;
    writeln;
  END;
  IF (freemem<=100.0) THEN
  BEGIN
    writeln('Symbol Table Overflow');
    error:=true;
  END ELSE
  BEGIN
    writeln(linenumber,' lines read from input file.');
    writeln(nofidents,' identifiers processed.');
    writeln(ifree-freemem:0:0,' bytes used, ',freemem:0:0,' free.');
    IF listing THEN write(outfile,formfeed);
  END;
END;

{ PRINTXREF outputs the cross reference map }

PROCEDURE printxref;
VAR
  n: integer;
  x: linerecptr;

{ TRAVERSE traverses the binary tree from "left" to "right",    }
{ printing all identifiers and the numbers of the lines within  }
{ which they are referenced.                                    }

PROCEDURE traverse(root: identrecptr);
BEGIN
  IF root<>NIL THEN
  BEGIN
    traverse(root^.left);
    WITH root^ DO
    IF NOT reserved THEN
    BEGIN
      write(outfile,id^);
      x:=firstline; n:=1;
      REPEAT
	IF n MOD 8=1 THEN writeln(outfile);
	write(outfile,x^.number:8); x:=x^.next; n:=n+1;
      UNTIL x=NIL;
      writeln(outfile);
    END;
    traverse(root^.right);
  END;
END;

BEGIN {printxref}
  traverse(idtree); write(outfile,formfeed);
END;

{ Main program }

BEGIN
  initialize;
  IF NOT error THEN processfile;
  IF NOT error THEN printxref;
  IF inopen THEN close(infile);
  IF outopen THEN close(outfile);
END.
