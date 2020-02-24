function [fres, dir_found, file_found, pGUIDmatch, contents_ok, ...
          ftask, exper_ok, fname_exp_match, ...
          datime_ok, exp_date, exp_time, run, run_date, run_time, tdiff, file_naming, fname, msg] ...
            = abcd_get_eprime_datetime( eprimedir, pGUID, taskname, StudyDate, SeriesTime )
% 
% Purpose: pick best-match EPrime file and run inside file, based on minimum delay relative to series date and time.
% Uses Octavio Ruiz's (2018may-2019dec) Python script to locate and read E-Prime spreadsheet files
%
% Input (required):
%   eprimedir    Path to eprime file directory
%   . . .
% Output:
%   fres         File-locating-and-interpreting result: ok or issues found while reading and interpreting file
%   . . .
%   file_naming  File name starts with the official 'NDAR_INV..."
%   ftask
%   exp_date
%   exp_time
%   run
%   run_date
%   run_time
%   tdiff        Time difference, minutes, of picked EPrime file & run relative to series date & time
%   fname_pick
%   . . .
%
% Created:  08/04/17 by Octavio Ruiz
% Prev Mod: 03/17/18 by Don Hagler
% Prev Mod: 12/04/19 by Octavio Ruiz
% Last Mod: 01/29/20 by Don Hagler|
%

% Defaults: values to return in case of not being able to get E-Prime information
fres = 0;         dir_found = 0;   file_found = 0;   pGUIDmatch = 0;   contents_ok = 0;
ftask = '';       exper_ok = 0;    fname_exp_match = 0;
datime_ok = 0;    exp_date = '';   exp_time = '';
run = 0;          run_date = '';   run_time = '';    tdiff = '';
file_naming = 0;  fname = '';      msg = '';

if strcmp( eprimedir, 'SetDefaults')
    return
end

% Get values from a file under given directory, First, assume we'll find nothing
fres = -2048;

% Check for Python (Don H.)
cmd = 'which python3';
[s,r] = unix(cmd);
if s || ~isempty(regexp(r,'not found'))
  error('Error: no Python3 found to run eprime_sprdsht_get.py');
end;

% Use Octavio's Python eprime_sprdsht_get.py to select and read file, and
% to extract the date and time of the run that minimizes the difference with the given date & time
cmnd0 = 'python3 $MMPS_DIR/python/eprime_sprdsht_get.py';
cmndline = sprintf('%s  %s  PickFile  "%.0f %.0f"  %s  %s  Info',  cmnd0, eprimedir, StudyDate, SeriesTime, pGUID, taskname );
[status, cmdout] = mmil_unix( cmndline );

% eprime_sprdsht_get.py returns a line with these values:
%   diagnos  dir_found  file_found  pGUIDmatch  contents_ok  exper  exper_ok  fname_exp_match
%   datime_ok  exp_t0  run  run_t0  tdiff  naming_ok  fname  msg

if status == 0
  if length(cmdout) > 16
    % Decode the returned line. There are two instructions per field:
    % the first assignment extracts a substring, the second converts the string to the required type: integer, string, float
    try
      [diagnos,     moreinfo] = strtok(cmdout, ',');     diagnos     = str2double( strtrim(strtok(diagnos, ',')));
      [dir_found,   moreinfo] = strtok(moreinfo, ',');   dir_found   = str2double( strtrim(strtok(dir_found, ',')));
      [file_found,  moreinfo] = strtok(moreinfo, ',');   file_found  = str2double( strtrim(strtok(file_found, ',')));
      [pGUIDmatch,  moreinfo] = strtok(moreinfo, ',');   pGUIDmatch  = str2double( strtrim(strtok(pGUIDmatch, ',')));
      [contents_ok, moreinfo] = strtok(moreinfo, ',');   contents_ok = str2double( strtrim(strtok(contents_ok, ',')));
      [ftask,           moreinfo] = strtok(moreinfo, ',');   ftask           = strtrim(strtok(ftask, ','));
      [exper_ok,        moreinfo] = strtok(moreinfo, ',');   exper_ok        = str2double( strtrim(strtok(exper_ok, ',')));
      [fname_exp_match, moreinfo] = strtok(moreinfo, ',');   fname_exp_match = str2double( strtrim(strtok(fname_exp_match, ',')));

      [datime_ok,  moreinfo] = strtok(moreinfo, ',');    datime_ok   = str2double( strtrim(strtok(datime_ok, ',')) );
      [exp_datime, moreinfo] = strtok(moreinfo, ',');    exp_datime  = strtrim( strtok(exp_datime, ',') );
      [run,        moreinfo] = strtok(moreinfo, ',');    run         = str2double( strtrim(strtok(run, ',')));
      [run_datime, moreinfo] = strtok(moreinfo, ',');    run_datime  = strtrim( strtok(run_datime, ',') );
      [tdiff,      moreinfo] = strtok(moreinfo, ',');    tdiff       = str2double( strtrim(strtok(tdiff, ',')));

      [file_naming, moreinfo] = strtok(moreinfo, ',');   file_naming = str2double( strtrim(strtok(file_naming, ',')));
      [fname,       moreinfo] = strtok(moreinfo, ',');   fname       = strtrim(strtok(fname, ','));
      msg = strtrim(strtok(moreinfo, ','));

      if file_found && contents_ok && exper_ok && datime_ok
        try
          exp_date = str2double( datestr( exp_datime, 'yyyymmdd') );
          exp_time = str2double( datestr( exp_datime, 'HHMMSS') );
          % If arrived here, everything is right
          fres = diagnos;
        catch err
          fprintf('%s: WARNING: unable to get/interpret experiment date or time. Command: %s\n',...
            mfilename,cmndline);
          fres = -512 + diagnos;
        end
        try
          run_date = str2double( datestr( run_datime, 'yyyymmdd') );
          run_time = str2double( datestr( run_datime, 'HHMMSS') );
          % If arrived here, everything is right
          fres = diagnos;
        catch err
          fprintf('%s: WARNING: unable to get/interpret run date or time. Command: %s\n',...
            mfilename,cmndline);
          fres = -512 + diagnos;
        end
      else
        fname = '';
        exp_date = '';
        exp_time = '';
        run_date = '';
        run_time = '';
      end

    catch err
      fprintf('%s: WARNING: unable to read/interpret file. Command: %s\n',...
        mfilename,cmndline);
      fres = -512;
      return
    end
  else
    fprintf('%s: WARNING: unable to get E-Prime files information from specified directory: %s\n',...
      mfilename,cmndline);
    fres = -1024;
  end
else
  fprintf('%s: WARNING: error while calling: %s\n',...
    mfilename,cmndline);
  fres = -2048;
end

return
