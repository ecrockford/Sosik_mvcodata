%A summary of chlorophyll, nutrient, and HPLC data all contained within one
%large matrix which makes it easerier to do things like plot the data and
%not do so much work matching 
%Creates the variable 'MVCO_samples' as a cell array 

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

clear all, close all
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
%SQL_query = 'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,"Chl_a_Chl (ug/l)","Chl_b_Chl (ug/l)","Chl_c_Chl (ug/l)" from MVCO_Chl_reps';

% Read data from database.  
% Make the SQL statement easily with querybuilder and paste in here - or select all fields with *
%%%%%%%%%%%EVENTS%%%%%%%%%%%%%%%%%
%get all field from the table Event_meta
%getting separate bottle/event table instead of just summary table because
%was skipping events that didn't have data. couldn't figure out access
SQL_query       = 'SELECT ALL * from Event_meta';  
e               =exec(conn, SQL_query);
e               = fetch(e);
events          = e.Data;
attributes      = attr(e);
header_events   = cellstr(strvcat(attributes.fieldName));
close(e)

%%%%%%%%%%%CHLOROPHYLL%%%%%%%%%%%%%%%%%
SQL_query       = 'SELECT ALL * from MVCO_Chl_reps';  %get all field from the table MVCO_Chl_reps
e               = exec(conn, SQL_query);
e               = fetch(e);
attributes      = attr(e);
header_chl      = cellstr(strvcat(attributes.fieldName));
MVCO_chl_reps   = e.Data; %Create a variable 'MVCO_chl_reps' which equals the data contained in
close(e)

%%%%%%%%%%%NUTRIENTS%%%%%%%%%%%%%%%%%
SQL_query       = 'SELECT ALL * from MVCO_Nut_reps';  %get all field from the table MVCO_Nut_reps
e               = exec(conn, SQL_query);
e               = fetch(e);
MVCO_nut_reps   = e.Data; %make variable MVCO_nut_reps which equals data contained in
attributes      = attr(e);
header_nut      = cellstr(strvcat(attributes.fieldName));
close(e)

%%%%%%%%%%%HPLC%%%%%%%%%%%%%%%%%
SQL_query       = 'SELECT ALL * from HPLC_reps';  %get all field from the table HPLC_reps
e               = exec(conn, SQL_query);
e               = fetch(e);
HPLC            = e.Data;
attributes      = attr(e);
header_hplc     = cellstr(strvcat(attributes.fieldName)); %Create header file with metadata
close(e)

% Close database connection.
close(conn)

clear e conn s exec_str tempstr attributes SQL_*

