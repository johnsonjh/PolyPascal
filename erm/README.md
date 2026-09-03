# `erm`

## Overview

* `erm` is a utility to decompile and recompile the PolyPascal-86
  3.11 error message files (`PPAS.ERM`).
* It has been verified to produce byte-exact round-trip results when
  decompiling and then recompiling the shipping Danish-language files.
* The `erm` utility is a single file ([`erm.c`](erm.c)) ANSI C89 utility
  that can be built with any standard C compiler.  It also works with the
  [SoftIntegration Ch](https://softintegration.com/) C interpreter.

## Notes

* [`.stash/310.TXT`](.stash/310.TXT) file is an English-language
  PolyPascal-80 V3.10 error message file that has been decompiled to the
  same format as that which `erm` produces.
* This file is for **REFERENCE ONLY**.  It is **NOT** compatible with
  PolyPascal-86 V3.11 and is included in the repository only to aid in the
  Danish to English translation work.
[]()

[]()
* The PolyPascal-80 V3.10 file defines **17** macros and **99** error
  messages.
* The PolyPascal-86 V3.11 file defines **21** macros and **102** error
  messages.

## Trivia

* The PolyPascal-86 V3.11 CP/M-86 error message file contains a typo! It has
  an extra `1` in error #41.  This was most likely caused by editing the file
  in a WordStar-pattern editor in **1985**.  This typo was fixed in the
  PolyPascal-86 V3.11 DOS version (which is dated **1986**):
  ```diff
  --- cpm.txt	1985-01-01 01:00:00.000000000 -0000
  +++ dos.txt	1986-01-01 01:00:00.000000000 -0000
  @@ -61,3 +61,3 @@
   40"&Ken s&L&A"
  -41"1&W&B"
  +41"&W&B"
   42"Operand&A(r) stemmer&V overens med operator"
  ```

## Translation

* When complete, a single translated error message file can be used for both
  the CP/M-86 and DOS versions (as we do the for the
  [PPAS.HLP.en](../PPAS.HLP.en) help text).
