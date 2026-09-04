/*
 * PolyPascal-86 V3.11 error message file expansion utility - ermexpand.c
 * Copyright (c) 2026 Jeffrey H. Johnson <johnsonjh.dev@gmail.com>
 * SPDX-License-Identifier: MIT-0
 * scspell-id: db900532-a7b7-11f1-8533-80ee73e9b8e7
 */

/******************************************************************************/

#include <ctype.h>
#include <errno.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/******************************************************************************/

#include "common.h"

/******************************************************************************/

#ifdef VERSION
# undef VERSION
#endif

/******************************************************************************/

#define VERSION "1.2"

/******************************************************************************/

#define MAX_MACROS 256
#define MAX_LINE 1024

/******************************************************************************/

struct macro
{
  char name;
  char * value;
};

/******************************************************************************/

static struct macro macros [MAX_MACROS];
static int macro_count = 0;

/******************************************************************************/

static const char *
find_macro (char name)
{
  int i;

  for (i = 0; i < macro_count; i++)
    {
      if (macros [i].name == name)
        {
          return macros [i].value;
        }
    }

  return NULL;
}

/******************************************************************************/

static void
trim (char * s)
{
  char * end;

  while (* s && isspace ((unsigned char)* s))
    {
      s++;
    }

  end = s + strlen (s);

  while (end > s && isspace ((unsigned char)end [-1]))
    {
      end--;
    }

  * end = '\0';
}

/******************************************************************************/

static char *
expand (const char * src)
{
  char * out, * p;
  const char * q;
  size_t offset = 0;
  size_t out_size = strlen (src) * 10 + 1;

  out = (char *)malloc (out_size);

  if (! out)
    {
      return NULL;
    }

  p = out;
  q = src;

  while (* q)
    {
      if (q [0] == '&' && q [1] != '\0')
        {
          const char * m = find_macro (q [1]);

          if (m)
            {
              size_t len = strlen (m);

              if (offset + len + 1 >= out_size)
                {
                  size_t used = offset;
                  char * new_out;

                  out_size *= 2;
                  new_out = (char *)realloc (out, out_size);

                  if (! new_out)
                    {
                      FREE (out);

                      return NULL;
                    }

                  out = new_out;
                  p = out + used;
                }

              (void)memcpy (p, m, len);
              p += len;
              offset += len;
              q += 2;

              continue;
            }
        }

      * p++ = * q++;
      offset++;
    }

  * p = '\0';

  return out;
}

/******************************************************************************/

static void
usage (const char * progname)
{
  (void)fprintf (stderr,
                 "ERM - "
                 "PolyPascal-86 V3.11 error message file expansion utility\n");
  (void)fprintf (stderr,
                 "Release " VERSION
#if defined(__DATE__) && defined(__TIME__)
                 " (Built %s %s)",
                 sqz_str (__DATE__), sqz_str (__TIME__)
#elif defined(__DATE__)
                 " (Built %s)",
                 sqz_str (__DATE__)
#endif
                );
  (void)fprintf (stderr, " https://github.com/johnsonjh/PolyPascal\n");
  (void)fprintf (stderr,
      "Copyright (c) 2026 Jeffrey H. Johnson <johnsonjh.dev@gmail.com>\n\n");
  (void)fprintf (stderr, "USAGE: %s <file.txt>\n", progname);
}

/******************************************************************************/

int
main (int argc, char * * argv)
{
  FILE * fp;
  char line [MAX_LINE];

  if (argc != 2)
    {
      usage (argv [0]);

      return EXIT_FAILURE;
    }

  fp = fopen (argv [1], "r");

  if (! fp)
    {
      (void)fprintf (stderr, "ERROR: Cannot open file: %s\n", argv [1]);

      return EXIT_FAILURE;
    }

  while (fgets (line, sizeof (line), fp))
    {
      char * p = line;
      trim (p);

      if (p [0] == '&' && isupper ((unsigned char)p [1]))
        {
          char name = p [1];
          char * q = strchr (p, '"');
          char * r;

          if (! q)
            {
              continue;
            }

          q++;
          r = strrchr (q, '"');

          if (! r)
            {
              continue;
            }

          * r = '\0';

          macros [macro_count].name = name;
          macros [macro_count].value = (char *)malloc (strlen (q) + 1);

          if (! macros [macro_count].value)
            {
              (void)fclose (fp);

              return EXIT_FAILURE;
            }

          (void)strcpy (macros [macro_count].value, q);
          macro_count++;
        }
    }

  if (ferror (fp))
    {
      (void)fprintf (stderr, "ERROR: Read error while scanning macros\n");
      (void)fclose (fp);

      return EXIT_FAILURE;
    }

  rewind (fp);

  if (errno != 0)
    {
      (void)errno;
    }

  while (fgets (line, sizeof (line), fp))
    {
      char * p = line;
      trim (p);

      if (isdigit ((unsigned char)p [0]))
        {
          int num = atoi (p);
          char * q = strchr (p, '"');
          char * r;
          char * expanded;

          if (! q)
            {
              continue;
            }

          q++;
          r = strrchr (q, '"');

          if (! r)
            {
              continue;
            }

          * r = '\0';

          expanded = expand (q);

          if (! expanded)
            {
              (void)fclose (fp);

              return EXIT_FAILURE;
            }

          (void)printf ("%d: \"%s\"\n", num, expanded);

          FREE (expanded);
        }
    }

  if (ferror (fp))
    {
      (void)fprintf (stderr, "ERROR: Read error while scanning entries\n");
      (void)fclose (fp);

      return EXIT_FAILURE;
    }

  (void)fclose (fp);

  return EXIT_SUCCESS;
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
