%Code to generate SeaBASS files for fluorometric chl directly from Access
%database; read from 3 tables: Event, Bottle, and MVCO_chl

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
e = exec(conn,'SELECT ALL Event_Number,Start_Date,Start_Time_UTC,Latitude,Longitude,Water_Depth_m,Secchi_Depth_m,Cloud_Percent,Wind_Speed_kts,Wind_Direction_degrees,Wave_Height_m FROM Event where Cruise_Name = ''MVCO'''); %Melissa added rest of fields necessary - 4/24/08
e = fetch(e);
close(e);

for event_count = 1:length(e.data),
    b = exec(conn,['SELECT ALL Event_Number_Niskin,Depth FROM Bottle where Event_Number = ''' char(e.data(event_count,1)) '''']);
    b = fetch(b);
    bottle_result{event_count} = b.data;
    c = exec(conn,['SELECT ALL Event_Number_Niskin,Chl_ugperL,Phaeo_ugperL FROM Chl_MVCO where Event_Number = ''' char(e.data(event_count,1)) '''']);  %Melissa - think you want to actually use Chl_MVCO (linked excel table) - don't know what the deal is with MVCO_Chl
    %c = exec(conn,['SELECT ALL Event_Number_Niskin,Chl_ugperL,Phaeo_ugperL FROM MVCO_Chl where Event_Number = ''' char(e.data(event_count,1)) '''']);
    c = fetch(c);
    chl_result{event_count} = c.data;
end;

% Close database connection.
close(conn);

% Header information for file.



% clear conn e b c;
    
