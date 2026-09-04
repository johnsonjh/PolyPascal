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
  represent `<TAB>`, `<LF>`, and `<CR>` characters.  `Z` is surely reserved as
  well (representing CP/M `<EOF>`).  The `erm` utility detects attempts to use
  these names are outputs a prominent warning.  If they are used, the resulting
  compiled error message file is misread by PolyPascal, causing incorrect
  messages to be displayed.

* It is currently **unknown** if all **22** macros can be used (as the shipping
  error message files never use macro `Y`), or if the limit is **21**.  It is
  also **unknown** if compiled error message files can safely exceed
  **1920 bytes**.  Neither of these potential limitations were a problem when
  producing the English‑language translation.

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

| File | Description |
|-----:|:------------|
| [`311.DK`](311.DK) | Decompiled Danish‑language error message file |
| [`DANISH.TXT`](DANISH.TXT) | Expanded Danish‑language decompiled error message file |
| [`311.EN`](311.EN) | Decompiled English‑languge error message file |
| [`ENGLISH.TXT`](ENGLISH.TXT) | Expanded English‑language decompiled error message file |

The `311.EN` file has been recompiled using the `erm` utility to create the
[`../PPAS.ERM.en`](../PPAS.ERM.en) error message file in the repository root.
