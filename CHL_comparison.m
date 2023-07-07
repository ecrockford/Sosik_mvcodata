%Takes all variables from 'CHL_ours_vs_HPLC' table in
%Sosik Database and puts them into a cell array 'CHL_comparison'

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

% Make connection to database.  Note that the password has been omitted.
% Using ODBC driver.
conn = database('SOSIK_Database','','password');

% Read data from database.
e = exec(conn,'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,Filter_Size,Chl_a,Chl_b,HPLC_Name,FL_Chl_a,Total_Chl_a,quality_flag_a,quality_flag_b,Cal_Date_a,Cal_Date_b,Phaeo_a,Phaeo_b,Pheophytin,Pheophorbide_a FROM CHL_ours_vs_HPLC');
e = fetch(e);
close(e);

% Close database connection.
close(conn);

%Create a variable 'non_reps' which equals the data contained in
%the variable 'e'
CHL_comparison_data=e.data;

clear conn e s;
    
%To get rid of all the extra HPLC entries and convert the lat, lon, and
%depth columns from strings to numbers
%for i = (1:118),
    %if ( isnan (CHL_comparison{i,10}) == 1),
       %CHL_comparison{i,11} = NaN;
    %end;
    %if ( isnan (CHL_comparison{i,11}) == 1),
        %CHL_comparison{i,12} = NaN;
    %end;
    %if ( isnan (CHL_comparison{i,11}) == 1),
        %CHL_comparison{i,13} = NaN;
    %end;
    %CHL_comparison{i,5}=str2double(CHL_comparison{i,5}); 
    %CHL_comparison{i,6}=str2double(CHL_comparison{i,6}); 
    %CHL_comparison{i,7}=str2double(CHL_comparison{i,7});
%end;

clear i;

%Create header file with metadata
%creates a 1x17 struct with the metadata information
 header{1,1} = 'Event Number';
 header{1,2} = 'Niskin Number';
 header{1,3} = 'Date';
 header{1,4} = 'Time (UTC)';
 header{1,5} = 'Latitude (dec deg)';
 header{1,6} = 'Longitude (dec deg)';
 header{1,7} = 'Depth of sample (m)';
 header{1,8} = 'Filter Size';
 header{1,9} = 'Chl conc. (ug/L) of sample a';
header{1,10} = 'Chl conc. (ug/L) of sample b';
header{1,11} = 'HPLC name';
header{1,12} = 'Fluor of Chl a from HPLC';
header{1,13} = 'Total Chl a (ug/L) from HPLC';
header{1,14} = 'Quality Flag a'
header{1,15} = 'Quality Flag b'
header{1,16} = 'Chl_Cal_Date a'
header{1,17} = 'Chl_Cal_Date b'
header{1,18} = 'Phaeo_a'
header{1,19} = 'Phaeo_b'
header{1,20} = 'Pheophytin'
header{1,21} = 'Pheophorbide_a'

% Save workspace variable as a .mat file
save('CHL_comparison_data.mat','CHL_comparison_data','header');