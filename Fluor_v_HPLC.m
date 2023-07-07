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
% Make the SQL statement easily with querybuilder and paste in here - or select all fields with *
%SQL_query = 'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,"Chl_a_Chl (ug/l)","Chl_b_Chl (ug/l)","Chl_c_Chl (ug/l)"';
SQL_query = 'SELECT ALL * from FLUOR_v_HPLC';  %get all field from the table MVCO_Chl_reps
e =exec(conn, SQL_query);
%e = exec(conn,'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,Filter_Size,"Chl (ug/l)","Phaeo (ug/l)",quality_flag,Cal_Date FROM MVCO_Chl_reps');
e = fetch(e);

attributes = attr(e);
header = cellstr(strvcat(attributes.fieldName));

close(e)

% Close database connection.
close(conn)
    
%Create a variable 'MVCO_chl' which equals the data contained in
%the variable 'e'
FLUOR_v_HPLC=e.Data;
    
clear e conn s exec_str tempstr

%Create header file with metadata
%creates a 1x20 struct with the metadata information

%Save workspace variables as a .mat file
save('FLUOR_v_HPLC.mat','FLUOR_v_HPLC','header');