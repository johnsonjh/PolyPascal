
{***************************************************************}
{                                                               }
{             MS-DOS FUNCTION CALL SUPPORT ROUTINES             }
{                    for PolyPascal-86 V3.1                     }
{                                                               }
{                      Copyright (C) 1986                       }
{                  PolyTech International A/S                   }
{                                                               }
{***************************************************************}

{ This include file contains a number of subroutines which may  }
{ be used to access verious MS-DOS functions not directly sup-  }
{ ported by PolyPascal. To use the procedures in this file,     }
{ either include the entire file in the compilation of your     }
{ program, or copy the type and variable declarations plus the  }
{ routines you need into your source text.                      }

{$R-}

TYPE
  fnamstr = STRING[63];
  cmdline = STRING[127];
  regpack = RECORD
              ax,bx,cx,dx,bp,si,di,ds,es,flags: integer;
            END;
  fcbname = RECORD
              drive: byte;
              name: ARRAY[1..11] OF char;
            END;
VAR
  regs: regpack;
  dirbuf: RECORD
            rsvd: ARRAY[0..29] OF byte;
            fnam: ARRAY[0..12] OF char;
          END;
  eofdir: boolean;

{ getdate returns the current date set in the operating system. }
{ Ranges of the values returned are: year 1980-2099, month      }
{ 1-12, day 1-31 and dofw (day of week) 0-6 with 0 correspond-  }
{ ing to sunday, 1 to monday, etc.).                            }

PROCEDURE getdate(VAR year,month,day,dofw: integer);
BEGIN
  regs.ax:=$2A00; swint($21,regs);
  year:=regs.cx; month:=hi(regs.dx);
  day:=lo(regs.dx); dofw:=lo(regs.ax);
END;

{ setdate sets the current date in the operating system. Valid  }
{ parameter ranges are: year 1980-2099, month 1-12 and day 1-   }
{ 31. If the date is not valid, the function call is ignored.   }

PROCEDURE setdate(year,month,day: integer);
BEGIN
  regs.ax:=$2B00; regs.cx:=year;
  regs.dx:=swap(month)+day; swint($21,regs);
END;

{ gettime returns the current time set in the operating system. }
{ Ranges of the values returned are: hour 0-23, minute 0-59,    }
{ second 0-59 and sec100 (hundredths of seconds) 0-99.          }

PROCEDURE gettime(VAR hour,minute,second,sec100: integer);
BEGIN
  regs.ax:=$2C00; swint($21,regs);
  hour:=hi(regs.cx); minute:=lo(regs.cx);
  second:=hi(regs.dx); sec100:=lo(regs.dx);
END;

{ settime sets the time in the operating system. Valid parame-  }
{ ter ranges are: hour 0-23, minute 0-59, second 0-59 and       }
{ sec100 (hundredths of seconds) 0-99. If the time is not va-   }
{ lid, the function call is ignored.                            }

PROCEDURE settime(hour,minute,second,sec100: integer);
BEGIN
  regs.ax:=$2D00; regs.cx:=swap(hour)+minute;
  regs.dx:=swap(second)+sec100; swint($21,regs);
END;

{ keep terminates the current program, but keeps it in memory.  }
{ This routine is useful for installing interrupt drivers and   }
{ other resident processes. The code and data segments plus     }
{ whatever has been allocated on the heap are made resident.    }
{ The exit code may be examined from MS-DOS through the ERROR-  }
{ LEVEL batch command.                                          }

PROCEDURE keep(exitcode: integer);
BEGIN
  regs.ax:=$3100+lo(exitcode); regs.dx:=seg(hptr^)-cseg+1;
  swint($21,regs);
END;

{ diskfree returns the free space on disk along with other      }
{ additional information about the disk. drive specifies the    }
{ drive number (0=default, 1=A:, 2=B:, etc.). cla is number of  }
{ clusters available, cpd is clusters per drive, bps is bytes   }
{ per sector and spc is sectors per cluster. The total number   }
{ of bytes per disk is (cpd+0.0)*bps*spc. The number of bytes   }
{ free	is (cla+0.0)*bps*spc. Real zero (0.0) must be added to  }
{ convert the type of the expression to real as an overflow     }
{ would otherwise occur. spc returns -1 if the drive number is  }
{ invalid.                                                      }

PROCEDURE diskfree(drive: integer; VAR cla,cpd,bps,spc: integer);
BEGIN
  regs.ax:=$3600; regs.dx:=drive; swint($21,regs);
  cla:=regs.bx; cpd:=regs.dx; bps:=regs.cx; spc:=regs.ax;
END;

{ getmode returns the attributes of a file. path is a string    }
{ that specifies the drive, path, and filename of the file. The }
{ attribute value of a normal file is 0. Add 1 for read-only,   }
{ 2 for hidden, 4 for system, 8 for volume label, 16 for sub-   }
{ directory, and 32 for archive. If the file is not found, get- }
{ mode returns -1.                                              }

FUNCTION getmode(path: fnamstr): integer;
VAR
  n: integer;
BEGIN
  n:=ord(path[0]); move(path[1],path[0],n); path[n]:=@0;
  regs.ax:=$4300; regs.dx:=ofs(path); regs.ds:=seg(path);
  swint($21,regs); getmode:=regs.cx;
  IF regs.flags AND 1<>0 THEN getmode:=-1;
END;

{ setmode sets the attributes of a file. path is a string that  }
{ specifies the drive, path, and filename of the file, and attr }
{ is an integer that specifies the new attributes (see descrip- }
{ tion of getmode).                                             }

PROCEDURE setmode(path: fnamstr; attr: integer);
VAR
  n: integer;
