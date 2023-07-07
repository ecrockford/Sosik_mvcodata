%CHLOROPHYLLS
%Creates the variable 'MVCO_chl_reps' as a cell array 
%last updated 5/7/14 Taylor
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%must run this script in 32-bit Matlab in order to successfully connect to
%Microsoft Access database (as of May2014 - Microsoft 2010, Matlab 2014a 32-bit
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%
% connecting to Access through ODBC database driver. must be setup through:
% C:\Windows\SysWOW64\odbcad32.exe
% setup ms access dbase connection. name must match script database below.
% in this case: SOSIK_Database
%

% Set preferences with setdbprefs.
s.DataReturnFormat = 'cellarray';
s.ErrorHandling = 'store';
s.NullNumberRead = 'NaN';
s.NullNumberWrite = 'NaN';
s.NullStringRead = 'null';
s.NullStringWrite = 'null';
s.JDBCDataSourceFile = '';
s.UseRegistryForSources = 'yes';
s.TempDirForRegistryOutput = '';
setdbprefs(s)

% See more database notes above.
% Make connection to database.  Note that the password has been omitted.
% Using ODBC driver. If getting error when trying to close(e) make sure
% that the ODBC driver is pointing to the correct (most up-to-date)
% database. **** OLD ODBC in 32-bit comp Check connection by going to Control Panel > Administrative
% Tools > Data Sources (ODBC)
conn = database('SOSIK_Database','','password');

% Read data from database.  
% Make the SQL statement easily with querybuilder and paste in here - or select all fields with *
%SQL_query = 'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,"Chl_a_Chl (ug/l)","Chl_b_Chl (ug/l)","Chl_c_Chl (ug/l)" from MVCO_Chl_reps';
SQL_query = 'SELECT ALL * from MVCO_Chl_reps';  %get all field from the table MVCO_Chl_reps
e =exec(conn, SQL_query);
%e = exec(conn,'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,Filter_Size,"Chl (ug/l)","Phaeo (ug/l)",quality_flag,Cal_Date FROM MVCO_Chl_reps');

e = fetch(e);

attributes = attr(e);
header_chl = cellstr(strvcat(attributes.fieldName));

close(e)

% Close database connection.
close(conn)
    
%Create a variable 'MVCO_chl_reps' which equals the data contained in
%the variable 'e'
MVCO_chl_reps=e.Data;
    
clear e conn s exec_str tempstr attributes SQL_*

%Create header file with metadata
%creates a 1x35 struct with the metadata information

%Save workspace variables as a .mat file
save('chl_data_reps.mat','MVCO_chl_reps','header_chl');

%###################################################################
%Format the chl data into a more immediately usable format. Slightly more
%combersome .mat file because more variables in workspace. But chl has
%station numbers assigned. 

matdate         = cell2mat(MVCO_chl_reps(:,3)); 
mattime         = cell2mat(MVCO_chl_reps(:,4));
matdate         = datenum([matdate(:,1:10) mattime(:,11:end-2)]);
clear mattime

%event = strvcat(MVCO_chl_reps(:,2));
lat = cell2mat(MVCO_chl_reps(:,5)); 
lon = cell2mat(MVCO_chl_reps(:,6));
depth = cell2mat(MVCO_chl_reps(:,7));
chl = cell2mat(MVCO_chl_reps(:,8:14));
phaeo = cell2mat(MVCO_chl_reps(:,15:21));
quality = cell2mat(MVCO_chl_reps(:,22:28));
clear datetemp ind count

rep_titles = {'whole a', 'whole b', 'whole c', '<10um a', '<10um b', '<80um a', '<80um b'};

for i=1:size(quality,2)
    badind = find(quality(:,i) == 3);
    chl(badind,i) = NaN;
end
clear badind
chl_station = NaN(length(chl),1);

load setlatlon

for i=1:length(chl)
    if lat(i) > setcoord(1,2) && lat(i) < setcoord(1,3) && lon(i) < setcoord(1,4) && lon(i) > setcoord(1,5)
        chl_station(i) = 1;
    elseif lat(i) > setcoord(2,2) && lat(i) < setcoord(2,3) && lon(i) < setcoord(2,4) && lon(i) > setcoord(2,5)
        chl_station(i) = 2;
     elseif lat(i) > setcoord(3,2) && lat(i) < setcoord(3,3) && lon(i) < setcoord(3,4) && lon(i) > setcoord(3,5)
         chl_station(i) = 3;
     elseif lat(i) > setcoord(4,2) && lat(i) < setcoord(4,3) && lon(i) < setcoord(4,4) && lon(i) > setcoord(4,5)
         chl_station(i) = 4;
     elseif lat(i) > setcoord(5,2) && lat(i) < setcoord(5,3) && lon(i) < setcoord(5,4) && lon(i) > setcoord(5,5)
         chl_station(i) = 5;
     elseif lat(i) > setcoord(6,2) && lat(i) < setcoord(6,3) && lon(i) < setcoord(6,4) && lon(i) > setcoord(6,5)
         chl_station(i) = 6;
     elseif lat(i) > setcoord(7,2) && lat(i) < setcoord(7,3) && lon(i) < setcoord(7,4) && lon(i) > setcoord(7,5)
         chl_station(i) = 7;
    elseif lat(i) > setcoord(8,2) && lat(i) < setcoord(8,3) && lon(i) < setcoord(8,4) && lon(i) > setcoord(8,5)
         chl_station(i) = 8;
    elseif isempty(chl_station(i))
        error('chl out of lat/lon station ranges!')
    end
end
clear i badind
avg_chl = nanmean(chl(:,1:3),2);

save('chl_data_reps_w_stations.mat','MVCO_chl_reps','header_chl','chl_station');
save chl_stations.mat chl phaeo chl_station matdate rep_titles avg_chl lat lon depth header_chl