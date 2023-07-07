function [lat,lon,gtime,data,names,sensors]=cnv2mat4hand(file,ctd_header);
%modified from cnv2mat by Taylor 12/30/10
% CNV2MAT Reads the SeaBird ASCII .CNV file format
%
%  Usage:   [lat,lon,gtime,data,names,sensors]=cnv2mat(cnv_file);
%
%     Input:  cnv_file = name of .CNV file  (e.g. 'cast002.cnv')
%
%     Output: lon = manually input assuming ASIT tower, West negative
%             lat = manually input assuming ASIT tower, North positive
%             lat/lon in decimal degrees 41.325 N, -70.5667 W
%           gtime = Gregorian time vector in UTC
%            data = matrix containing all the columns of data in the .CNV file
%           names = string matrix containing the names and units of the columns
%         sensors = string matrix containing the names of the sensors
%
%  NOTE: How lon,lat and time are written to the header of the .CNV
%        file may vary with CTD setup.  For our .CNV files collected using 
%        handcast, the lat, lon do not exist in file & time info look like this:
%
%  * cast   1 21 May 2010 13:52:06 samples 1 to 493, avg = 1, stop = mag switch
%
%  Modify the lat,lon and date string handling if your .CNV files are different.

%  4-8-98  Rich Signell (rsignell@usgs.gov)  
%     incorporates ideas from code by Derek Fong & Peter Brickley
%

% Open the .cnv file as read-only text
%
lat = 41.325;
lon = -70.5667;
if ~isempty(strfind(file,'12Mnode'))
    lat = 41.335;
    lon = -70.555;
end
fid=fopen(file,'rt');
% 
% Read the header.
% Start reading header lines of .CNV file,
% Stop at line that starts with '*END*'
%
% Pull out NMEA lat & lon along the way and look
% at the '# name' fields to see how many variables we have.
%
str='*START*';
while (~strncmp(str,'*END*',5));
     str=fgetl(fid);
%-----------------------------------
%

% #########################################################################
% ******** LAT/LON extract from original cnv2mat.m taken out***************
% seabird handcasts don't have lat/lon. assuming all casts from ASIT use
% coordinates above. if handcast not at tower must manually input for special
% file names!!!!
% *************************************************************************
% #########################################################################
% 
     
%------------------------
%
%    Read the 'System upload time' to get the date.
%           This may vary with CTD setup.
% Hand casts with Seabird ctd have different header format. Does not
% contain date/time line with NMEA formate or system upload time. Line 
% always starts with '* cast' followed by a number that represents cast 
% number of that day. 

%HEIDI - Tioga rosette casts ARE UTC ALREADY - don't add 5/24
     if (strncmp(str,'* cast',6))
        is=findstr(str,'samples');
%    pick apart date string and reassemble in DATEFORM type 0 form
        datstr=[str(is-21:is-20) '-' str(is-18:is-16) '-' str(is-14:is-11)];
        datstr=[datstr ' ' str(is-9:is-2)];
%    convert datstr to Julian time, add 5 hours to convert from EST to GMT
        n=datenum(datstr)+5/24; %Heidi took out in cnv2mat because our Tioga files are in UTC but handcasts are in local
        gtime=datevec(n);
%----------------------------
% left original NMEA read in because doesn't harm addition format of handcast
%    Read the NMEA TIME string.  This may vary with CTD setup.
%
%      replace the System upload time with the NMEA time
     elseif (strncmp(str,'* NMEA UTC',10))
        is=findstr(str,':');
        isub=is(1)-2:length(str);
        gtime([4:6])=sscanf(str(isub),'%2d:%2d:%2d');
%------------------------------
%
%    Read the variable names & units into a cell array
%
     elseif (strncmp(str,'# name',6))  
        var=sscanf(str(7:10),'%d',1);
        var=var+1;  % .CNV file counts from 0, Matlab counts from 1
 %      stuff variable names into cell array
      names{var}=str;
%------------------------------
%
%    Read the sensor names into a cell array
%
     elseif (strncmp(str,'# sensor',8))  
        sens=sscanf(str(10:11),'%d',1);
        sens=sens+1;  % .CNV file counts from 0, Matlab counts from 1
 %      stuff sensor names into cell array
      sensors{sens}=str;
%
%  pick up bad flag value
     elseif (strncmp(str,'# bad_flag',10))  
        isub=13:length(str);
        bad_flag=sscanf(str(isub),'%g',1);
     end
