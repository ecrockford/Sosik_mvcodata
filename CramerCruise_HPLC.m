%last updated 5/21/14 Taylor
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
SQL_query = 'SELECT ALL * from HPLC_a';  %get all field from the table MVCO_Chl_reps
e =exec(conn, SQL_query);
%e = exec(conn,'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,Filter_Size,"Chl (ug/l)","Phaeo (ug/l)",quality_flag,Cal_Date FROM MVCO_Chl_reps');

e = fetch(e);

attributes = attr(e);
header = cellstr(strvcat(attributes.fieldName));

close(e)

% Close database connection.
close(conn)
    
%Create a variable 'MVCO_chl_reps' which equals the data contained in
%the variable 'e'
data=e.Data;

clear e conn s exec_str tempstr attributes SQL_*

ind=find(strncmp(data(:,1),'C',1));
data=data(ind,:);
clear ind

%change to double, make all below detection
%limit values (0.000999 and -111) to zero values for chemtax use. BDL
%values were originally supplied as 0.000999 and were changed to -111 in
%late 2013 (for seabass purposes)
hplc       = cell2mat(data(:,11:end-1));
BDL         = find(hplc < 0.001);%below detection limit
hplc(BDL)  = 0;
data(:,11:end-1)     = num2cell(hplc);

%get matday first because sometimes data does not extract from access in exact time
%order. re-order for ease of use downstream
tempdate=char(cell2mat(data(:,3)));
temptime=char(cell2mat(data(:,4)));
matdate = datenum([tempdate(:,1:11) temptime(:,12:end-2)]);
[matdate,i]=sort(matdate);
data=data(i,:);
clear temp* i BDL
ymdhhmmss = num2cell(datevec(matdate)); %emily likes individual columsn of date vector for chemtax
date2 = [cellstr(datestr(matdate,'mm/dd/yyyy')) cellstr(datestr(matdate,'hh:mm:ss'))];
%ID=bottle number and HS#
ID = [data(:,2) data(:,8)]; 
depth = data(:,7);

%Lat, Lon
latlon=data(:,5:6);

header4chemtax={'Year','Month','Day','Hour','Minute','Second','CTD NO.','Sample ID','Depth(m)','Date','Time_GMT','Latitude_S','Longitude_E',...
    'TChlb','TChlc','Carot','HexFuc','ButFuc','Allox','Diadin','Diatox','Fucox','Perid','Chl_c12','Chl_c3','Zeaxan','Neoxan','Violax','Prasin','Lutein','Tchla','quality'};

%pigments, found them individually in case need to rearrange later. Used
%averages from hplc varialbe that has different indicies than HPLC variable
TChlb   = data(:,12);
TChlc   = data(:,13);
Carot   = data(:,14);
HexFuc  = data(:,16);
ButFuc  = data(:,15);
Allox   = data(:,17);
Diadin  = data(:,18);
Diatox  = data(:,19);
Fucox   = data(:,20);
Perid   = data(:,21);
Chl_c12 = data(:,30);
Chl_c3  = data(:,31);
Zeaxan  = data(:,22);
Neoxan  = data(:,33);
Violax  = data(:,34);
Prasin  = data(:,37);
Lutein  = data(:,32);
TChla   = data(:,11);
quality = data(:,end);
%combine all pigment columns, 
%use num2cell below to change data double matrix back to cell matrix to
%combine for final variable for ease of using xlswrite below.
pigments = [TChlb TChlc Carot HexFuc ButFuc Allox Diadin Diatox Fucox Perid Chl_c12 Chl_c3 Zeaxan Neoxan Violax Prasin Lutein TChla];
%combine all the individual pieces into one usuable matrix. some pieces of
%matrix numbers, other pieces strings, etc.
HPLC_pigments  = [ymdhhmmss ID depth date2 latlon pigments quality];

save Cramer_HPLC_pigments_for_chemtax HPLC_pigments header4chemtax matdate

%save in excel format for Emily to use in Chemtax - takes out apostrophe's
%in cell array
%updates HPLC_pigments.xls with a new worksheet with all data. the new worksheet is
%labeled with the date it was update.
excel=[header4chemtax;HPLC_pigments];
[status,message]=xlswrite('Cramer_HPLC4chemtax.xls',excel,['Cramer_HPLC_' date])
