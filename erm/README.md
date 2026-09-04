# `ERM`

## Overview

* **ERM** is a utility to decompile and recompile the PolyPascal‑86
  V3.11 error message files (`PPAS.ERM`).  It has been verified to produce
  byte‑exact round‑trip results when decompiling and then recompiling the
  shipping Danish‑language files.
* The `ermexpand` utility expand all macros in the *unpacked* error message
  file for verification or ease of translation.

## Notes

* Macro letters `I`, `J`, and `M` are reserved and cannot be used (as these
  represent `<TAB>`, `<LF>`, and `<CR>` characters.  The `erm` utility
  currently **will** accept them, but if you use those letters, the resulting
  compiled error message file is misparsed by PolyPascal, causing incorrect
  messages to be displayed.

* It is currently **unknown** if more than **21** macros can be used, or if
  compiled error message files can exceed **1920 bytes**.  These limitations
  were not a problem for the English translation.

* The original PolyPascal‑86 V3.11 Danish‑languge CP/M‑86 error message file
  contains a typo! It has an extra `1` in error #41.  This was most likely
  caused by editing the file in a WordStar‑pattern editor back in **1985**.
  This typo was fixed in the PolyPascal‑86 V3.11 DOS version (which is
  dated **1986**):
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

| File          | Description                                             |
|--------------:|:--------------------------------------------------------|
| `311.DK`      | Decompiled Danish‑language error message file           |
| `DANISH.TXT`  | Expanded Danish‑language decompiled error message file  |
| `311.EN`      | Decompiled English‑languge error message file           |
| `ENGLISH.TXT` | Expanded English‑language decompiled error message file |

The `311.EN` file has been recompiled using `erm` utility to create the
[`../PPAS.ERM.en`](../PPAS.ERM.en) compiled error message file in the root of
the repository.
