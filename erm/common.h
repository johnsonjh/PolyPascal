/*
 * PolyPascal-86 V3.11 error message file expansion utility - common.h
 * Copyright (c) 2026 Jeffrey H. Johnson <johnsonjh.dev@gmail.com>
 * SPDX-License-Identifier: MIT-0
 * scspell-id: 0ce145d0-a7c0-11f1-af9b-80ee73e9b8e7
 */

/******************************************************************************/

#ifndef COMMON_H_
# define COMMON_H_

/******************************************************************************/

#ifndef EXIT_SUCCESS
# define EXIT_SUCCESS 0
#endif

/******************************************************************************/

#ifndef EXIT_FAILURE
# define EXIT_FAILURE 1
#endif

/******************************************************************************/

#ifdef FREE
# undef FREE
#endif

/******************************************************************************/

static const int never = 0;

/******************************************************************************/

#define FREE(p)   \
  do              \
    {             \
      free ((p)); \
      (p) = NULL; \
    }             \
  while (never)

/******************************************************************************/

char * sqz_str (const char * const s);

/******************************************************************************/

#endif

/******************************************************************************/

/*
 * Local Variables:
 * mode: c
 * indent-tabs-mode: nil
 * tab-width: 2
 * c-basic-offset: 2
 * fill-column: 80
 * eval: (setq-local display-fill-column-indicator-column 80)
 * eval: (display-fill-column-indicator-mode 1)
 * End:
 */

/******************************************************************************/
/* vim: set ft=c ts=2 sw=2 tw=0 ai expandtab cc=80 : */
/******************************************************************************/
