## E-Prime data clean

The ABCD project is using E-Prime to store functional behavior data connected to MRI scans. Each of the files is stored by E-Prime as a edat2 file that is converted into a CSV format (extension .csv and .txt). During this translation several errors can occour. This project tries to read the uploaded data files and fix a number of issues commonly observed.

### Usage

```
 matlab -r ' dataColumn1 = eprime_data_get("filename", "columnHeader");'
```
