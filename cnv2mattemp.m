function [lat,lon,gtime,data,names,sensors]=cnv2mat(cnv_file,ctd_header);
% CNV2MAT Reads the SeaBird ASCII .CNV file format
%
%  Usage:   [lat,lon,gtime,data,names,sensors]=cnv2mat(cnv_file);
%
%     Input:  cnv_file = name of .CNV file  (e.g. 'cast002.cnv')
%
%     Output: lon = longitude in decimal degrees, West negative
%             lat = latitude in decimal degrees, North positive
%           gtime = Gregorian time vector in UTC
%            data = matrix containing all the columns of data in the .CNV file
%           names = string matrix containing the names and units of the columns
%         sensors = string matrix containing the names of the sensors
%
%  NOTE: How lon,lat and time are written to the header of the .CNV
%        file may vary with CTD setup.  For our .CNV files collected on 
%        the Oceanus, the lat, lon & time info look like this:
%
%    * System UpLoad Time = Mar 30 1998 18:48:42
%    * NMEA Latitude = 42 32.15 N
%    * NMEA Longitude = 069 28.69 W
%    * NMEA UTC (Time) = 23:50:36
%
%  Modify the lat,lon and date string handling if your .CNV files are different.

%  4-8-98  Rich Signell (rsignell@usgs.gov)  
%     incorporates ideas from code by Derek Fong & Peter Brickley
%

% Open the .cnv file as read-only text
%
lat = NaN;
lon = NaN;
fid=fopen(cnv_file,'rt');
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
%    Read the NMEA latitude string.  This may vary with CTD setup.
%
    if (strncmp(str,'* NMEA Lat',10))
        is=findstr(str,'=');
        isub=is+1:length(str);
        dm=sscanf(str(isub),'%f',2);
        if(findstr(str(isub),'N'));
           lat=dm(1)+dm(2)/60;
        else  
           lat=-(dm(1)+dm(2)/60); 
        end
%-------------------------------
%
%    Read the NMEA longitude string.  This may vary with CTD setup.
%
     elseif (strncmp(str,'* NMEA Lon',10))
        is=findstr(str,'=');
        isub=is+1:length(str);
        dm=sscanf(str(isub),'%f',2);
        if(findstr(str(isub),'E'));
           lon=dm(1)+dm(2)/60;
        else  
           lon=-(dm(1)+dm(2)/60); 
        end
%------------------------
%
%    Read the 'System upload time' to get the date.
%           This may vary with CTD setup.
%
%    I'm reading this in to get the date, since the NMEA time string
%    does not contain date.  Unfortunately, the system upload time is
%    in local time (here, EST), so I need to convert to UTC by adding
%    5 hours (5/24 days).
%       %HEIDI - OURS ARE UTC ALREADY - don't add 5/24
    elseif (strncmp(str,'* System UpLoad',15))
        is=findstr(str,'=');
%    pick apart date string and reassemble in DATEFORM type 0 form
        datstr=[str(is+6:is+7) '-' str(is+2:is+4) '-' str(is+9:is+12)];
        datstr=[datstr ' ' str(is+14:is+21)];
%    convert datstr to Julian time, add 5 hours to convert from EST to GMT
        n=datenum(datstr)  %+5/24; %Heidi
        gtime=datevec(n);
%----------------------------
%
%    Read the NMEA TIME string.  This may vary with CTD setup.
%
%      replace the System upload time with the NMEA time
     elseif (strncmp(str,'* NMEA UTC',10))
        is=findstr(str,':');
        isub=is(1)-2:length(str);
        gtime([4:6])=sscanf(str(isub),'%2d:%2d:%2d');
%------------------------------
% Hand casts with Seabird ctd have different header format. Does not
% contain date/time line with NMEA formate or system upload time. Line 
% always starts with '* cast' followed by a number that represents cast 
% number of that day. 

    elseif (strncmp(str,'* cast',6))
        is=findstr(str,'samples');
%    pick apart date string and reassemble in DATEFORM type 0 form
        datstr=[str(is-21:is-20) '-' str(is-18:is-16) '-' str(is-14:is-11)];
        datstr=[datstr ' ' str(is-9:is-2)];
%    convert datstr to Julian time, add 5 hours to convert from EST to GMT
        n=datenum(datstr)+5/24; %Heidi took out in cnv2mat because our Tioga files are in UTC but handcasts are in local
        gtime=datevec(n);

%------------------------------
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
%      elseif (strncmp(str,'# sensor',8))  
%         sens=sscanf(str(10:11),'%d',1);
%         sens=sens+1;  % .CNV file counts from 0, Matlab counts from 1
%  %      stuff sensor names into cell array
%       sensors{sens}=str;
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

%############################ if working with handcast need to set lat/lon
if ~isempty(strfind(cnv_file,'hand'))
    lat = 41.325;
    lon = -70.5667;
end
if ~isempty(strfind(cnv_file,'12Mnode'))
    lat = 41.335;
    lon = -70.555;
end

%
% Flag bad values with nan
%
ind=find(tempdata==bad_flag);
tempdata(ind)=tempdata(ind)*nan;

%
% Flip data around so that each variable is a column
tempdata=tempdata.';
data = NaN(size(tempdata,1),length(ctd_header)-3);
Tiogacnv_header={'Depth' 'Pressure' 'Temperature' 'Conductivity' 'Salinity' 'Density' 'Fluorescence' 'Turbidity' 'bat:' 'Oxygen' 'PAR' 'altM:' 'bct:' 'nbf:' 'Time,' 'nbin:' 'flag:'};
for i=1:length(Tiogacnv_header)
    temp = strfind(names,char(Tiogacnv_header(i)));
    for count = 1:length(temp), junk(count) = ~isempty(temp{count}); end;
    b = find(junk); %default for find is find where junk =1 (and not =0)
    if ~isempty(b),
        data(:,i) = tempdata(:,b);
    end;
end

% Convert cell arrays of names to character matrices
names=char(names);
%sensors=char(sensors);

return
