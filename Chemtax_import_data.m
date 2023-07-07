%HPLC Chemtax MVCO data
%Creates the variable 'Chemtax_MVCO' as a cell array 

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
% Using ODBC driver. If getting error when trying to close(e) make sure
% that the ODBC driver is pointing to the correct (most up-to-date)
% database. Check connection by going to Control Panel > Administrative
% Tools > Data Sources (ODBC)
conn = database('SOSIK_Database','','password');

% Read data from database.  
% Make the SQL statement easily with querybuilder and paste in here - or select all fields with *
%SQL_query = 'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,"Chl_a_Chl (ug/l)","Chl_b_Chl (ug/l)","Chl_c_Chl (ug/l)" from MVCO_Chl_reps';
SQL_query = 'SELECT ALL * from Sheet1';  %get all field from the table MVCO_Chl_reps
e =exec(conn, SQL_query);
%e = exec(conn,'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,Filter_Size,"Chl (ug/l)","Phaeo (ug/l)",quality_flag,Cal_Date FROM MVCO_Chl_reps');

e = fetch(e);

attributes = attr(e);
header = cellstr(strvcat(attributes.fieldName));

close(e)

% Close database connection.
close(conn)
    
%Create a variable 'Chemtax_MVCO' which equals the data contained in
%the variable 'e'
chemtax_MVCO=e.data;
    
clear e conn s exec_str tempstr attributes SQL_query

event = strvcat(chemtax_MVCO(:,16));
ind = find(event(:,1) == 'M');
event = event(ind,:);

datetemp = char(chemtax_MVCO(ind,3)); datetemp = datetemp(:,1:11);
datetemp2 = char(chemtax_MVCO(ind,17)); datetemp2 = datetemp2(:,12:19);
matdate = datenum([datetemp, datetemp2], 'yyyy-mm-dd HH:MM:SS');
clear datetemp*

lat = cell2mat(chemtax_MVCO(ind,18)); 
lon = cell2mat(chemtax_MVCO(ind,19));
id = cell2mat(chemtax_MVCO(ind,2));
temp = cell2mat(chemtax_MVCO(ind,5:13));
chemtax = [id temp];
meta_data = [matdate lat lon];
meta_header = {'Time_UTC' 'lat' 'lon'};
chemtax_header = [header(2); header(5:13)];

clear lat lon id temp matdate chemtax_MVCO ind header
%Save workspace variables as a .mat file
save('chemtax.mat','chemtax','chemtax_header','meta*');