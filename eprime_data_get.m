function [vals,result] = eprime_data_get(parms)
%
% Usage: function [vals,result] = eprime_data_get(parms)
%
% Get data from eprime file.
% Reads spreadsheet file, attempts to find its format and extract data accordingly.
%
% Required input:
% 	parms.fname     name of file to read
% 	parms.columns   strucutre with names of columns to be read
% 
% Output
%     vals    requested columns
%     result  integer that describes the operation's result
% 
% Based on abcd_extract_eprime_mid.m
%
% Created:  10/07/16  by Don Hagler
% Last Mod: 2017aug01-14 by Octavio Ruiz
%

vals = {};  result = 0;

% Check for UTF-16, convert to ASCII if necessary
fname = abcd_check_eprime_encoding(parms.fname,parms.outdir,parms.forceflag);

% Read file assuming first tab-separated then comma-separated columns;
% compare results and keep imported data that "makes more sense".
% Avoid allowing both commas and tabs simultaneously because incorrect importing of some files
[At,rt] = mmil_readtext(fname, '\t');
[Ac,rc] = mmil_readtext(fname, ',');

if rt.max > 1 || rc.max > 1
    if rt.max >= rc.max
        A = At;
        fimport_result = rt;
    else
        A = Ac;
        fimport_result = rc;
    end
else
    fprintf('\n%s\n', fname);
    fprintf('- Unable to import file: "1-column" spreadsheet -');
    rt
    rc
    result = result + 1
    
    return
    
end


% Some files are read incorrectly, but yet, we can get useful information.
% For example, there is an extra column and some values shifted, but other
% columns and vals are ok.
% If there is one or two extra columns, and remove it/them
ec = fimport_result.max - fimport_result.min;
if (1 <= ec && ec <= 2) && size(A,2) > ec
    A = A( : , 1:end-ec);
    fprintf('\n%s\n- Removing last %.0f column(s) from imported spreadsheet -', fname, ec);
    fimport_result
    result = result + 2
end


% First row or rows may contain not column names but other information
% e.g, a comment (on first cell and then empty cells).
% We will ignore those rows, after checking the, say the first 3 rows
for j = 1:3
    if iscellstr( A(j,:) )
        % This row has strings in all its cells, so stop checking,
        % and consider it as column names
        break
    end
end
colnames = A(   j   , :);
vals  =    A(j+1:end, :);


% If column names contains empty cells, something is wrong
if isempty( find(cellfun(@isempty,colnames)) )
    [~,i_all,i_sel] = intersect(colnames,parms.colnames);
    [~,i_sort] = sort(i_sel);
    i_all = i_all(i_sort);
    % create new matrix with replacement column labels
    vals = vals(:,i_all);
else
    fprintf('\n%s\n', fname);
    fprintf('- Empty column names in imported spreadsheet (colname_row = %.0f) -', j);
    fimport_result
    colnames
    result = result + 4
end


return;


% Notes:
% Specifying both commas and tabs as possible delimiters returns, in some
% cases, values (e.g. date and time) that are shifted relative to their column names
% and returns also empty columns