BEGIN
  n:=ord(path[0]); move(path[1],path[0],n); path[n]:=@0;
  regs.ax:=$4301; regs.cx:=attr; regs.dx:=ofs(path);
  regs.ds:=seg(path); swint($21,regs);
END;

{ initdir initializes a directory read operation. path is a     }
{ string that specifies the drive, path, and filename of the    }
{ file(s) to be found. The filename portion can contain global  }
{ filename characters ('*' and '?'). attr defines the allowed   }
{ attributes (see description of getmode). After a call to      }
{ initdir, the eofdir variable is true if the directory is      }
{ empty, otherwise false. The file names may be read using the  }
{ getdir function below.                                        }

PROCEDURE initdir(path: fnamstr; attr: integer);
VAR
  n: integer;
BEGIN
  regs.ax:=$1A00; regs.dx:=ofs(dirbuf);
  regs.ds:=seg(dirbuf); swint($21,regs);
  n:=ord(path[0]); move(path[1],path[0],n); path[n]:=@0;
  regs.ax:=$4E00; regs.cx:=attr; regs.dx:=ofs(path);
  regs.ds:=seg(path); swint($21,regs);
  eofdir:=regs.flags AND 1<>0;
END;

{ getdir returns the next directory entry. initdir must be      }
{ called before getdir to establish the search file name. If    }
{ eofdir is true, getdir returns an empty string.               }

FUNCTION getdir: fnamstr;
VAR
  n: integer;
  fnam: fnamstr;
BEGIN
  IF eofdir THEN fnam:='' ELSE
  BEGIN
    n:=0; WHILE dirbuf.fnam[n]<>@0 DO n:=succ(n);
    fnam[0]:=chr(n); move(dirbuf.fnam,fnam[1],n);
    regs.ax:=$1A00; regs.dx:=ofs(dirbuf);
    regs.ds:=seg(dirbuf); swint($21,regs);
    regs.ax:=$4F00; swint($21,regs);
    eofdir:=regs.flags AND 1<>0;
  END;
  getdir:=fnam;
END;

{ exec is used to load and execute a program under program con- }
{ trol. exec is an extremely powerful routine - through it you  }
{ can execute any program or MS-DOS command and still be in     }
{ control. exec must never be called from a program that was    }
{ started with a RUN command in PolyPascal. You may only call   }
{ it in programs that were run from MS-DOS. When you compile a  }
{ program that is to use exec, you should keep your stack seg-  }
{ ment as small as possible, to free as much memory as possible }
{ for other programs. Specifically, you must include the        }
{ <ssmax> parameter in the PROGRAM command, as it will other-   }
{ wise default to all available memory.                         }

{ The path parameter specifies the path of the program to be    }
{ executed. clin is a command line to be passed to the program. }
{ The following call will load and execute PPAS.COM from a sub- }
{ directory called BIN: "exec('\BIN\PPAS.COM','',sts)". To      }
{ execute an MS-DOS internal command, you may run COMMAND.COM,  }
{ for instance: "exec('\COMMAND.COM','/C DIR B:*.PAS',sts)".    }
{ Note that '/C' must be specified in front of the command.     }

{ Some programs require the default FCBs at addresses $5C and   }
{ $6C in the program segment prefix to the initialized with one }
{ or two file names. In such cases you should declare two FCBs  }
{ using the fcbname type, as shown in the VAR declarations      }
{ below, and initialize them before the call to exec. exec will }
{ then pass them on to the new program. exec will always pass   }
{ the MS-DOS "environment" of the calling program on to the new }
{ program with no changes.                                      }

{ The status parameter returns the status of the operation. 0   }
{ means no error, 1 means invalid function, 2 means file not    }
{ found, 8 means not enough memory, 10 means bad environment,   }
{ and 11 means bad format.                                      }

PROCEDURE exec(path: fnamstr; clin: cmdline; VAR status: integer);
TYPE
  parblock = RECORD
               envseg: integer;
               clinp: ^cmdline;
               fcb1p,fcb2p: ^fcbname;
             END;
VAR
  n: integer;
  pblk: parblock;
  envs: integer AT cseg:$2C;
  fcb1: fcbname AT cseg:$5C;
  fcb2: fcbname AT cseg:$6C;
  trds: integer AT cseg:$F8;
  trss: integer AT cseg:$FA;
  trsp: integer AT cseg:$FC;
  trbp: integer AT cseg:$FE;
BEGIN
  n:=len(path); move(path[1],path[0],n); path[n]:=@0;
  clin:=clin+@13;
  pblk.envseg:=envs; pblk.clinp:=addr(clin);
  pblk.fcb1p:=addr(fcb1); pblk.fcb2p:=addr(fcb2);
  CODE
    $2E,$8C,$16,trss,$2E,$89,$26,trsp,$2E,$8C,$1E,trds,
    $2E,$89,$2E,trbp,$16,$07,$8D,$9E,pblk,$16,$1F,$8D,$96,path,
    $B8,$00,$4B,$CD,$21,$2E,$8E,$16,trss,$2E,$8B,$26,trsp,
    $2E,$8E,$1E,trds,$2E,$8B,$2E,trbp,$72,$02,$31,$C0,
    $C4,$BE,status,$26,$89,$05;
END;

{ exitcode returns the exit code of a sub-process. The low byte }
{ is the code sent by the terminating process. The high byte is }
{ zero for normal termination, 1 if terminated by Ctrl-C, 2 if  }
{ terminated due to a device error, or 3 if terminated by the   }
{ keep procedure (function call 31 hex).                        }

FUNCTION exitcode: integer;
BEGIN
  regs.ax:=$4D00; swint($21,regs);
  exitcode:=regs.ax;
END;
