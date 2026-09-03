/*
 * PolyPascal-86 V3.11 error message file expansion utility - common.c
 * Copyright (c) 2026 Jeffrey H. Johnson <johnsonjh.dev@gmail.com>
 * SPDX-License-Identifier: MIT-0
 * scspell-id: ea523e2a-a7bf-11f1-97ba-80ee73e9b8e7
 */

/******************************************************************************/

# define TRIM_BUFSIZE 256
# define TRIM_RING 3 /* max reentrancy depth of *all* callers, use calls +1 */

char *
sqz_str (const char * const s)
{
    static char bufs [TRIM_RING] [TRIM_BUFSIZE];
    static int idx = 0;

    const char * p;
    const char * q;
    const char * last;

    char * buf;
    char * d;

    buf = bufs [idx];
    idx++;

    if (idx >= TRIM_RING)
      {
        idx = 0;
      }

    if (s == 0)
      {
        buf [0] = '\0';

        return buf;
      }

    p = s;

    while (* p == ' ' || * p == '\t' || * p == '\r' || * p == '\n')
      {
        p++;
      }

    if (* p == '\0')
      {
        buf [0] = '\0';

        return buf;
      }

    q = p;
    last = p;

    while (* q != '\0')
      {
        if (* q != ' ' && * q != '\t' && * q != '\r' && * q != '\n')
          {
            last = q;
          }

        q++;
      }

    d = buf;

    {
      int in_ws = 0;

      while (p <= last && d < buf + (TRIM_BUFSIZE - 1))
        {
          if (* p == ' ' || * p == '\t' || * p == '\r' || * p == '\n')
            {
              in_ws = 1;
            }
          else
            {
              if (in_ws)
                {
                  * d++ = ' ';
                  in_ws = 0;
                }

              * d++ = * p;
            }

          p++;
        }
    }

    * d = '\0';

    return buf;
}

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
