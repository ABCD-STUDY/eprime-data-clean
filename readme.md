## E-Prime data get

The ABCD project is using E-Prime to run behavioral tests connected to MRI scans. E-prime produces EDAT2 (binary) files with the behavioral results. EDAT2 files are converted, at the acquisition site, into ASCII TAB-separated (preferred) or CSV files (extensions .txt and .csv, resepectively).

We have observed several types of errors occuring during this translation.

This project tries to extract information from a given ASCII E-prime file, solving for the encoding issues that we have observed.

It consists, right now, of the Matlab function eprime_data_get.m.
It gets a subset of the columns present in an eprime file solving for encoding issues.
I am currently modifying the script to read all the ASCII Eprime file, corrects issues as possible, and save the fixed version.



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