end
%==============================================
%
%  Done reading header.  Now read the data!
%
nvars=var;  %number of variables

% Read the data into one big matrix
%
tempdata=fscanf(fid,'%f',[nvars inf]);

fclose(fid);

%
% Flag bad values with nan
%
ind=find(tempdata==bad_flag);
tempdata(ind)=tempdata(ind)*nan;

%
% Flip data around so that each variable is a column
tempdata=tempdata.';
data = NaN(size(tempdata,1),length(ctd_header)-3);
clear ind fid nvars inf var str bad_flag isub is

cnv_header = {'Depth' 'Pressure' 'Temperature' 'Conductivity' 'Salinity' 'Density' 'Flourescence' 'Turbidity' 'Beam Attenuation' 'Oxygen' 'PAR' 'Time' 'nbin:' 'flag:'};
for i=1:length(cnv_header)
    test=NaN(1,length(names));
    if i > 11
        a=i+3;
    else a=i;
    end
    if ~isempty(cell2mat(strfind(names,char(cnv_header(i)))))
        test(i)=1;
    b = find(~isnan(test));
    data(:,a) = tempdata(:,b);
    end
    clear b
end

%{
a = strfind(names,'Depth');
b = find(~isempty(cell2mat(a)));
if ~isempty(b)
    c = find(strcmp(ctd_header, 'depth m'));
    data(:,c) = tempdata(:,b);
end

a = strfind(names,'Pressure');
b = find(~isempty(cell2mat(a)));
if ~isempty(b)
    c = find(strcmp(ctd_header, 'pressure db'));
    data(:,c) = tempdata(:,b);
end

a = strfind(names,'Temperature');
b = find(~isempty(cell2mat(a)));
if ~isempty(b)
    c = find(strcmp(ctd_header, 'temperature deg C'));
    data(:,c) = tempdata(:,b);
end

a = strfind(names,'Conductivity');
b = find(~isempty(cell2mat(a)));
if ~isempty(b)
    c = find(strcmp(ctd_header, 'conductivity S/m'));
    data(:,c) = tempdata(:,b);
end

a = strfind(names,'Salinity');
b = find(~isempty(cell2mat(a)));
if ~isempty(b)
    c = find(strcmp(ctd_header, 'salinity psu'));
    data(:,c) = tempdata(:,b);
end

a = strfind(names,'Density');
b = find(~isempty(cell2mat(a)));
if ~isempty(b)
    c = find(strcmp(ctd_header, 'density kg/m^3'));
    data(:,c) = tempdata(:,b);
end

a = strfind(names,'Fluorescence');
b = find(~isempty(cell2mat(a)));
if ~isempty(b)
    c = find(strcmp(ctd_header, 'fluorescence mg/m^3'));
    data(:,c) = tempdata(:,b);
end

a = strfind(names,'Turbidity');
b = find(~isempty(cell2mat(a)));
if ~isempty(b)
    c = find(strcmp(ctd_header, 'turbidity ftu'));
    data(:,c) = tempdata(:,b);
end

a = strfind(names,'Beam Attenuation');
b = find(~isempty(cell2mat(a)));
if ~isempty(b)
    c = find(strcmp(ctd_header, 'beam attenuation 1/m'));
    data(:,c) = tempdata(:,b);
end

a = strfind(names, 'Oxygen');
b = find(~isempty(cell2mat(a)));
if ~isempty(b)
    c = find(strcmp(ctd_header, 'oxygen conc mg/l'));
    data(:,c) = tempdata(:,b);
end
    
a = strfind(names,'PAR');
b = find(~isempty(cell2mat(a)));
if ~isempty(b)
    c = find(strcmp(ctd_header, 'PAR'));
    data(:,c) = tempdata(:,b);
end

a = strfind(names,'Time,');
b = find(~isempty(cell2mat(a)));
if ~isempty(b)
    c = find(strcmp(ctd_header, 'time elapsed min'));
    data(:,c) = tempdata(:,b);
end

a = strfind(names,'nbin:');
b = find(~isempty(cell2mat(a)));
if ~isempty(b)
    c = find(strcmp(ctd_header, 'no scans per bin'));
    data(:,c) = tempdata(:,b);
end

a = strfind(names,'flag:');
b = find(~isempty(cell2mat(a)));
if ~isempty(b)
    c = find(strcmp(ctd_header, 'flag'));
    data(:,c) = tempdata(:,b);
end
%}

% Convert cell arrays of names to character matrices
names=char(names);
sensors=char(sensors);

return

