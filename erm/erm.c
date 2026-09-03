/*
 * PolyPascal-86 V3.11 error message compiler/decompiler utility - erm.c
 * Copyright (c) 2026 Jeffrey H. Johnson <johnsonjh.dev@gmail.com>
 * SPDX-License-Identifier: MIT-0
 * scspell-id: 51f2da5e-a774-11f1-b904-80ee73e9b8e7
 */

/******************************************************************************/

#include <ctype.h>
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

#define VERSION "1.1"

/******************************************************************************/

static void
usage (const char * progname, int nl)
{
  if (nl)
    {
      (void)fprintf (stderr, "\r\n");
    }

  (void)fprintf (stderr, "ERM - "
      "PolyPascal-86 V3.11 error message file compiler/decompiler utility\n");
  (void)fprintf (stderr, "Release " VERSION
#if defined (__DATE__) && defined (__TIME__)
                 " (Built %s %s)", sqz_str (__DATE__), sqz_str (__TIME__)
#elif defined (__DATE__)
                 " (Built %s)", sqz_str (__DATE__)
#endif
                );
  (void)fprintf (stderr, " https://github.com/johnsonjh/PolyPascal\n");
  (void)fprintf (stderr,
       "Copyright (c) 2026 Jeffrey H. Johnson <johnsonjh.dev@gmail.com>\n\n");
  (void)fprintf (stderr, "USAGE: %s -u <file.erm> -o <file.txt>\n", progname);
  (void)fprintf (stderr, "       %s -p <file.txt> -o <file.erm>\n", progname);
}

/******************************************************************************/

static void
unpack (const char * in_filename, const char * out_filename)
{
  FILE * fin;
  FILE * fout;
  long size, idx;
  unsigned char * buffer;
  int state;
  int err_num;
  unsigned char b;

  fin = fopen (in_filename, "rb");

  if (! fin)
    {
      perror ("Error opening input file");

      exit (EXIT_FAILURE);
    }

  fout = fopen (out_filename, "w");

  if (! fout)
    {
      perror ("Error opening output file");
      (void)fclose (fin);

      exit (EXIT_FAILURE);
    }

  (void)fseek (fin, 0, SEEK_END);
  size = ftell (fin);
  (void)fseek (fin, 0, SEEK_SET);

  buffer = (unsigned char *)malloc ((size_t)size);

  if (! buffer)
    {
      (void)fprintf (stderr, "Memory allocation failed!\n");

      abort ();
    }

  if (size > 0)
    {
      (void)fread (buffer, 1, (size_t)size, fin);
    }

  (void)fclose (fin);

  while (size > 0 && buffer [size - 1] == 0x1A)
    {
      size--;
    }

  idx = 0;
  state = 0;
  err_num = 1;

  while (idx < size)
    {
      if (state == 0)
        {
          if (buffer [idx] == 0x0D)
            {
              state = 1;
              idx++;

              continue;
            }

          b = buffer [idx++];

          if (b >= 1 && b <= 31)
            {
              (void)fprintf (fout, "&%c\"", b - 1 + 'A');

              while (idx < size && buffer [idx] >= 32)
                {
                  (void)fputc (buffer [idx++], fout);
                }

              (void)fprintf (fout, "\"\n");
            }
          else
            {
              (void)fprintf (stderr,
                             "WARN: bad byte 0x%02X in macro section\n", b);
            }
        }
      else
        {
          (void)fprintf (fout, "%d\"", err_num++);

          while (idx < size && buffer [idx] != 0x0D)
            {
              b = buffer [idx++];

              if (b >= 32)
                {
                  (void)fputc (b, fout);
                }
              else if (b >= 1)
                {
                  (void)fprintf (fout, "&%c", b - 1 + 'A');
                }
            }

          (void)fprintf (fout, "\"\n");

          if (idx < size && buffer [idx] == 0x0D)
            {
              idx++;
            }
        }
    }

  FREE (buffer);

  (void)fclose (fout);
}

/******************************************************************************/

