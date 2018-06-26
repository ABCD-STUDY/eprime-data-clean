function [fres, pGUIDmatch, file_naming, date, time, ftask, tdiff, fname_pick] ...
            = abcd_get_eprime_datetime( eprimedir, pGUID, taskname, StudyDate, SeriesTime)
%
% Purpose: pick best-match EPrime file name, location, date and time,
% and delay relative to series date and time.
% Uses Octavio Ruiz's (2018may) Python script to extract data from E-Prime spreadsheet files
%
% Input (required):
%   fname: name of input eprime file directory
% Output:
%   fres         File-locating-and-interpreting result: ok or issues found while reading and interpreting file
%   file_naming  File name starts with the official 'NDAR_INV..."
%   date
%   time
%   ftask
%   tdiff        Time difference, minutes, of picked EPrime file relative to series date & time
%   fname_pick
%
% Created:  08/04/17 by Octavio Ruiz
% Prev Mod: 10/20/17 by Octavio Ruiz
% Prev Mod: 03/17/18 by Don Hagler
% Last Mod: 06/15/18 by Octavio Ruiz

fres = -1024;   pGUIDmatch = 0;   file_naming = 0;   date = '';   time = '';   ftask = '';   tdiff = '';   fname_pick = '';

% Check for Python (Don H.)
cmd = 'which python3';
[s,r] = unix(cmd);
if s || ~isempty(regexp(r,'not found'))
  error('Error: no Python3 found to run eprime_sprdsht_get.py');
end;

% Use python script to read file and get task-start date and time
% For TESTs: -------------------------------------------------
% command = './python/eprime_sprdsht_get.py';
% cmndline = sprintf('%s  %s  PickFile  "%.0f %.0f"  %s  %s  Info',  command, eprimedir, StudyDate, SeriesTime, pGUID, taskname );
% ------------------------------------------------- :for TESTs
cmnd0 = 'python3 $MMPS_DIR/python/eprime_sprdsht_get.py';
cmndline = sprintf('%s  %s  PickFile  "%.0f %.0f"  %s  %s  Info',  cmnd0, eprimedir, StudyDate, SeriesTime, pGUID, taskname );

% Octavio (2018may25):
% Hauke is plugging my eprime_sprdsht_get.py into the proces that uploads data
% at each ABCD site, in order to test for appropriatness of the EPrime files.
% To use it there, I am returning non-standard exit code:
% 0 => error or file not found, read, interpreted, consistent;
% larger than 1 is my diagnos number.

[status, cmdout] = system( cmndline );
 
if status > 0
    [diagnos, moreinfo] = strtok(cmdout, ',');
    try
        diagnos = str2double(diagnos);
        if diagnos > 0
            % Decode remaining response
            [pGUIDmatch,  moreinfo] = strtok(moreinfo, ',');   pGUIDmatch  = str2double( strtrim(strtok(pGUIDmatch, ',')));
            [file_naming, moreinfo] = strtok(moreinfo, ',');   file_naming = str2double( strtrim(strtok(file_naming, ',')));
            [datime,      moreinfo] = strtok(moreinfo, ',');   datime = strtrim(strtok(datime, ','));
            [ftask,       moreinfo] = strtok(moreinfo, ',');   ftask  = strtrim(strtok(ftask, ','));
            [tdiff,     fname_pick] = strtok(moreinfo, ',');   tdiff = str2double( strtrim(strtok(tdiff, ',')) );
            if isnan(tdiff)
                tdiff = '';
            end
            fname_pick = strtrim(strtok(fname_pick, ','));

            % Parse returned information into date, time, and file diagnostics
            try
                date = str2double( datestr( datime, 'yyyymmdd') );
                time = str2double( datestr( datime, 'HHMMSS') );
                % If arrived here, everything is right
                fres = diagnos;
            catch err
                fprintf('Unable to get/interpret datetime. Command: %s\n', cmndline);
                fres = -512 + diagnos;
            end
        else
            fprintf('Unable to read/interpret file. Command: %s\n', cmndline);
            fres = diagnos;
            return
        end
    catch err
        fprintf('Unable to read/interpret file. Command: %s\n', cmndline);
        fres = -512;
        return
    end
else
    fprintf('Error while calling: %s\n', cmndline);
    fres = -1024;
end

return
