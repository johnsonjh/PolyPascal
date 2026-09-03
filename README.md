# PolyPascal 3.11 for DOS and CP/M-86

## Overview

* This is an English translation of **PolyPascal-86 3.1** for
  DOS and CP/M-86.

* See
  [https://datamuseum.dk/wiki/PolyPascal](https://datamuseum.dk/wiki/PolyPascal)
  for additional PolyPascal information.

## Notes

* The [`fetch.sh`](fetch.sh) script was used to create the [`PPCPM`](PPCPM)
  (CP/M-86) and [`PPDOS`](PPDOS) (DOS) directories.  It is provided for
  reference purposes.  It should not be necessary to run it again.

## Configuration

* Use `emu2-cpm86` (available from
  [https://gitlab.com/johnsonjh/emu2-cpm86](https://gitlab.com/johnsonjh/emu2-cpm86))
  or [https://github.com/johnsonjh/emu2-cpm86](https://github.com/johnsonjh/emu2-cpm86))
  to run the `INSTALL.CMD` or `INSTALL.COM` programs to configure
  PolyPascal for your system:

  ```
  $ emu2 INSTALL.CMD

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

* Repeat the above process to configure all three executables
  (`CMD` or `COM`) in each version:

  | Executable | Description        |
  |-----------:|:-------------------|
  | `PPAS`     | Standard version   |
  | `PPBS`     | BCD version        |
  | `PP87`     | 8087 NDP version   |

* Most users will want to use `A` (DOS), `B` (CP/M-86), or `C` (ANSI).

## Translations

### Help text

* The [`PPAS.HLP.en`](PPAS.HLP.en) is an English translation of the
  `PPAS.HLP` help file which should be appropriate for both versions.
* For DOS, overwrite `PPAS.HLP` with `PPAS.HLP.en`.
* For CP/M-86, overwrite `PPASRC.HLP` with `PPAS.HLP.en`.
  * NOTE: `PPAS.HLP` appears to be unused in the CP/M-86 version.

### Error messages

* Error messages are stored in the `PPAS.ERM` file and are not yet
  translated.
