PROGRAM database; {$A+,C-,R-,V-}


{***************************************************************}
{                                                               }
{                    PolyFile Version 1.10                      }
{                                                               }
{                       DATABASE Example                        }
{                                                               }
{                      Copyright (C) 1986                       }
{                  PolyTech International A/S                   }
{                                                               }
{***************************************************************}


{ DATABASE demonstrates how to use PolyFile to create and main- }
{ tain a simple customer data base. DATABASE allows you to add, }
{ find, view, edit, delete and list customers of a predefined   }
{ type (see the CUSTREC type definition below).                 }

{ DATABASE maintains three files: A data file (CUST.DAT), a     }
{ customer code index (CUST.IXC) and a name index (CUST.IXN).   }
{ The customer code index does not allow duplicate keys,        }
{ whereas the name index does. When DATABASE is run for the     }
{ first time, it will automatically create an empty data base.  }

{ The main menu offers three functions: U)pdate, L)ist and      }
{ Q)uit. U)pdate is used to add, find, view, edit and delete    }
{ customers. L)ist is used to list customers, and Q)uit is used }
{ to terminate the program.                                     }

{ On the U)pdate menu, The A)dd function is used to add new     }
{ customers. F)ind is used to locate a customer, either by cus- }
{ tomer code or by last (and first) name. To search for a spe-  }
{ cific customer code, simply enter it when the cursor moves to }
{ the customer code field. If it is found, the customer's data  }
{ is displayed and you may, if you wish, E)dit or D)elete it.   }
{ To search for a name, enter an empty customer code. Then      }
{ enter the last name and optionally the first name. Note that  }
{ if a first name is specified, the first 15 characters of the  }
{ last name must be entered in full. The scan will locate the   }
{ first customer of the specified name or the first customer    }
{ that follows the specified name if no exact match occurs. You }
{ may then use N)ext and P)revious to move forwards and back-   }
{ wards in alphabetical order. Once you have located the wanted }
{ customer, enter Q)uit. You may then E)dit or D)elete the      }
{ record shown on the screen, or simply leave it unchanged.     }

{ L)ist is used to list customers. Listings will show the cus-  }
{ tomer code, the name and the company. They may be output to   }
{ the P)rinter or to the S)creen, and they may be U)nsorted or  }
{ sorted by customer C)ode or N)ame.                            }

{ For further comments, read through this source code.          }


LABEL stop;

CONST

{ Data record size definition }

  crsize = 342;         { Customer record size }

{ PolyFile constants }

  maxrsize = crsize;    { Max record size }
  maxksize = 25;        { Max key size }
  nodesize = 16;        { Node size }
  nodehalf = 8;         { Half node size }
  nbufsize = 5;         { Node buffer size }
  maxdepth = 5;         { Max index depth }

{ Include PolyFile modules }

{$I DATMAN}
{$I NPFKEY}
{$I ADDKEY}
{$I DELKEY}

TYPE

{ Various string types }

  str5 = STRING[5];
  str10 = STRING[10];
  str15 = STRING[15];
  str25 = STRING[25];
  str80 = STRING[80];
  anystr = STRING[255];

{ Character set type }

  charset = SET OF char;

{ Customer record definition }

  custrec = RECORD
              status: integer;       { Status }
              ccode: STRING[15];     { Customer code }
              cdate: STRING[8];      { Entry date }
              fname: STRING[15];     { First name }
              lname: STRING[30];     { Last name }
              cmpny: STRING[40];     { Company }
              addr1: STRING[40];     { Address 1 }
              addr2: STRING[40];     { Address 2 }
              phone: STRING[15];     { Phone number }
              pextn: STRING[5];      { Extension }
              rmrk1: STRING[40];     { Remarks 1 }
              rmrk2: STRING[40];     { Remarks 2 }
              rmrk3: STRING[40];     { Ramarks 3 }
            END;

VAR

{ Global variables }

  datf: datafile;
  idxc,idxn: indexfile;
  ch: char;

{ CAP converts a character to upper case }

