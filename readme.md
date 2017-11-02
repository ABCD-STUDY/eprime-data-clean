## E-Prime data get

The ABCD project is using E-Prime to run behavioral tests during fMRI scans. E-Prime produces EDAT2 (binary) files with the behavioral results. EDAT2 files are converted, at the acquisition site, into ASCII TAB-separated (preferred) or CSV files (extensions .txt and .csv, resepectively). We have observed several types of errors originated during this conversion.

eprime_sprdsht_get.py extracts information from a given ASCII E-prime file, fixing known encoding issues. It can return information about an E-Prime file (experiment date and time, file diagnostics), or rewrite a clean version of the E-Prime file.


### Usage

```
  ./eprime_spreadsheet_read.py
  ./eprime_spreadsheet_read.py  file  option
  ./eprime_spreadsheet_read.py  file  ExportFile  out_file (without .ext)

Options:
                    Prints this help
   Encoding         Returns encoding, file format, and row organization of input file
   Summary          As Encoding, plus a summary of column names and last row
   ExportFile       Save a tab-separated output file with clean contents of input file; we'll make extension = '.txt'
   DateTime         Returns ISO starting date and time of experiment reported in input file
   DateTimeDiagnos  As DateTime, plus a file diagnostic code (see below):
   Diagnos          Returns a diagnostic number, formed by summing:
      File found?                           0  -->  [Unable to find file]
      Encoding:                     1,      2  -->  ['utf-8','utf-16']
      Separator:                   10,     20  -->  [Tab, Comma]
      Quoted rows?                  0,    100  -->  [No, Yes]
      Start_time_info:              0,   1000  -->  [Found, Unable to extract]
      File read?                    0,  10000  -->  [Yes,   Unable to read]
      Filename contains '()':          100000  -->  [Yes]  (Reserved, calculated elsewhere)
      Experiment matches filename?    1000000  -->  [No]
```


### Example

eprime_datetime_get.m   Uses eprime_sprdsht_get.py to extract the date and time of an E-Prime experiment.
