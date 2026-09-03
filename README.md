# PolyPascal-86 3.11 for DOS and CP/M-86

## Overview

* This is an English translation of **PolyPascal-86 3.11** for
  DOS and CP/M-86.
* See
  [https://datamuseum.dk/wiki/PolyPascal](https://datamuseum.dk/wiki/PolyPascal)
  for additional PolyPascal information.

## Notes

* The [`fetch.sh`](fetch.sh) script was used to create the
  [`PPCPM`](PPCPM) (CP/M-86) and [`PPDOS`](PPDOS) (DOS) directories.
* It is provided for reference purposes, and it should not be necessary
  to run it again.

## Configuration

* Use `emu2-cpm86` (available from
  [GitLab](https://gitlab.com/johnsonjh/emu2-cpm86)
  or [GitHub](https://github.com/johnsonjh/emu2-cpm86))
  to run the `INSTALL.CMD` and `INSTALL.COM` programs to configure
  PolyPascal-86 for your system:

  ```
                PolyPascal-86 V3.11 Install Program
                          CP/M-86 version

                        Copyright (C) 1985
                     PolyData MicroCenter A/S


  This  program is used to view and modify the adjustable parts  of
  PolyPascal.  If your copy of PolyPascal is unconfigured, then be-
  fore you can use it,  you must install it using this program.  If
  your copy is already set up for a specific computer system, there
  is no need to run this program,  unless you wish to make personal
  adjustments.

  Input file name (RETURN for PPAS.CMD)? <PPAS.CMD>

  INSTALL PROGRAM MAIN MENU:

  1. Load a standard configuration
  2. Edit configuration parameters
  3. Edit memory allocation parameters
  4. Save a standard configuration

  CURRENT CONFIGURATION: RC PICCOLINE.

  Function(1-4), Exit(X), Help(Y): <1>

  STANDARD CONFIGURATIONS (MENU 1):

  A. IBM PC, XT, AT (PC-DOS)
  B. IBM PC, XT, AT (CP/M-86)
  C. ANSI Standard

  [ ... ]

  Press RETURN to view more

  Load(A-J), Exit(X), Help(Y): <B>

  CURRENT CONFIGURATION: IBM PC, XT, AT (CP/M-86)

  Function(1-4), Exit(X), Help(Y): <X>

  Save configuration in PPAS.CMD (YES/NO)? <YES>
  ```

* Most users will want to use `A` (PC-DOS), `B` (CP/M-86), or `C` (ANSI).

* Repeat the above process to configure all three executables
  (`CMD` and `COM`) in each version:

  |                        Executable | Description         |
  |----------------------------------:|:--------------------|
  | `PPAS.COM`&nbsp;/&nbsp;`PPAS.CMD` | Standard versions   |
  | `PPBS.COM`&nbsp;/&nbsp;`PPBS.CMD` | BCD versions        |
  | `PP87.COM`&nbsp;/&nbsp;`PP86.CMD` | 8087 NDP versions   |

## Translation

### Help text

* The [`PPAS.HLP.en`](PPAS.HLP.en) is an English help file
  appropriate for both versions.
  * For DOS, overwrite `PPAS.HLP` with `PPAS.HLP.en`.
  * For CP/M-86, overwrite both `PPASRC.HLP` and `PPAS.HLP` with
    `PPAS.HLP.en`.

### Error messages

* Error messages are stored in the `PPAS.ERM` files and are not yet
  translated.

## License

* This software is provided for the purposes of historical research
  and preservation.
* It is not intended for commercial use, and all original rights
  remain with their respective holders.
