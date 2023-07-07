% creats consistently formatted text files for submission to NASA Ocean
% Color SeaBASS data repository
% 
%last updated 5/7/14 Taylor
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%must run this script in 32-bit Matlab in order to successfully connect to
%Microsoft Access database (as of May2014 - Microsoft 2010, Matlab 2014a 32-bit
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% connecting to Access through ODBC database driver. must be setup through:
% C:\Windows\SysWOW64\odbcad32.exe
% setup ms access dbase connection. name must match script database below.
% in this case: SOSIK_Database
% 
% last edited 17Sept2013 updated documents & cal file headers after working
%with Chris Proctor (christopher.w.proctor@nasa.gov) from NASA

commentstr='For submission to seabass.';
datadir = 'C:\from_Samwise\data\mvcodata\';
investigators = 'Heidi_Sosik';
contact = 'hsosik@whoi.edu';
data_type = 'pigment';
data_status = 'preliminary';
calibration_files = 'seabass_mvcochl.xls,MVCO_chl_protocol.doc';
experiment = 'MVCO';
station = 'NA';

%CHLOROPHYLLS
%Creates the variable 'MVCO_chl_reps' as a cell array 

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
% database. See instructions above
conn = database('SOSIK_Database','','password');

% Read data from database.  
% Make the SQL statement easily with querybuilder and paste in here - or select all fields with *
SQL_query = 'SELECT ALL * from MVCO_Chl_reps';  %get all field from the table MVCO_Chl_reps
e =exec(conn, SQL_query);
e = fetch(e);
attributes = attr(e);
header = cellstr(strvcat(attributes.fieldName));
close(e);

%Create a variable 'MVCO_chl_reps' which equals the data contained in
%the variable 'e'
MVCO_chl_reps=e.Data;
    
clear e 

SQL_query = 'SELECT ALL * from Event';  %get all field from the table MVCO_Chl_reps
e =exec(conn, SQL_query);
e = fetch(e);
attributes = attr(e);
header_event = cellstr(strvcat(attributes.fieldName));
close(e);
%Creat variable 'event' for all sample metadata
event = e.Data;

% Close database connection.
close(conn);
    
clear e conn s

event_num = strvcat(MVCO_chl_reps(:,1));
fluorometer = strvcat(MVCO_chl_reps(:,end));
lat = cell2mat(MVCO_chl_reps(:,5)); 
lon = cell2mat(MVCO_chl_reps(:,6));
depth = cell2mat(MVCO_chl_reps(:,7));
chl = cell2mat(MVCO_chl_reps(:,8:14));
phaeo = cell2mat(MVCO_chl_reps(:,15:21));

replicate = repmat([1 2 3 1 2 1 2],length(MVCO_chl_reps),1); %numbers equivilant to a b c a b a b

quality = cell2mat(MVCO_chl_reps(:,22:28));
phaeo(find(isnan(phaeo))) = -9999;

datetemp = char(MVCO_chl_reps(:,3)); datetemp = datetemp(:,1:11);
datetemp2 = char(MVCO_chl_reps(:,4)); datetemp2 = datetemp2(:,12:19);
matdate = datenum([datetemp, datetemp2], 'yyyy-mm-dd HH:MM:SS');
clear datetemp*
matday = floor(matdate);
unqday = unique(matday);
clear datetemp unqday

caldate = NaN(length(lat), 7);
for count = 1:7,
    datetemp = char(MVCO_chl_reps(:,count+28)); ind = setdiff(1:length(lat), strmatch('null', datetemp));
    caldate(ind,count) = datenum(datetemp(ind,:), 'yyyy-mm-dd HH:MM:SS');
end;
clear datetemp ind count

tind = find(strncmp(event(:,1), 'MVCO',4));
event = event(tind,:);
event_num2 = strvcat(event(:,1));
fluorometer = strvcat(MVCO_chl_reps(:,end));
lat = cell2mat(MVCO_chl_reps(:,5)); 
lon = cell2mat(MVCO_chl_reps(:,6));
wind_speed = cell2mat(event(:,15));
cloud_percent = cell2mat(event(:,14));
water_depth = cell2mat(event(:,12));
wave_height = cell2mat(event(:,17));
secchi_depth = -9999;



% create a file for each water sample
unqevent = unique(MVCO_chl_reps(:,1));
for eventcount = 1:length(unqevent), %length(unqevent),
    ind = find(strcmp(MVCO_chl_reps(:,1), unqevent(eventcount)));  %chl matrix rows
    event_table_row = find(strcmp(event(:,1), unqevent(eventcount)));    %eventlog row
    cruise = ['MVCO_' datestr(matdate(ind(1)), 'mmddyy')];
    
    bassfile = ['chl_' datestr(matdate(ind(1)),'yyyymmdd_HHMM') '.sb'];
    disp(bassfile)
    % Write results to SEABASS file
    fid=fopen([datadir,'\seabass\',bassfile],'W');
    fprintf(fid,'/begin_header\n');
    fprintf(fid,'/data_file_name=%-s\n',bassfile);
    fprintf(fid,'/affiliations=WHOI\n');
    fprintf(fid,'/investigators=%-s\n',investigators);
    fprintf(fid,'/experiment=%-s\n',experiment);
    fprintf(fid,'/cruise=%-s\n',cruise);
    fprintf(fid,'/station=%-s\n',station);
    fprintf(fid,'/contact=%-s\n',contact);
%    fprintf(fid,'/data_type=pigment\n');
%    fprintf(fid,'/data_status=final\n');
    fprintf(fid,'/data_type=%-s\n', data_type);
    fprintf(fid,'/data_status=%-s\n',data_status);
    fprintf(fid,'/documents=see_notes_and_calibration_files\n');
    fprintf(fid,'/calibration_files=%-s\n',calibration_files);
    fprintf(fid,'/north_latitude=%-3.4f[DEG]\n',lat(ind(1)));
    fprintf(fid,'/south_latitude=%-3.4f[DEG]\n',lat(ind(1)));
    fprintf(fid,'/east_longitude=%-3.4f[DEG]\n',lon(ind(1)));
    fprintf(fid,'/west_longitude=%-3.4f[DEG]\n',lon(ind(1)));
    fprintf(fid,'/start_date=%-8s\n',datestr(matdate(ind(1)),'yyyymmdd'));
    fprintf(fid,'/end_date=%-8s\n',datestr(matdate(ind(1)),'yyyymmdd'));
    fprintf(fid,'/start_time=%-8s[GMT]\n',datestr(matdate(ind(1)),'HH:MM:SS'));
    fprintf(fid,'/end_time=%-8s[GMT]\n',datestr(matdate(ind(1)),'HH:MM:SS'));
    fprintf(fid,'/wind_speed=%-.0f\n',wind_speed(event_table_row));
    fprintf(fid,'/wave_height=%-.0f\n',wave_height(event_table_row));
    fprintf(fid,'/secchi_depth=%-.0f\n',secchi_depth);
    fprintf(fid,'/water_depth=%-.1f\n',water_depth(event_table_row));
    fprintf(fid,'/cloud_percent=%-.0f\n',cloud_percent(event_table_row));
    fprintf(fid,'!\n');
    fprintf(fid,'! Instrument: %-s\n',strtrim(fluorometer(ind(1),:)));
    fprintf(fid,'!\n');
    fprintf(fid,'! Number field represents replicate number\n');
    fprintf(fid,'!\n');
    fprintf(fid,'! Calibration date: %-s\n',datestr(caldate(ind(1))));
    fprintf(fid,'! Analyst-specific quality control 1 = no suspicion; 2 = some question, high replicate variability; 3 = very suspicious\n');
    for comrep=1:size(commentstr,1)
        fprintf(fid,'! %-s\n',commentstr(comrep,:));
    end
    fprintf(fid,'!\n');
    fprintf(fid,'/missing=-9999\n');
    fprintf(fid,'/delimiter=space\n');
    fprintf(fid,'/fields=depth,number,CHL,phaeo,Tpg,quality\n');
    fprintf(fid,'/units=m,none,mg/m^3,mg/m^3,mg/m^3,none\n'); %TC 11/20/12 added ^ to units from new seabass field requirement
    fprintf(fid,'/end_header\n');
    total_pig = chl+phaeo;
    temp = find(phaeo == -9999);
    total_pig(temp) = chl(temp);
    for count = 1:length(ind),
        for col = 1:3,
            if ~isnan(chl(ind(count),col)),
                fprintf(fid,'%-3.1f %0.0f %-2.2f %-2.2f % -2.2f %0.0f\n',depth(ind(count)),replicate(ind(count),col),chl(ind(count),col),phaeo(ind(count),col),total_pig(ind(count),col), quality(ind(count),col));
            end;
        end;        
    end
    fclose(fid);
end;

