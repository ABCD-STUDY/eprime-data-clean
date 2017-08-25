## E-Prime data get

The ABCD project is using E-Prime to run behavioral tests connected to MRI scans. E-prime produces EDAT2 (binary) files with the behavioral results. EDAT2 files are converted, at the acquisition site, into ASCII TAB-separated (preferred) or CSV files (extensions .txt and .csv, resepectively). We have observed several types of errors occuring during this translation.

This project tries to extract information from a given ASCII E-prime file, despite known encoding issues.

The project consists of the Matlab function eprime_data_get.m.
This function returns a subset of columns from an eprime file after tring to repair encoding issues, and reports the issue.



### Usage

```
[vals,result] = eprime_data_get(parms)
%
% Gets a subset of the columns present in an eprime file solving for encoding issues.
%
% Required input:
%    parms.fname     name of file to read
%    parms.columns   strucutre with names of columns to be read
% 
% Output
%    vals    requested columns
%    result  integer that summarizes the result of reading and interpreting an eprime file.

The value of result is formed by adding the following numbers:
  0  No issues
  1  Unable to import file: imported table has one column
  2  Imported spreadsheet contains rows with different number of cells;
     the difference is small (1 or 2) and last columns were removed in that number
  4  Best guess of colum names includes empty cells

```
