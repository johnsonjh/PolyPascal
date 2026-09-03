# erm - Makefile
# Copyright (c) 2026 Jeffrey H. Johnson <johnsonjh.dev@gmail.com>
# SPDX-License-Identifier: MIT-0
# scspell-id: 27a85f0c-a77a-11f1-bd84-80ee73e9b8e7

################################################################################

# Compatible defaults.

XCC=$$(command -v cc 2> /dev/null || command -v gcc 2> /dev/null || \
	command -v clang 2> /dev/null || printf '%s\n' "cc")
XCFLAGS=-O

################################################################################

all: erm

################################################################################

build: all

################################################################################

erm: erm.c
	@eval echo \
		"$${CC:-$(XCC)}" "$${CFLAGS:-$(XCFLAGS)}" \
		-o ./$@ ./erm.c "$${LDFLAGS:-$(XLDFLAGS)}" \
		2> /dev/null || :
	@eval \
		"$${CC:-$(XCC)}" "$${CFLAGS:-$(XCFLAGS)}" \
		-o ./$@ ./erm.c "$${LDFLAGS:-$(XLDFLAGS)}"

################################################################################

strip:
	test -x erm 2> /dev/null && strip erm || :
	test -x erm 2> /dev/null && sstrip -z erm 2> /dev/null || :

################################################################################

clean distclean:
	rm -f ./erm ./erm.exe ./erm.o ./a.exe ./a.out ./core ./*.core ./core-*

################################################################################

.PHONY: all build strip clean distclean

################################################################################

# Local Variables:
# mode: makefile
# indent-tabs-mode: t
# tab-width: 8
# whitespace-style: (tabs tab-mark)
# whitespace-display-mappings: ((tab-mark 9 [45] [45]))
# fill-column: 80
# eval: (setq-local whitespace-display-mappings
#                   '((tab-mark 9
#                               [45 45 45 45 45 45 62]
#                               [45 45 45 45 45 45 62])))
# eval: (whitespace-mode 1)
# eval: (setq-local display-fill-column-indicator-column 80)
# eval: (display-fill-column-indicator-mode 1)
# End:

################################################################################
# vim: set ft=make ts=8 ai noexpandtab list listchars=tab\:\>\- cc=80 :
################################################################################
