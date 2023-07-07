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

% Read data from database.  
% Make the SQL statement easily with querybuilder and paste in here - or select all fields with *
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SQL_query = 'SELECT ALL * from MVCO_sample_summary';  %get all field from the table MVCO_Chl_reps
%e = exec(conn,'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,Filter_Size,"Chl (ug/l)","Phaeo (ug/l)",quality_flag,Cal_Date FROM MVCO_Chl_reps');

%Jan 25,2013 TC changed query that's referenced, the above sample summary
%only had rows with all available data. this hplc_flcl version has rows for
%all events
SQL_query = 'SELECT ALL * from MVCO_sample_summary';  %get all field from the table MVCO_Chl_reps
e =exec(conn, SQL_query);
e = fetch(e);

%make header cell array with all the column names taken from Access. header
%is labeled more specifically than just header because loading multiple
%mat files overwrites headers that are all similarly named 'header'
attributes = attr(e);
header_summary = cellstr(strvcat(attributes.fieldName));

close(e)

% Close database connection.
close(conn)
    
%Create a variable 'MVCO_samples' which equals the data contained in
%the variable 'e'
MVCO_samples=e.Data;

clear e conn s exec_str tempstr attributes SQL_*

%some duplicates for when an HPLC was run twice. avg values
unq_bottle = unique(MVCO_samples(:,2));
%pre-allocate matrix to make new cell matrix that gets rid of extra rows.
%probably more efficient way to rid rows but good enough for now
tempMVCO = cell(length(unq_bottle),size(MVCO_samples,2)); 
for count = 1:length(unq_bottle)
    ind = strcmp(MVCO_samples(:,2),unq_bottle(count));
    if length(MVCO_samples(ind,2))==1 %if only the 1 bottle row leave as is
        tempMVCO(count,:) = MVCO_samples(ind,:);
    elseif length(MVCO_samples(ind,2))>1
        temp = MVCO_samples(ind,1:7); %if multiple for bottle, avg together
        tempMVCO(count,1:7) = temp(1,:);
        tempMVCO(count,8:end) = num2cell(nanmean(cell2mat(MVCO_samples(ind,8:end))));
    else %this seems impossible but just in case, throw error
        error(['no samples found for this bottle event: ' unq_bottle(count)])
    end
end
MVCO_samples = tempMVCO;
clear count temp* ind unq*

%get rid of junk part of date that's carried through during import
%just want date
datetemp=cell2mat(MVCO_samples(:,3));
datetemp=datetemp(:,1:10);
MVCO_samples(:,3)=cellstr(datetemp);
%just want time
timetemp=cell2mat(MVCO_samples(:,4));
timetemp=timetemp(:,12:end-2);
MVCO_samples(:,4)=cellstr(timetemp);

%data is not in sequential time order. fix it
matdate         = datenum([datetemp repmat(' ',length(timetemp),1) timetemp]);
[y,i]             = sort(matdate);
matdate         = y;
temp            = datevec(matdate);
yearday         = matdate-datenum(temp(:,1),0,0);
MVCO_samples  = MVCO_samples(i,:);
clear y i mattime datetemp timetemp temp


lat = cell2mat(MVCO_samples(:,5)); 
lon = cell2mat(MVCO_samples(:,6));
%Tchl_HPLC = [cell2mat(HPLC(:,37)) cell2mat(HPLC(:,89))];
load setlatlon

station4sum = NaN(length(MVCO_samples),1);
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
clear i lat lon count
% depth = cell2mat(MVCO_samples(:,7));
% chl=cell2mat(MVCO_samples(:,8:12));
% phaeo=cell2mat(MVCO_samples(:,13:15));
% %nut=cell2mat(MVCO_samples(:,16:27)); %no nutrients in this new summary version, only pigments for sat data work
% hplca=cell2mat(MVCO_samples(:,16:31));
% hplcb=cell2mat(MVCO_samples(:,32:47));
% hplc = NaN(size(hplca));
% for count = 1:length(hplc)
%     hplc(count,:) = nanmean([hplca(count,:); hplcb(count,:)]);
% end
% header_hplc = header_summary(16:31);
% clear count hplca hplca
% 
% %changed matday because want time of day. want sample matched within 4 hours
% %datetemp = char(MVCO_samples(:,3));
% %matday = floor(datenum(datetemp(:,1:10), 'yyyy-mm-dd'));
% %clear datetemp
% % temp = datevec(matday);
% % yearday = matday-datenum(temp(:,1),0,0);
% % clear temp
% title_station = {'S1' 'S2' 'S3' 'S4' 'S5' 'S6' 'S7' 'S8'};
%Save workspace variables as a .mat file
%save('MVCO_sample_summary.mat','MVCO_samples','header_summary','station4sum','chl','phaeo','nut','hplca','hplcb','depth','matdate','yearday','title_station');
%no longer saving nut
% save('MVCO_sample_summary_Jan2013.mat','MVCO_samples','header_summary','station4sum','chl','phaeo','hplc','depth','matdate','yearday','title_station','header_hplc');
save MVCO_sample_summary