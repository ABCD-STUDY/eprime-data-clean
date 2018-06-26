## E-Prime data get

The ABCD project is using E-Prime to run behavioral tests during fMRI scans. E-Prime produces EDAT2 (binary) files with the behavioral results. EDAT2 files are converted, at the acquisition site, into ASCII TAB-separated (preferred) or CSV files (extensions .txt and .csv, resepectively). We have observed several types of errors originated during this conversion.

eprime_sprdsht_get.py reads one or more text files containing E-Prime spreadsheets, detects each file's encoding and format, interprets their content fixing known encoding issues, identifies the behavioral task in the spreadsheet, extracts the experiment's starting date and time, calculates the time difference between this date&time and a given series date&time, and evaluates the matching between the file name and a given pGUID.

The program calculates and returns a diagnostic number summarizing the file format and contents; it returns also the experiment's task, starting date and time, and other information.

If requested, the script exports a clean version of the E-Prime file.

If a directory or path is provided, the program locates and processes all files under that path.



### Usage

```
 ./eprime_sprdsht_get.py

Read text file(s) containing a E-Prime spreadsheet(s), detect encoding and format, interpret content,
check if experiment matches file name, extract experiment's date and time and other information.
This program can also locate and check a set of files under a given directory or path.
                                                      Octavio Ruiz.  2017jun05-nov01, 2018feb19-jun25
Usage:
  ./eprime_sprdsht_get.py                          Print this help
  ./eprime_sprdsht_get.py file Summary             Read file, print summary of file encoding and contents
  ./eprime_sprdsht_get.py file Info                Read file, print diagnostics and file information
  ./eprime_sprdsht_get.py file InfoCheckName       Read file, print diagnostics and file information,
                                                   check that file name matches experiment in spreadsheet
  ./eprime_sprdsht_get.py file ExportFile outfile  Read file, and write a new file containing the interpreted EPrime data in our standard format
                                                   (tab-separated, no comments before header line, extension = .txt)
                                                   outfile should be entered with no extension

  ./eprime_sprdsht_get.py dir                                                           Read files in directory and print a table with diagnostics, experiment date, time, and filename
  ./eprime_sprdsht_get.py dir PickFile                                                  Idem, suppress listing, pick file with best format and diagnostics, print diagnostics and file information
  ./eprime_sprdsht_get.py dir PickFile "YYYYmmdd HHMMSS"                                Idem, and calculate difference (in minutes) relative to given time
  ./eprime_sprdsht_get.py dir PickFile "YYYYmmdd HHMMSS" pGUID                          Idem, order file names by specified subject
  ./eprime_sprdsht_get.py dir PickFile "YYYYmmdd HHMMSS" pGUID Task Info                Idem, filter for files containing specified task, pick file with smallest pGUID and time differences
                                                                                        Suppress table listing, print diagnostics and file information
  ./eprime_sprdsht_get.py dir PickFile "YYYYmmdd HHMMSS" pGUID Task ExportFile outfile  Idem, write picked file using our standard format
                                                                                        (tab-separated, no comments before header line, extension = .txt)
                                                                                        outfile should be entered with no extension
Where
  Task is  "" or one of dict_keys(['MID', 'nBack', 'SST'])

Info, when argument is a file, prints:
    diagnos ,  pGUIDmatch ,  naming_ok ,  exp_t0 ,  task ,  full_file_fname

Info, when arguments are  dir PickFile "YYYYmmdd HHMMSS" ,  prints:
    diagnos ,  pGUIDmatch ,  naming_ok ,  exp_t0 ,  task ,  time_diff(minutes) ,  full_file_fname

diagnos is a sum of values from the following code:
  diag = 0  File not found
  diag > 0  File was found and read succesfully. Encoding and format are:
         1   =>   Encoding = utf-8
         2   =>   Encoding = utf-16
         4   =>   Separator = Tab, instead of comma
         8   =>   Quoted rows
        16   =>   One or more rows before column-names header
        64   =>   Experiment in spreadsheet matches file name (returned only if option = "FileNameCheck")
  diag < 0  File was found and read, but it is not acceptable:
   -1..-16   =>   Format as described for diag > 0
       -32   =>   Unable to recognize experiment in spreadsheet
       -64   =>   Experiment in spreadsheet does not match file name, or practice experiment (returned only if option = "FileNameCheck")
      -128   =>   Start_time_info not found or unable to extract
      -256   =>   Un-diagnosed error
diagnos is returned to the shell as exit-status code, that can be checked with "echo $?"

naming_ok = 1  =>  file name starts with "NDAR_INV"

Spreadsheets with practice experiments are considered not valid.

```


### Examples

  ./eprime_sprdsht_get.py  some_file.tsv  Info
  ./eprime_sprdsht_get.py  some_dir  PickFile  "20170520 164900"  ""  ""  Info
  ./eprime_sprdsht_get.py  some_dir  PickFile  "20170520 164900"  NDAR_INVJPLWZ1Z0  MID  Info
  ./eprime_sprdsht_get.py  "/dir0/subdir1/*INVB9CDPZUA*/*/*exported*"

