## E-Prime data get

The ABCD project uses the E-Prime software to run behavioral tests during fMRI scans. E-Prime produces EDAT2 (binary) files with the behavioral results. EDAT2 files are converted, at the acquisition site, into ASCII TAB-separated (preferred) or comma-separated spreadsheet files (extensions .txt and .csv, resepectively) for further analysis. We have observed several types of errors originated during this conversion.

eprime_sprdsht_get.py reads a text file containing E-Prime spreadsheets, detects the file's encoding and format, interprets its content while fixing known encoding issues, identifies the behavioral task in the spreadsheet in the file, extracts the experiment's starting date and time, the number of runs in the experiment, and the starting time of each run. It then evaluates the matching between each run in the file and a specified pGUID, task name, and series-date & time.

If a directory or path is provided, the program locates and processes all files under that path, looking for the best match to the provided parameters (pGUID, task, series date&time).

The program returns a diagnostic number, per file, summarizing its format and contents.

If requested, the script exports a clean, standard-format version of a particular E-Prime file.

We include an additional script, abcd_get_eprime_datetime.m, to show the use of eprime_sprdsht_get.py from Matlab.


### Usage

```
 ./eprime_sprdsht_get.py

Read E-Prime files saved as csv or tsv spreadsheets, detecting encoding and format.
Find runs in file, extract their starting time, and calculate their difference relative to a specified date & time.
Reads E-Prime files in a directory, and pick the file-run closest to a specified date & time.
Spreadsheets with practice experiments are considered invalid.
                     Octavio Ruiz.  2017jun05-nov01, 2018feb19-jun25, 2019apr05-jul23, nov13-dec04, 2020jan13-feb14

Usage:
  ./eprime_sprdsht_get.py                           Print this help
  ./eprime_sprdsht_get.py file Summary              Read file, print summary of file encoding and contents
  ./eprime_sprdsht_get.py file Info                 Read file, print diagnostics and file information
  ./eprime_sprdsht_get.py file InfoCheckName        Read file, print diagnostics and file information,
                                                    check that file name matches experiment in spreadsheet
  ./eprime_sprdsht_get.py file ExportFile outfile   Read file, and write a new file containing the interpreted EPrime data in our standard format
                                                    (tab-separated, no comments before header line, extension = .txt)
                                                    outfile should be entered with no extension

  ./eprime_sprdsht_get.py dir                                                            Read files in directory and print a table with diagnostics, experiment date, time, and filename
  ./eprime_sprdsht_get.py dir PickFile                                                   Idem, suppress listing, pick file with best format and diagnostics, print diagnostics and file information
  ./eprime_sprdsht_get.py dir PickFile "YYYYmmdd HHMMSS"                                 Idem, and calculate difference (in minutes) relative to given time
  ./eprime_sprdsht_get.py dir PickFile "YYYYmmdd HHMMSS" pGUID                           Idem, order file names by specified subject
  ./eprime_sprdsht_get.py dir PickFile "YYYYmmdd HHMMSS" pGUID Task Info                 Idem, filter for files containing specified task, pick file with smallest pGUID and time differences
                                                                                         Suppress table listing, print diagnostics and file information
  ./eprime_sprdsht_get.py dir PickFile "YYYYmmdd HHMMSS" pGUID Task ExportFile outfile   Idem, write picked file using our standard format
                                                                                         (tab-separated, no comments before header line, extension = .txt)
                                                                                         outfile should be entered with no extension
Arguments:
  pGUID    Participant short keyname or ""
  Task     Either "" or one of dict_keys(['nBack', 'MID', 'SST'])
  -h       Print variable names above output line
  -v       Verbose operation
  Info     Print an output line containing:
      diagnos  dir_found  file_found  pGUIDmatch  contents_ok  exper  exper_ok  fname_exp_match  datime_ok  exp_t0  run  run_t0  tdiff  naming_ok  fname  msg

Output:
  diagnos    Sum of values from the following code:
    = 0  File not found
    > 0  File was found and read succesfully. Encoding and format are:
           1   =>   Encoding = utf-8
           2   =>   Encoding = utf-16
           4   =>   Separator = Tab, instead of comma
           8   =>   Quoted rows
          16   =>   One or more rows before column-names header
          64   =>   Experiment in spreadsheet matches file name (returned only if option = "FileNameCheck")
    < 0  File was found and read, but it is not acceptable:
     -1..-16   =>   Format as described for diag > 0
         -32   =>   Unable to recognize experiment in spreadsheet
         -64   =>   Experiment in spreadsheet does not match file name, or practice experiment (returned only if option = "FileNameCheck")
        -128   =>   Start_time_info not found or unable to extract
        -256   =>   Non specified error

  dir_found        Directory found
  file_found       Found at least one file in directory
  pGUIDmatch       Subject in file name matches the specified pGUID
  contents_ok      File contains E-Prime data

  exper            Experiment found inside the file (short code)
  exper_ok         File contains the specified task
  fname_exp_match  Experiment in file matches file name

  datime_ok        Date and time can be extracted
  exp_t0           Experiment starting time, according to file contents
  tdiff            Time difference relative to provided date & time (minutes)

  naming_ok        File name starts with "NDAR_INV"
  fname            Full file fname

Use: "echo $?" to check exit status code

```


### Examples

  ./eprime_sprdsht_get.py   partic1  PickFile  "20170520 164900"  ""  ""  Info

  ./eprime_sprdsht_get.py   partic1  PickFile  "20170520 164900"  NDAR_INVJPLWZ1Z0  ""   Info

  ./eprime_sprdsht_get.py   partic1  PickFile  "20170520 164900"  NDAR_INVJPLWZ1Z0  MID  Info

  ./eprime_sprdsht_get.py   /something/somewhere/site/NDAR_INVJPLZW1Z0/baseline_year_1_arm_1/sst-exported_NDAR_INVJPLZW1Z0_baseline_year_1_arm_1_SessionC

  ./eprime_sprdsht_get.py  "/something/somewhere/*/*INVB9CDPZUA*/*/*exported*"
  