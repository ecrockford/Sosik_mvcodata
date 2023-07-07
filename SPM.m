%SPMs
%Creates the variable 'spm' as a cell array 

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
e = exec(conn,'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,SPM,"Concentration(g/L)" FROM SPM_Results');
e = fetch(e);
close(e)

% Close database connection.
close(conn)
    
%Create a variable 'MVCO_chl' which equals the data contained in
%the variable 'e'
spm=e.data;
    
clear e conn s

%Create header file with metadata
%creates a 1x9 struct with the metadata information
header{1,1} = 'Event Number';
header{1,2} = 'Niskin Number';
header{1,3} = 'Date';
header{1,4} = 'Time (UTC)';
header{1,5} = 'Latitude (dec deg)';
header{1,6} = 'Longitude (dec deg)';
header{1,7} = 'Depth of sample (m)';
header{1,8} = 'SPM ID';
header{1,9} = 'Concentration (g/L)';

%Save workspace variables as a .mat file
save('SPM_data.mat','spm','header');

%Converts date and time strings into actual dates and times
datetemp = char(spm(:,3));      %creates dates
datetemp = datetemp(:,1:11);

datetemp2 = char(spm(:,4));     %creates times
datetemp2 = datetemp2(:,12:19);

matdate = datenum([datetemp, datetemp2], 'yyyy-mm-dd HH:MM:SS'); %creates variable 'matdate' with formatted dates and times
%to see matdate in something comprehensible, use 'datestr(matdate)'

clear datetemp*

%plot SPM concentration vs matdate
conc = cell2mat(spm(:,9));  %make column 9 (concentrations) in spm a double number instead of a cell
plot(matdate,conc,'--k.','MarkerSize',14);
datetick;




