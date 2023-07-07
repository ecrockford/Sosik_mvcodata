%CHLOROPHYLLS
%Creates the variable 'chl' as a cell array 

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
e = exec(conn,'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,Filter_Size,"Chl (ug/l)","Phaeo (ug/l)",quality_flag,Cal_Date FROM MVCO_Chl');
e = fetch(e);
close(e);

% Close database connection.
close(conn)
    
%Create a variable 'MVCO_chl' which equals the data contained in
%the variable 'e'
MVCO_chl=e.data;
    
clear e conn s

%Create header file with metadata
%creates a 1x12 struct with the metadata information
 header{1,1} = 'Event Number';
 header{1,2} = 'Niskin Number';
 header{1,3} = 'Date';
 header{1,4} = 'Time (UTC)';
 header{1,5} = 'Latitude (dec deg)';
 header{1,6} = 'Longitude (dec deg)';
 header{1,7} = 'Depth of sample (m)';
 header{1,8} = 'Filter Size';
 header{1,9} = 'Chl conc (ug/L)';
 header{1,10} = 'Phaeo conc (ug/L)';
 header{1,11} = 'Quality Flag';
 header{1,12} = 'Chl_Cal Date';

%Save workspace variables as a .mat file
save('chl_data.mat','MVCO_chl','header');