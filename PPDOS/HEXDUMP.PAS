PROGRAM hexdump; {$R-,K-}

{ This program will output a hex dump af any disk file. Each    }
{ line shows the address of the first byte of the line, then 16 }
{ bytes in hex, and then the same bytes in ASCII, if they are   }
{ printable. On running the program, you must specify the name  }
{ of the disk file to be dumped, and the name of the disk file  }
{ or logical device (CON:, LST:, etc.) to recieve the dump.     }

TYPE
  sector = ARRAY[0..127] OF byte;
  hexstring = STRING[4];

VAR
  address,i,m,n,p: integer;
  ch: char;
  buffer: sector;
  infile: FILE;
  outfile: text;

FUNCTION hex(number,digits: integer): hexstring;
CONST
  hexdigit: ARRAY[0..15] OF char = '0123456789ABCDEF';
VAR
  d: integer;
  h: hexstring;
BEGIN
  h[0]:=chr(digits);
  FOR d:=digits DOWNTO 1 DO
  BEGIN
    h[d]:=hexdigit[number AND 15];
    number:=number SHR 4;
  END;
  hex:=h;
END;

BEGIN
  IF (argcnt<1) OR (argcnt>2) THEN
  BEGIN
    writeln('Syntax: HEXDUMP <infile> [<outfile>]'); halt;
  END;
  assign(infile,argstr(1)); {$I-} reset(infile,1) {$I+};
  IF iores>0 THEN
  BEGIN
    writeln('HEXDUMP: "',argstr(1),'" does not exist'); halt;
  END;
  IF argcnt=2 THEN
  assign(outfile,argstr(2)) ELSE
  assign(outfile,'CON:');
  rewrite(outfile);
  address:=0;
  REPEAT
    blockread(infile,buffer,size(sector),n);
    i:=0;
    WHILE i<n DO
    BEGIN
      m:=n-i; IF m>16 THEN m:=16;
      write(outfile,hex(address,4),' ');
      FOR p:=0 TO pred(m) DO
      BEGIN
        IF p=8 THEN write(outfile,' ');
        write(outfile,hex(buffer[i+p],2):3);
      END;
      write(outfile,'':(16-m)*3+(16-m) DIV 8+2);
      FOR p:=0 TO pred(m) DO
      BEGIN
        ch:=chr(buffer[i+p]);
        IF (ch>=@32) AND (ch<=@126) THEN
        write(outfile,ch) ELSE write(outfile,'.');
      END;
      writeln(outfile);
      i:=i+m; address:=address+m;
    END;
  UNTIL n=0;
  close(infile); close(outfile);
END.
