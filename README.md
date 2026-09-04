# PolyPascal‑86 V3.11 for DOS and CP/M‑86

## Overview

* This is an English translation of **PolyPascal‑86 V3.11** (the final version)
  for DOS and CP/M‑86.
* PolyPascal was the direct predecessor of Borland Turbo Pascal.
* See
  [https://datamuseum.dk/wiki/PolyPascal](https://datamuseum.dk/wiki/PolyPascal)
  for additional PolyPascal information.

## Documentation

* Complete [PDF documentation](https://rc700.dk/files/documentation/PICCOLINE_PolyPascal_Brugervejledning_1985.pdf)
  is available (in Danish).
* For English‑language documentation, the Borland
  [Turbo Pascal 1.0](https://bitsavers.org/pdf/borland/turbo_pascal/Turbo_Pascal_Reference_Manual_Feb84.pdf)
  manual should adequately describe the language.

## Notes

* The [`fetch.sh`](fetch.sh) script was used to create the
  [`PPCPM/`](PPCPM) (CP/M‑86) and [`PPDOS/`](PPDOS) (DOS) directories.
* It is provided for reference purposes, and it should not be necessary
  to run it again.

## Configuration

* If you are using a UNIX‑like system, `emu2‑cpm86` (available from
  [GitLab](https://gitlab.com/johnsonjh/emu2-cpm86)
  or [GitHub](https://github.com/johnsonjh/emu2-cpm86))
  can be used to run the `INSTALL.CMD` and `INSTALL.COM` programs to
  configure PolyPascal‑86 for your system:

  ```
                PolyPascal-86 V3.11 Install Program
                          CP/M-86 version

                        Copyright (C) 1985
                     PolyData MicroCenter A/S
  [ ... ]

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

* Most users will want to use `A` (PC‑DOS), `B` (CP/M‑86), or `C` (ANSI).

* Repeat the above process to configure all three executables
  (`CMD` and `COM`) in each version:

  |                        Executable | Description         |
  |----------------------------------:|:--------------------|
  | `PPAS.COM`&nbsp;/&nbsp;`PPAS.CMD` | Standard versions   |
  | `PPBS.COM`&nbsp;/&nbsp;`PPBS.CMD` | BCD versions        |
  | `PP87.COM`&nbsp;/&nbsp;`PP86.CMD` | 8087 NDP versions   |

* The PolyPascal‑86 software as provided is unmodified; see the instructions
  below to install the English‑language translation files.

## Translation

### Help text

* [`PPAS.HLP.en`](PPAS.HLP.en) contains the English‑language help translation
  appropriate for both versions.
  * For **DOS**, overwrite `PPAS.HLP` with `PPAS.HLP.en`.
  * For **CP/M‑86**, overwrite *both* `PPASRC.HLP` and `PPAS.HLP` with
    `PPAS.HLP.en`.

### Error messages

* [`PPAS.ERM.en`](PPAS.ERM.en) contains the English‑language error‑message
  file translation appropriate for both versions.
  * For *both* **DOS** and **CP/M‑86**, overwrite `PPAS.ERM` with
    `PPAS.ERM.en`.

### Translation tools

* See the [`erm/`](erm) directory for information on the tools developed
  to facilitate the translation.

## Extras

* The [`PPAS_T3/`](PPAS_T3) directory contains the source code for a program
  to convert PolyPascal‑86 programs so the `UPGRADE` utility shipped with
  Borland Turbo Pascal 4.0 for DOS can successfully process them, and a copy
  of the PolyPascal‑86 Turtlegraphics Package for the IBM PC.

## Availability

* [GitHub](https://github.com/johnsonjh/PolyPascal)
* [GitLab](https://gitlab.com/johnsonjh/polypascal)

## License

* This software is provided for the purposes of historical research
  and preservation.
* It is not intended for commercial use, and all original rights
  remain with their respective holders.
