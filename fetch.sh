#!/bin/sh

## This script created the `PPCMP` and `PPDOS` directories.
## It shouldn't be necessary to run it again.

set -eux

rm -rf ./PPCMP > /dev/null 2>&1
rm -rf ./PCTMP > /dev/null 2>&1

mkdir -p PCTMP

wget https://datamuseum.dk/aa/cpm/ca/caa2c93b7.bin -O PCTMP/ADDKEY.PAS
wget https://datamuseum.dk/aa/cpm/d3/d3e4a4505.bin -O PCTMP/CALC.PAS
wget https://datamuseum.dk/aa/cpm/52/52d6d2e1d.bin -O PCTMP/CROSSREF.PAS
wget https://datamuseum.dk/aa/cpm/f7/f73c998f3.bin -O PCTMP/DATABASE.PAS
wget https://datamuseum.dk/aa/cpm/f1/f1277d8e3.bin -O PCTMP/DATAMAN.PAS
wget https://datamuseum.dk/aa/cpm/90/906323cf7.bin -O PCTMP/DELKEY.PAS
wget https://datamuseum.dk/aa/cpm/27/2761ee297.bin -O PCTMP/GSX.DOC
wget https://datamuseum.dk/aa/cpm/e2/e25f7d9b3.bin -O PCTMP/GSX.PAS
wget https://datamuseum.dk/aa/cpm/99/99e628caa.bin -O PCTMP/HEXDUMP.PAS
wget https://datamuseum.dk/aa/cpm/e8/e8754c5f2.bin -O PCTMP/INSTALL.CMD
wget https://datamuseum.dk/aa/cpm/5c/5cd0bb4ea.bin -O PCTMP/INSTALL.DAT
wget https://datamuseum.dk/aa/cpm/1c/1c6a8a3fb.bin -O PCTMP/INSTALL.DOC
wget https://datamuseum.dk/aa/cpm/d9/d957ab890.bin -O PCTMP/INSTALL.PAS
wget https://datamuseum.dk/aa/cpm/5a/5ab7cfff6.bin -O PCTMP/INSTALL.TRM
wget https://datamuseum.dk/aa/cpm/d9/d9b0c7100.bin -O PCTMP/INSTJOB.SUB
wget https://datamuseum.dk/aa/cpm/93/93b35aedf.bin -O PCTMP/LIST.PAS
wget https://datamuseum.dk/aa/cpm/69/69a53b437.bin -O PCTMP/NPFKEY.PAS
wget https://datamuseum.dk/aa/cpm/b0/b08f4828c.bin -O PCTMP/PP87.CMD
wget https://datamuseum.dk/aa/cpm/80/8056743e5.bin -O PCTMP/PPAS.CMD
wget https://datamuseum.dk/aa/cpm/56/562ac9c29.bin -O PCTMP/PPAS.ERM
wget https://datamuseum.dk/aa/cpm/5d/5d440f578.bin -O PCTMP/PPAS.HLP
wget https://datamuseum.dk/aa/cpm/bc/bce9dbe2a.bin -O PCTMP/PPASRC.HLP
wget https://datamuseum.dk/aa/cpm/8f/8fca68512.bin -O PCTMP/PPBS.CMD
wget https://datamuseum.dk/aa/cpm/66/662f107e4.bin -O PCTMP/PRIMES.PAS
wget https://datamuseum.dk/aa/cpm/f0/f03a54785.bin -O PCTMP/QSORT.PAS
wget https://datamuseum.dk/aa/cpm/a4/a44a97dbf.bin -O PCTMP/README.DOC

mv -f PCTMP PPCPM

rm -rf ./PPDOS > /dev/null 2>&1
rm -rf ./PPTMP > /dev/null 2>&1

mkdir -p PPTMP

wget https://datamuseum.dk/bits/30005447 -O PPTMP/PP311.ZIP

(
  cd PPTMP \
    && unzip -xa PP311.ZIP \
    && mv PolyPascal-3.11-MSDOS/* . \
    && rmdir PolyPascal-3.11-MSDOS
)

(
  cd PPTMP/data \
    && rm -rf ./out > /dev/null 2>&1
  mkdir -p out \
    && mcopy -v -i disk1.bin '::*' out/ \
    && mcopy -v -i disk2.bin '::*' out/
)

mv -f PPTMP/data/out PPDOS

rm -rf PPTMP > /dev/null 2>&1