%get rid of junk part of date that's carried through during import
%just want date
ind_date = find(strcmp(header_events,'Start_Date'));
datetemp=cell2mat(events(:,ind_date));
datetemp=datetemp(:,1:10);
events(:,ind_date)=cellstr(datetemp);
%get rid of junk part of time
ind_time = find(strcmp(header_events,'Start_Time_UTC'));
timetemp=cell2mat(events(:,ind_time));
timetemp=timetemp(:,12:end-2);
events(:,ind_time)=cellstr(timetemp);
clear ind* *temp
%don't need to sort by date because bottle table already sorted sequentionally
%{
matdate         = datenum([datetemp repmat(' ',length(timetemp),1) timetemp]);
[y,i]             = sort(matdate);
matdate         = y;
temp            = datevec(matdate);
yearday         = matdate-datenum(temp(:,1),0,0);
MVCO_samples  = MVCO_samples(i,:);
clear y i mattime datetemp timetemp temp
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%confirm no repeats of bottle events in list of events before syncing up
%data types into single matrix
ind_bottle = find(strcmp(header_events,'Event_Number_Niskin'));
unq_events = unique(events(:,ind_bottle));
if length(unq_events) ~= length(events)
    disp('Bottle event repeated more than once. Check to find which eventt.');
    pause;
end
clear ind* unq*


%as precaution if matrix change column order search in header for names
%problem with this search, assumes replicates are grouped by sample type
temp        = find(strcmp(header_chl,'Chl_a_Chl (ug/l)'));
ind_chl     = temp:temp+2;
temp        = find(strcmp(header_chl,'Chl_a_Phaeo (ug/l)'));
ind_phaeo   = temp:temp+2;
temp        = find(strcmp(header_chl,'Chl_a_quality_flag'));
ind_chlflag = temp:temp+2;
temp        = find(strcmp(header_chl,'Chl_10a_Chl (ug/l)'));
ind_chl10   = temp:temp+1;
temp        = find(strcmp(header_chl,'Chl_10a_Phaeo (ug/l)'));
ind_phaeo10 = temp:temp+1;
temp        = find(strcmp(header_chl,'Chl_10a_quality_flag'));
ind_flag10  = temp:temp+1;

temp = regexp(header_nut,'\w*NO3-'); %find all folders with this naming scheme
ind_NO2NO3 = find(cellfun('isempty',temp)==0);
temp = regexp(header_nut,'\w*NH4+'); %find all folders with this naming scheme
ind_NH4 = find(cellfun('isempty',temp)==0);
temp = regexp(header_nut,'\w*SiO2-'); %find all folders with this naming scheme
ind_SiO2 = find(cellfun('isempty',temp)==0);
temp = regexp(header_nut,'\w*PO43-'); %find all folders with this naming scheme
ind_PO4 = find(cellfun('isempty',temp)==0);

temp = regexp(header_hplc,'HPLC_a.\w*'); %find all folders with this naming scheme
ind_hplca = find(cellfun('isempty',temp)==0);
temp = regexp(header_hplc,'HPLC_b.\w*'); %find all folders with this naming scheme
ind_hplcb = find(cellfun('isempty',temp)==0);
clear temp

%replace -9999, -8888, -111
%HPLC rep A
temp = cell2mat(HPLC(:,ind_hplca));
temp(temp == -9999) = NaN; %replace -9999 does not exist, with NaN
temp(temp == -8888) = 0; %replace not detected with zero
temp(temp == -111) = 0; %replace below detection limit with zero
HPLC(:,ind_hplca) = num2cell(temp); %put back as cells in normal matrix 
%HPLC rep B
temp = cell2mat(HPLC(:,ind_hplcb));
temp(temp == -9999) = NaN; %replace -9999 does not exist, with NaN
temp(temp == -8888) = 0; %replace not detected with zero
temp(temp == -111) = 0; %replace below detection limit with zero
HPLC(:,ind_hplcb) = num2cell(temp); %put back as cells in normal matrix 
clear temp

header_summary = [header_events(:); header_chl(ind_chl); header_chl(ind_phaeo); header_chl(ind_chlflag); header_chl(ind_chl10);...
    header_chl(ind_phaeo10); header_chl(ind_flag10); header_nut(ind_NO2NO3); header_nut(ind_NH4); header_nut(ind_SiO2);...
    header_nut(ind_PO4); header_hplc(ind_hplca); header_hplc(ind_hplcb)];
temp_avg = {'Chl (ug/l)'; 'Phaeo (ug/l)'; 'Chl quality_flag'; '<10 Chl (ug/l)'; '<10 Phaeo (ug/l)'; '<10Chl quality flag';...
        'NO2- + NO3- (uM)'; 'NH4 (uM)'; 'SiO2- (uM)'; 'PO43- (uM)'};
temphplc = char(header_hplc(ind_hplca));
temphplc = [temphplc(:,1:4) temphplc(:,7:end)];
header_avg = [header_events(:);  temp_avg; cellstr(temphplc)];
clear temp_avg temphplc

%loop through each bottle event and find corresponding data for chl, nut,
%hplc. if data do not exist leave as nan
%pre-allocate matrix to make new cell matrix that gets rid of extra rows.
%probably more efficient way to rid rows but good enough for now
MVCO_sample_summary = cell(length(events),length(header_summary)); 
MVCO_sample_summary(:,1:size(events,2)) = events; %fill event data in don't need to do in loop for each row
%length of avg matrix = event(7) + chl(6) + nut(4) + hplc(51)
MVCO_sample_avg = cell(length(events),length(header_avg)); 
MVCO_sample_avg(:,1:size(events,2)) = events; %fill event data in don't need to do in loop for each row

ind_bottle = find(strcmp(header_events,'Event_Number_Niskin'));
for count = 1:length(events)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CHLOROPHYLL%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    ind_bottle_chl = strcmp(MVCO_chl_reps(:,2),events(count,ind_bottle));
    if length(MVCO_chl_reps(ind_bottle_chl,1))==1 %if only the 1 bottle row leave as is
        MVCO_sample_summary(count,8:22) = [MVCO_chl_reps(ind_bottle_chl,ind_chl) MVCO_chl_reps(ind_bottle_chl,ind_phaeo)...
            MVCO_chl_reps(ind_bottle_chl,ind_chlflag) MVCO_chl_reps(ind_bottle_chl,ind_chl10) MVCO_chl_reps(ind_bottle_chl,ind_phaeo10)...
            MVCO_chl_reps(ind_bottle_chl,ind_flag10)];
        MVCO_sample_avg(count,8:13) = [{nanmean(cell2mat(MVCO_chl_reps(ind_bottle_chl,ind_chl)))}...
            {nanmean(cell2mat(MVCO_chl_reps(ind_bottle_chl,ind_phaeo)))} {nanmean(cell2mat(MVCO_chl_reps(ind_bottle_chl,ind_chlflag)))}...
            {nanmean(cell2mat(MVCO_chl_reps(ind_bottle_chl,ind_chl10)))} {nanmean(cell2mat(MVCO_chl_reps(ind_bottle_chl,ind_phaeo10)))}...
            {nanmean(cell2mat(MVCO_chl_reps(ind_bottle_chl,ind_flag10)))}];
    elseif isempty(MVCO_chl_reps(ind_bottle_chl,1)) %no chl sapmle taken for this bottle
        MVCO_sample_summary(count,8:22) = repmat(num2cell(NaN),1,length(8:22));
        MVCO_sample_avg(count,8:13) = repmat(num2cell(NaN),1,length(8:13));
    elseif length(MVCO_chl_reps(ind_bottle_chl,1))>1 %I DON'T THINK THIS SHOULD HAPPEN??NEED TO AVERAGE DUPLIC ROWS??
        if strcmp(MVCO_chl_reps(ind_bottle_chl,ind_bottle),'MVCO_015_01') | strcmp(MVCO_chl_reps(ind_bottle_chl,ind_bottle),'MVCO_016_01')
            temp = [MVCO_chl_reps(ind_bottle_chl,ind_chl) MVCO_chl_reps(ind_bottle_chl,ind_phaeo)...
                MVCO_chl_reps(ind_bottle_chl,ind_chlflag) MVCO_chl_reps(ind_bottle_chl,ind_chl10) MVCO_chl_reps(ind_bottle_chl,ind_phaeo10)...
                MVCO_chl_reps(ind_bottle_chl,ind_flag10)];
            MVCO_sample_summary(count,8:22) = temp(1,:);
            MVCO_sample_avg(count,8:13) = [{nanmean(cell2mat(temp(1,1:3)))}...
                {nanmean(cell2mat(temp(1,4:6)))} {nanmean(cell2mat(temp(1,7:9)))}...
                {nanmean(cell2mat(temp(1,10:11)))} {nanmean(cell2mat(temp(1,12:13)))}...
                {nanmean(cell2mat(temp(1,14:15)))}];
        else
        error(['More than 1 row in chl table for this bottle event: ' cell2mat(events(count,ind_bottle))])
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NUTRIENT%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    ind_bottle_nut = strcmp(MVCO_nut_reps(:,2),events(count,ind_bottle));
    if length(MVCO_nut_reps(ind_bottle_nut,1))==1 %if only the 1 bottle row leave as is
        MVCO_sample_summary(count,23:34) = [MVCO_nut_reps(ind_bottle_nut,ind_NO2NO3) MVCO_nut_reps(ind_bottle_nut,ind_NH4)...
            MVCO_nut_reps(ind_bottle_nut,ind_SiO2) MVCO_nut_reps(ind_bottle_nut,ind_PO4)];
        MVCO_sample_avg(count,14:17) = [{nanmean(cell2mat(MVCO_nut_reps(ind_bottle_nut,ind_NO2NO3)))}...
            {nanmean(cell2mat(MVCO_nut_reps(ind_bottle_nut,ind_NH4)))} {nanmean(cell2mat(MVCO_nut_reps(ind_bottle_nut,ind_SiO2)))}...
            {nanmean(cell2mat(MVCO_nut_reps(ind_bottle_nut,ind_PO4)))}];
    elseif isempty(MVCO_nut_reps(ind_bottle_nut,1)) %no nut sample taken for this bottle
        MVCO_sample_summary(count,23:34) = repmat(num2cell(NaN),1,length(23:34));
        MVCO_sample_avg(count,14:17) = repmat(num2cell(NaN),1,length(14:17));
    elseif length(MVCO_nut_reps(ind_bottle_nut,1))>1 %I DON'T THINK THIS SHOULD HAPPEN??NEED TO AVERAGE DUPLIC ROWS??
        error(['More than 1 row in nut table for this bottle event: ' cell2mat(events(count,ind_bottle))])
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%HPLC%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    ind_bottle_hplc = strcmp(HPLC(:,2),events(count,ind_bottle));
    if length(HPLC(ind_bottle_hplc,1))==1 %if only the 1 bottle row leave as is
        MVCO_sample_summary(count,35:end) = [HPLC(ind_bottle_hplc,ind_hplca) HPLC(ind_bottle_hplc,ind_hplcb)];
        MVCO_sample_avg(count,18:end) = num2cell(nanmean(cell2mat([HPLC(ind_bottle_hplc,ind_hplca); HPLC(ind_bottle_hplc,ind_hplcb)])));
    elseif isempty(HPLC(ind_bottle_hplc,1)) %no nut sample taken for this bottle
        MVCO_sample_summary(count,35:end) = repmat(num2cell(NaN),1,length(35:size(MVCO_sample_summary,2)));
        MVCO_sample_avg(count,18:end) = repmat(num2cell(NaN),1,length(18:size(MVCO_sample_avg,2)));
    elseif length(HPLC(ind_bottle_hplc,1))>1 %I DON'T THINK THIS SHOULD HAPPEN??NEED TO AVERAGE DUPLIC ROWS??
        if length(unique(HPLC(ind_bottle_hplc,8)))<length(HPLC(ind_bottle_hplc,1)) | length(unique(HPLC(ind_bottle_hplc,60)))<length(HPLC(ind_bottle_hplc,1)) %index 8 is HS# for rep a, index 60 is HS# rep b
            MVCO_sample_summary(count,35:end) = num2cell([nanmean(cell2mat(HPLC(ind_bottle_hplc,ind_hplca))) nanmean(cell2mat(HPLC(ind_bottle_hplc,ind_hplcb)))]);
            MVCO_sample_avg(count,18:end) = num2cell(nanmean(cell2mat([HPLC(ind_bottle_hplc,ind_hplca); HPLC(ind_bottle_hplc,ind_hplcb)])));
        else
        error(['More than 1 row in HPLC table for this bottle event: ' cell2mat(events(count,ind_bottle))])
        end
    end
    if rem(count,50) == 0,
        disp([num2str(count) ' of ' num2str(length(events))]) 
    end;
end
clear count temp* ind unq*


lat = cell2mat(MVCO_sample_avg(:,5)); 
lon = cell2mat(MVCO_sample_avg(:,6));
%Tchl_HPLC = [cell2mat(HPLC(:,37)) cell2mat(HPLC(:,89))];
load setlatlon
README = 'Stations labeled 1-8. Station 4 = ASIT. Station 5 = 12m node.';
station4sum = NaN(length(MVCO_sample_avg),1);
for i=1:length(station4sum)
    if lat(i) > setcoord(1,2) && lat(i) < setcoord(1,3) && lon(i) < setcoord(1,4) && lon(i) > setcoord(1,5)
        station4sum(i) = 1;
    elseif lat(i) > setcoord(2,2) && lat(i) < setcoord(2,3) && lon(i) < setcoord(2,4) && lon(i) > setcoord(2,5)
        station4sum(i) = 2;
     elseif lat(i) > setcoord(3,2) && lat(i) < setcoord(3,3) && lon(i) < setcoord(3,4) && lon(i) > setcoord(3,5)
         station4sum(i) = 3;
     elseif lat(i) > setcoord(4,2) && lat(i) < setcoord(4,3) && lon(i) < setcoord(4,4) && lon(i) > setcoord(4,5)
         station4sum(i) = 4;
     elseif lat(i) > setcoord(5,2) && lat(i) < setcoord(5,3) && lon(i) < setcoord(5,4) && lon(i) > setcoord(5,5)
         station4sum(i) = 5;
     elseif lat(i) > setcoord(6,2) && lat(i) < setcoord(6,3) && lon(i) < setcoord(6,4) && lon(i) > setcoord(6,5)
         station4sum(i) = 6;
     elseif lat(i) > setcoord(7,2) && lat(i) < setcoord(7,3) && lon(i) < setcoord(7,4) && lon(i) > setcoord(7,5)
         station4sum(i) = 7;
    elseif lat(i) > setcoord(8,2) && lat(i) < setcoord(8,3) && lon(i) < setcoord(8,4) && lon(i) > setcoord(8,5)
         station4sum(i) = 8;
    else
        error('Sample out of lat/lon station ranges or missing!')
    end
end

clear i lat lon count ind* HPLC *reps events header_nut header_chl header_hplc header_events set*
save MVCO_sample_summary

