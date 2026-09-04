# `ERM`

## Overview

* **ERM** is a utility to decompile and recompile the PolyPascal‑86
  V3.11 error‑message files (`PPAS.ERM`).  It has been verified to produce
  byte‑exact round‑trip results when decompiling and then recompiling the
  shipping Danish‑language files.
* The `ermexpand` utility expand all macros in the *decompiled* error
  message file for verification or to ease translation efforts.

## Notes

* Macro letters `I`, `J`, `M`, and `Z` are reserved and cannot be used (as
  these represent `<TAB>`, `<LF>`, `<CR>`, and `<EOF>`.  The `erm` utility
  detects attempts to use these names are outputs a warning message.  If
  these names are used, the resulting compiled error‑message file is
  misparsed by PolyPascal‑86, causing incorrect messages to be displayed.

* It is currently **unknown** whether all **22** macro names can be used (as
  the shipping error‑message files never use macro `Y`), or whether the limit
  is **21**.  It is also **unknown** whether compiled error‑message files can
  safely exceed **1920 bytes**.  As neither of these potential limitations
  were encountered when producing the English‑language translation, they were
  not further investigated.

* The original PolyPascal‑86 V3.11 Danish‑languge CP/M‑86 error‑message file
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
| [`311.DK`](311.DK) | Decompiled Danish‑language error‑message file |
| [`DANISH.TXT`](DANISH.TXT) | Expanded Danish‑language decompiled error‑message file |
| [`311.EN`](311.EN) | Decompiled English‑languge error‑message file |
| [`ENGLISH.TXT`](ENGLISH.TXT) | Expanded English‑language decompiled error‑message file |

The `311.EN` file has been recompiled using the `erm` utility to create the
[`../PPAS.ERM.en`](../PPAS.ERM.en) error‑message file in the repository root.