static void
pack (const char * in_filename, const char * out_filename)
{
  FILE * fin;
  FILE * fout;
  char line [2048];
  int expected_err = 1;
  int first_error_written = 0;
  long pos;

  fin = fopen (in_filename, "r");

  if (! fin)
    {
      perror ("Error opening input file");

      exit (EXIT_FAILURE);
    }

  fout = fopen (out_filename, "wb");

  if (! fout)
    {
      perror ("Error opening output file");
      (void)fclose (fin);

      exit (EXIT_FAILURE);
    }

  while (fgets (line, sizeof (line), fin))
    {
      size_t len = strlen (line);
      char * first_quote;
      char * last_quote;
      const char * code;
      char * str;
      int i;

      while (len > 0 && (line [len - 1] == '\n' || line [len - 1] == '\r'))
        {
          line [--len] = '\0';
        }

      if (len == 0)
        {
          continue;
        }

      first_quote = strchr (line, '"');
      last_quote  = strrchr (line, '"');

      if (! first_quote || ! last_quote || first_quote == last_quote)
        {
          (void)fprintf (stderr,
                         "WARN: invalid line format (skipping): %s\n", line);

          continue;
        }

      * first_quote = '\0';
      * last_quote  = '\0';

      code = line;
      str = first_quote + 1;

      while (* code == ' ' || * code == '\t')
        {
          code++;
        }

      if (code [0] == '&')
        {
          char m;

          if (first_error_written)
            {
              (void)fprintf (stderr,
                             "WARN: Macro defined after errors started: &%s\n",
                             code + 1);
            }

          m = code [1];

          if (m >= 'A' && m <= 'Z')
            {
              (void)fputc (m - 'A' + 1, fout);

              for (i = 0; str [i]; i++)
                {
                  if (str [i] == '&' &&
                      str [i + 1] >= 'A' && str [i + 1] <= 'Z')
                    {
                      (void)fputc (str [i + 1] - 'A' + 1, fout);
                      i++;
                    }
                  else
                    {
                      (void)fputc (str [i], fout);
                    }
                }
            }
        }
      else if (isdigit ((unsigned char)code [0]))
        {
          int num = atoi (code);

          if (! first_error_written)
            {
              first_error_written = 1;
            }

          if (num < expected_err)
            {
              (void)fprintf (stderr,
                             "WARN: Error #%d is out of order (expected %d)\n",
                             num, expected_err);
              (void)fputc (0x0D, fout);
            }
          else
            {
              while (expected_err <= num)
                {
                  (void)fputc (0x0D, fout);
                  expected_err++;
                }
            }

          for (i = 0; str [i]; i++)
            {
              if (str [i] == '&' &&
                  str [i + 1] >= 'A' && str [i + 1] <= 'Z')
                {
                  (void)fputc (str [i + 1] - 'A' + 1, fout);
                  i++;
                }
              else
                {
                  (void)fputc (str [i], fout);
                }
            }
        }
    }

  pos = ftell (fout);

  while (pos % 128 != 0)
    {
      (void)fputc (0x1A, fout);
      pos++;
    }

  (void)fclose (fin);
  (void)fclose (fout);
}

/******************************************************************************/

int
main (int argc, const char * const argv [])
{
  int do_unpack = 0;
  int do_pack = 0;
  const char * in_file  = NULL;
  const char * out_file = NULL;
  int i;

  for (i = 1; i < argc; i++)
    {
      if (strcmp (argv [i], "-u") == 0)
        {
          do_unpack = 1;

          if (i + 1 < argc && argv [i + 1] [0] != '-')
            {
              in_file = argv [++i];
            }
          else
            {
              (void)fprintf (stderr,
                             "ERROR: '-u' requires a filename argument!\n");
              usage (argv [0], 1);

              return EXIT_FAILURE;
            }
        }
      else if (strcmp (argv [i], "-p") == 0)
        {
          do_pack = 1;

          if (i + 1 < argc && argv [i + 1] [0] != '-')
            {
              in_file = argv [++i];
            }
          else
            {
              (void)fprintf (stderr,
                             "ERROR: '-p' requires a filename argument!\n");
              usage (argv [0], 1);

              return EXIT_FAILURE;
            }
        }
      else if (strcmp (argv [i], "-o") == 0)
        {
          if (i + 1 < argc && argv [i + 1] [0] != '-')
            {
              out_file = argv [++i];
            }
          else
            {
              (void)fprintf (stderr,
                             "ERROR: '-o' requires a filename argument!\n");
              usage (argv [0], 1);

              return EXIT_FAILURE;
            }
        }
      else
        {
          (void)fprintf (stderr, "ERROR: Unknown argument '%s'!\n", argv [i]);
          usage (argv [0], 1);

          return EXIT_FAILURE;
        }
    }

  if (! do_unpack && ! do_pack)
    {
      usage (argv [0], 0);

      return EXIT_FAILURE;
    }

  if (do_unpack && do_pack)
    {
      (void)fprintf (stderr, "ERROR: Cannot specify both '-u' and '-p'!\n");
      usage (argv [0], 1);

      return EXIT_FAILURE;
    }

  if (! out_file)
    {
      (void)fprintf (stderr, "ERROR: Output file ('-o') must be specified!\n");
      usage (argv [0], 1);

      return EXIT_FAILURE;
    }

  if (do_unpack)
    {
      unpack (in_file, out_file);
    }
  else
    {
      pack (in_file, out_file);
    }

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
