%NUTRIENTS
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
%Creates the variable 'MVCO_nut_reps' as a cell array  
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
%SQL_query = 'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,"Nut_a_uM NO2- + NO3-","Nut_b_uM NO2- + NO3-","Nut_c_uM NO2- + NO3-","Nut_a_uM NH4+","Nut_b_uM NH4+","Nut_c_uM NH4+","Nut_a_uM SiO2-","Nut_b_uM SiO2-","Nut_c_uM SiO2-","Nut_a_uM PO43-","Nut_b_uM PO43-","Nut_c_uM PO43-" FROM MVCO_Nut_reps';
SQL_query = 'SELECT ALL * from MVCO_Nut_reps';  %get all field from the table MVCO_Nut_reps
e =exec(conn, SQL_query);

%e = exec(conn,'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,"Nut_a_uM NO2- + NO3-","Nut_b_uM NO2- + NO3-","Nut_c_uM NO2- + NO3-","Nut_a_uM NH4+","Nut_b_uM NH4+","Nut_c_uM NH4+","Nut_a_uM SiO2-","Nut_b_uM SiO2-","Nut_c_uM SiO2-","Nut_a_uM PO43-","Nut_b_uM PO43-","Nut_c_uM PO43-" FROM MVCO_Nut_reps');

e = fetch(e);

attributes = attr(e);
header_nut = cellstr(strvcat(attributes.fieldName));

close(e)

% Close database connection.
close(conn)
    
%Create a variable 'MVCO_nut_reps' which equals the data contained in
%the variable 'e'
MVCO_nut_reps=e.Data;
    
clear e conn s exec_str tempstr SQL* attributes

%Create header file with metadata
%creates a 1x19 struct with the metadata information

lat = cell2mat(MVCO_nut_reps(:,5)); 
lon = cell2mat(MVCO_nut_reps(:,6));
%Tchl_HPLC = [cell2mat(HPLC(:,37)) cell2mat(HPLC(:,89))];
load setlatlon

station4nut = NaN(length(MVCO_nut_reps),1);
for i=1:length(station4nut)
    if lat(i) > setcoord(1,2) && lat(i) < setcoord(1,3) && lon(i) < setcoord(1,4) && lon(i) > setcoord(1,5)
        station4nut(i) = 1;
    elseif lat(i) > setcoord(2,2) && lat(i) < setcoord(2,3) && lon(i) < setcoord(2,4) && lon(i) > setcoord(2,5)
        station4nut(i) = 2;
     elseif lat(i) > setcoord(3,2) && lat(i) < setcoord(3,3) && lon(i) < setcoord(3,4) && lon(i) > setcoord(3,5)
         station4nut(i) = 3;
     elseif lat(i) > setcoord(4,2) && lat(i) < setcoord(4,3) && lon(i) < setcoord(4,4) && lon(i) > setcoord(4,5)
         station4nut(i) = 4;
     elseif lat(i) > setcoord(5,2) && lat(i) < setcoord(5,3) && lon(i) < setcoord(5,4) && lon(i) > setcoord(5,5)
         station4nut(i) = 5;
     elseif lat(i) > setcoord(6,2) && lat(i) < setcoord(6,3) && lon(i) < setcoord(6,4) && lon(i) > setcoord(6,5)
         station4nut(i) = 6;
     elseif lat(i) > setcoord(7,2) && lat(i) < setcoord(7,3) && lon(i) < setcoord(7,4) && lon(i) > setcoord(7,5)
         station4nut(i) = 7;
    elseif lat(i) > setcoord(8,2) && lat(i) < setcoord(8,3) && lon(i) < setcoord(8,4) && lon(i) > setcoord(8,5)
         station4nut(i) = 8;
    else
        error('Nutrient out of lat/lon station ranges or missing!')
    end
end
clear i lat lon 


%Save workspace variables as a .mat file
save('nut_data_reps.mat','MVCO_nut_reps','station4nut','header_nut');

%make usable mat file
nut=cell2mat(MVCO_nut_reps(:,8:end));
ind=find(~isnan(nut(:,1)));
MVCO_nut_reps=MVCO_nut_reps(ind,:);
nut=cell2mat(MVCO_nut_reps(:,8:end));
lat=cell2mat(MVCO_nut_reps(:,5));
lon=cell2mat(MVCO_nut_reps(:,6));
depth=cell2mat(MVCO_nut_reps(:,7));
datetemp=char(MVCO_nut_reps(:,3));
datetemp2=char(MVCO_nut_reps(:,4));
matday = datenum([datetemp(:,1:11) datetemp2(:,12:end-2)],'yyyy-mm-dd HH:MM:SS');
station4nut=station4nut(ind);
save nut2plot MVCO_nut_reps nut lat lon depth matday station4nut