FUNCTION cap(ch: char): char;
BEGIN
  IF (ch>='a') AND (ch<='z') THEN
  cap:=chr(ord(ch)-32) ELSE cap:=ch;
END;

{ CPAS converts a string to upper case }

FUNCTION caps(s: str80): str80;
VAR
  p: integer;
BEGIN
  FOR p:=1 TO len(s) DO s[p]:=cap(s[p]);
  caps:=s;
END;

{ CSTR returns a string with N characters of value C }

FUNCTION cstr(c: char; n: integer): str80;
VAR
  s: STRING[80];
BEGIN
  IF n<0 THEN n:=0; s[0]:=chr(n); fill(s[1],n,c);
  cstr:=s;
END;

{ BEEP sounds the terminal's bell or beeper }

PROCEDURE beep;
BEGIN
  write(^G);
END;

{ INPSTR is a generalized string input routine which supports   }
{ on-screen editing. S is any string variable. L is the maximum }
{ input length. X and Y are the display coordinates. TERM is a  }
{ set of valid terminator characters, and TC returns the char-  }
{ acter that terminated the input. On entry, S is displayed at  }
{ X,Y on the screen, padded to the right with underscores. The  }
{ string may then be edited using standard control keys: ^S and }
{ ^D for left and right, ^A and ^F for beginning and end of     }
{ line, ^G to delete the character under the cursor, ^H or DEL  }
{ to backspace, and ^Y to delete to end of the line. When a     }
{ character is typed, it is inserted at the cursor at the re-   }
{ mainder of the line is moved to the right. When a terminator  }
{ character is typed, the trailing underscors are removed, and  }
{ INPSTR returns with the edited string in S and the terminator }
{ character in TC.                                              }

PROCEDURE inpstr(VAR s: anystr; l,x,y: integer;
  term: charset; VAR tc: char);
CONST
  fc = '_';
VAR
  p: integer;
  ch: char;
BEGIN
  gotoxy(x,y); write(s,cstr(fc,l-len(s))); p:=0;
  REPEAT
    gotoxy(x+p,y); read(kbd,ch);
    CASE ch OF
      @32..@126:
      IF p<l THEN
      BEGIN
        IF len(s)=l THEN delete(s,l,1);
        p:=p+1; insert(ch,s,p);
        write(copy(s,p,l));
      END ELSE beep;
      ^S: IF p>0 THEN p:=p-1 ELSE beep;
      ^D: IF p<len(s) THEN p:=p+1 ELSE beep;
      ^A: p:=0;
      ^F: p:=len(s);
      ^G:
      IF p<len(s) THEN
      BEGIN
        delete(s,p+1,1); write(copy(s,p+1,l),fc);
      END;
      ^H,@127:
      IF p>0 THEN
      BEGIN
        delete(s,p,1); write(^H,copy(s,p,l),fc); p:=p-1;
      END ELSE beep;
      ^Y:
      BEGIN
        write(cstr(fc,len(s)-p)); delete(s,p+1,l);
      END;
    OTHERWISE
      IF NOT(ch IN term) THEN beep;
    END;
  UNTIL ch IN term;
  p:=len(s); gotoxy(x+p,y); write('':l-p);
  tc:=ch;
END;

{ SELECT display the prompt string PR on line 22, and waits     }
{ until the user enters a character which is contained in the   }
{ TERM character set. The character is then returned in TC.     }

PROCEDURE select(pr: str80; term: charset; VAR tc: char);
VAR
  ch: char;
BEGIN
  gotoxy(0,22); write(pr,'? ',clreol);
  REPEAT
    read(kbd,ch); tc:=cap(ch);
    IF NOT(tc IN term) THEN beep;
  UNTIL tc IN term;
  write(ch);
END;

{ CLRFRAME clears the display frame, i.e. lines 3 to 20 }

PROCEDURE clrframe;
VAR
  i: integer;
BEGIN
  FOR i:=3 TO 20 DO
  BEGIN
    gotoxy(0,i); write(clreol);
  END;
END;

{ OUTFORM displays the entry form on the screen }

PROCEDURE outform;
BEGIN
  gotoxy(6,4); write('Code:');
  gotoxy(28,4); write('Date:');
  gotoxy(0,6); write('First Name:');
  gotoxy(28,6); write('Last Name:');
  gotoxy(3,8); write('Company:');
  gotoxy(1,9); write('Address 1:');
  gotoxy(1,10); write('Address 2:');
  gotoxy(5,12); write('Phone:');
  gotoxy(28,12); write('Extension:');
  gotoxy(1,14); write('Remarks 1:');
  gotoxy(1,15); write('Remarks 2:');
  gotoxy(1,16); write('Remarks 3:');
END;

{ CLRFORM clears all fields in the entry form }

PROCEDURE clrform;
BEGIN
  gotoxy(12,4); write('':15); gotoxy(34,4); write(clreol);
  gotoxy(12,6); write('':15); gotoxy(39,6); write(clreol);
  gotoxy(12,8); write(clreol); gotoxy(12,9); write(clreol);
  gotoxy(12,10); write(clreol); gotoxy(12,12); write('':15);
  gotoxy(39,12); write(clreol); gotoxy(12,14); write(clreol);
  gotoxy(12,15); write(clreol); gotoxy(12,16); write(clreol);
END;

{ INPCUST is used for inputting customer records. The routine   }
{ assumes that the entry form is already displayed and filled   }
{ in with the default data contained in CUSTREC. Apart from the }
{ control characters supported by INPSTR, the user may type ^E  }
{ to move to the previous field, RETURN, ^I or ^X to move to    }
{ the next field. INPCUST returns when the user types ^Z or     }
{ RETURN when the cursor is in the last field.                  }

PROCEDURE inpcust(VAR cust: custrec);
CONST
  term: charset = [^E,^I,^M,^X,^Z];
VAR
  l: integer;
  tc: char;
BEGIN
  l:=1;
  WITH cust DO
  REPEAT
    CASE l OF
      1: inpstr(ccode,15,12,4,term,tc);
      2: inpstr(cdate,8,34,4,term,tc);
      3: inpstr(fname,15,12,6,term,tc);
      4: inpstr(lname,30,39,6,term,tc);
      5: inpstr(cmpny,40,12,8,term,tc);
      6: inpstr(addr1,30,12,9,term,tc);
      7: inpstr(addr2,30,12,10,term,tc);
      8: inpstr(phone,15,12,12,term,tc);
      9: inpstr(pextn,5,39,12,term,tc);
      10: inpstr(rmrk1,40,12,14,term,tc);
      11: inpstr(rmrk2,40,12,15,term,tc);
      12: inpstr(rmrk3,40,12,16,term,tc);
    END;
    IF (tc=^I) OR (tc=^M) OR (tc=^X) THEN
    IF l=12 THEN l:=1 ELSE l:=l+1 ELSE
    IF tc=^E THEN
    IF l=1 THEN l:=12 ELSE l:=l-1;
  UNTIL (tc=^M) AND (l=1) OR (tc=^Z);
END;

{ OUTCUST displays the customer data contained in CUST }

PROCEDURE outcust(VAR cust: custrec);
BEGIN
  WITH cust DO
  BEGIN
    gotoxy(12,4); write(ccode,'':15-len(ccode));
    gotoxy(34,4); write(cdate,clreol);
    gotoxy(12,6); write(fname,'':15-len(fname));
    gotoxy(39,6); write(lname,clreol);
    gotoxy(12,8); write(cmpny,clreol);
    gotoxy(12,9); write(addr1,clreol);
    gotoxy(12,10); write(addr2,clreol);
    gotoxy(12,12); write(phone,'':15-len(phone));
    gotoxy(39,12); write(pextn,clreol);
    gotoxy(12,14); write(rmrk1,clreol);
    gotoxy(12,15); write(rmrk2,clreol);
    gotoxy(12,16); write(rmrk3,clreol);
  END;
END;

{ KEYN converts a last name and a first name to a key string.   }
{ The key string consists of the first 15 characters of the     }
{ last name (padded with blanks if required) followed by the    }
{ first 10 characters of the first name.                        }

FUNCTION keyn(ln: str15; fn: str10): str25;
CONST
  blanks = '               ';
BEGIN
  keyn:=caps(ln)+copy(blanks,1,15-len(ln))+caps(fn);
END;

{ UPDATE is used to update the data base }

PROCEDURE update;
VAR
  ch: char;

{ ADD is used to add customers }

PROCEDURE add;
VAR
  d: integer;
  cc: STRING[15];
  kn: STRING[25];
  cust: custrec;
BEGIN
  WITH cust DO
  BEGIN
    fill(cust,size(cust),0);
    REPEAT
      inpcust(cust); cc:=ccode; findkey(idxc,d,cc);
      IF ok THEN
      BEGIN
        gotoxy(5,18);
        write('ERROR: DUPLICATE CUSTOMER CODE'); beep;
      END;
    UNTIL NOT ok;
    addrec(datf,d,cust); addkey(idxc,d,ccode);
    kn:=keyn(lname,fname); addkey(idxn,d,kn);
    gotoxy(5,18); write(clreol);
  END;
END;

{ FIND is used to find, edit and delete customers }

PROCEDURE find;
VAR
  d,l,i: integer;
  ch,tc: char;
  cc,pc,fn: STRING[15];
  kn,pn: STRING[25];
  ln: STRING[30];
  cust: custrec;
BEGIN
  IF usedrecs(datf)>0 THEN
  BEGIN
    cc:='';
    REPEAT
      inpstr(cc,15,12,4,[^M,^Z],tc);
      IF cc<>'' THEN
      BEGIN
        findkey(idxc,d,cc);
        IF ok THEN
        BEGIN
          getrec(datf,d,cust); outcust(cust);
        END ELSE
        BEGIN
          gotoxy(5,18);
          write('ERROR: CUSTOMER CODE NOT FOUND'); beep;
        END;
      END;
    UNTIL ok OR (cc='');
    gotoxy(5,18); write(clreol);
    IF cc='' THEN
    BEGIN
      l:=1; fn:=''; ln:='';
      REPEAT
        CASE l OF
          1: inpstr(fn,15,12,6,[^I,^M,^Z],tc);
          2: inpstr(ln,30,39,6,[^I,^M,^Z],tc);
        END;
        IF (tc=^I) OR (tc=^M) THEN l:=3-l;
      UNTIL (tc=^M) AND (l=1) OR (tc=^Z);
      kn:=keyn(ln,fn); searchkey(idxn,d,kn);
      IF NOT ok THEN prevkey(idxn,d,kn);
      REPEAT
        getrec(datf,d,cust); outcust(cust);
        select('Find: N)ext, P)revious, Q)uit',['N','P','Q'],ch);
        CASE ch OF
          'N': REPEAT nextkey(idxn,d,kn) UNTIL ok;
          'P': REPEAT prevkey(idxn,d,kn) UNTIL ok;
        END;
      UNTIL ch='Q';
    END;
    select('Find: E)dit, D)elete, Q)uit',['E','D','Q'],ch);
    WITH cust DO
    CASE ch OF
      'E':
      BEGIN
        pc:=ccode; pn:=keyn(lname,fname);
        REPEAT
          inpcust(cust);
          IF ccode=pc THEN ok:=false ELSE
          BEGIN
            cc:=ccode; findkey(idxc,i,cc); IF ok THEN beep;
          END;
        UNTIL NOT ok;
        putrec(datf,d,cust);
        IF ccode<>pc THEN
        BEGIN
          deletekey(idxc,d,pc); addkey(idxc,d,ccode);
        END;
        kn:=keyn(lname,fname);
        IF kn<>pn THEN
        BEGIN
          deletekey(idxn,d,pn); addkey(idxn,d,kn);
        END;
      END;
      'D':
      BEGIN
        deletekey(idxc,d,ccode);
        kn:=keyn(lname,fname); deletekey(idxn,d,kn);
        deleterec(datf,d);
      END;
    END;
  END ELSE beep;
END;

BEGIN {UPDATE}
  outform;
  REPEAT
    select('Update: A)dd, F)ind, Q)uit',['A','F','Q'],ch);
    CASE ch OF
      'A': add;
      'F': find;
    END;
    IF ch<>'Q' THEN
    BEGIN
      gotoxy(59,1); write(usedrecs(datf):5); clrform;
    END;
  UNTIL ch='Q';
END;

{ LIST is used to list customers }

PROCEDURE list;
LABEL escape;
VAR
  d,l,ld: integer;
  ch,co,cs: char;
  cc: STRING[15];
  kn: STRING[25];
  name: STRING[35];
  cust: custrec;
BEGIN
  select('Output Device: P)rinter, S)creen',['P','S'],co);
  select('Sort By: C)ode, N)ame, U)nsorted',['C','N','U'],cs);
  gotoxy(0,22); write('Press <ESC> to abort',clreol);
  clearkey(idxc);
  clearkey(idxn);
  d:=0; ld:=filelen(datf)-1; l:=3;
  REPEAT
    IF keypress THEN
    BEGIN
      read(kbd,ch); IF ch=@27 THEN GOTO escape;
    END;
    CASE cs OF
      'C': nextkey(idxc,d,cc);
      'N': nextkey(idxn,d,kn);
      'U':
      BEGIN
        ok:=false;
        WHILE (d<ld) AND NOT ok DO
        BEGIN
          d:=d+1; getrec(datf,d,cust);
          ok:=cust.status=0;
        END;
      END;
    END;
    IF ok THEN WITH cust DO
    BEGIN
      IF cs<>'U' THEN getrec(datf,d,cust);
      name:=lname;
      IF fname<>'' THEN name:=name+', '+fname;
      IF co='P' THEN
      BEGIN
        write(lst,ccode,'':16-len(ccode));
        write(lst,name,'':36-len(name));
        writeln(lst,copy(cmpny,1,25));
      END ELSE
      BEGIN
        IF l=21 THEN
        BEGIN
          gotoxy(0,22);
          write('Press <RETURN> to continue or <ESC> to abort',clreol);
          REPEAT read(kbd,ch) UNTIL (ch=^M) OR (ch=@27);
          IF ch=@27 THEN GOTO escape;
          gotoxy(0,22); write('Press <ESC> to abort',clreol);
          clrframe; l:=3;
        END;
        gotoxy(0,l); write(ccode);
        gotoxy(16,l); write(name);
        gotoxy(52,l); write(copy(cmpny,1,25));
        l:=l+1;
      END;
    END;
  UNTIL NOT ok;
  IF co='S' THEN
  BEGIN
    gotoxy(0,22); write('Press <RETURN>',clreol);
    REPEAT read(kbd,ch) UNTIL ch=^M;
  END;
  escape:
END;

{ Main program }

BEGIN
  writeln(clrhom,cstr('-',79));
  writeln('PolyFile Customer Data Base');
  writeln(cstr('-',79));
  gotoxy(0,21); writeln(cstr('-',79));
  writeln; write(cstr('-',79)); gotoxy(0,3);
  initindex;
  openfile(datf,'CUST.DAT',crsize);
  IF ok THEN openindex(idxc,'CUST.IXC',15,0);
  IF ok THEN openindex(idxn,'CUST.IXN',25,1);
  IF NOT ok THEN
  BEGIN
    select('Data files missing. Create new files (Y/N)',['Y','N'],ch);
    IF ch='Y' THEN
    BEGIN
      makefile(datf,'CUST.DAT',crsize);
      makeindex(idxc,'CUST.IXC',15,0);
      makeindex(idxn,'CUST.IXN',25,1);
    END ELSE
    GOTO stop;
  END;
  gotoxy(59,1); write(usedrecs(datf):5,' Records In Use');
  REPEAT
    select('Select: U)pdate, L)ist, Q)uit',['U','L','Q'],ch);
    CASE ch OF
      'U': update;
      'L': list;
    END;
    IF ch<>'Q' THEN clrframe;
  UNTIL ch='Q';
  closefile(datf);
  closeindex(idxc);
  closeindex(idxn);
  stop:
  write(clrhom);
END.
