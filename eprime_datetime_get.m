function [date,time,dtres,fres,nruns] = eprime_datetime_get(fname,varargin)
% function [date,time,dtres,fileres] = eprime_datetime_get(fname,varargin)
%
% Purpose: extract timestamp from eprime data file
% Based on abcd_extract_eprime_mid.m
%
% Input (required):
%   fname: name of input eprime file
% Output:
%   date
%   time
%   dtres   Result of date&time conversion: 0,1
%   fres    Issues found while reading and interpreting file
%   nruns   Number of runs stored in file
%
% Created:  10/07/16  by Don Hagler
% Last Mod: 2017aug04-14 by Octavio Ruiz
%

date = '';   time = '';   dtres = 0;   fres = 0;   nruns = 0;

if ~mmil_check_nargs(nargin,1), return; end;


% fname sometimes is a copy of the original file, signaled by ' (1)' etc. in its name
% Here I remove those ' (*)' in order to access the original file.
i1 = strfind(fname,' (');
if ~isempty(i1)
    fprintf('\nRequested file name contains parentheses:\n%s\n', fname);
    i2 = strfind(fname,')');
    if ~isempty(i2) && i2 > i1
        % Remove one space, parentheses, and anything between them
        fname(i1:i2) = '';   % Attempted to read file without ' (*)' in file name
        fprintf('Name replaced with\n%s\n', fname);
    else
        fprintf('Unable to fix\n');
    end
end

% check input parameters
parms = check_input(fname,varargin);

% create output directory
mmil_mkdir(parms.outdir);


% Get date and time in eprime (behavioral) data, return first pair in file
try
    [info,fres] = eprime_data_get(parms);
    
    % Select first date&time pair, to be returned
    date = info{1,1};
    time = info{1,2};
    % Check that strings date and time contain valid date and time information;
    % if any of the next conversions fail, we'll go to catch and keep dtres = 0
    datenum(date);
    datenum(time);

    % Find number of unique date&time combinations in file,
    % indicative of number of runs in session
    ddtt = cell2table(info);
    nruns = size( unique(ddtt), 1 );
    
    % If arrived here, everything is right
    dtres = 1;

catch err
    fprintf('%s\n- Unable to get timestamps, or invalid values -\n', fname);
    fprintf('%s\n', err.message);
    date, time, fres

end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function parms = check_input(fname,options)
  parms = mmil_args2parms(options,{...
    'fname',fname,[],...
    ...
    'outdir',pwd,[],...
    'outstem',[],[],...
    'forceflag',true,[false true],...
    ...
    'colnames',  {'SessionDate','SessionTime'},[],...
    'fieldnames',{'date','time'},[],...
  });

  if ~exist(parms.fname,'file')
    error('file %s not found',parms.fname);
  end;
  [fdir,fstem,fext] = fileparts(parms.fname);
  if isempty(parms.outstem)
    parms.outstem = fstem;
  end;
return;
