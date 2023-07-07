%CHNs
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


%according to JOGFs protocol POC and PN is calculated by
%uM=(S-B)*1000/(V*roh) with S=sample value, B=blank, V=vol filt,roh=density of SW = 1.027


%Creates the variable 'MVCO_CHN_reps' as a cell array 

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
% database. Check connection by going to Control Panel > Administrative **** not really true anymore on 64bit comp. see below
% Tools > Data Sources (ODBC)
%
%
%
conn = database('SOSIK_Database','','password');

% Read data from database.  
% Make the SQL statement easily with querybuilder and paste in here - or select all fields with *
%SQL_query = 'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,"Chl_a_Chl (ug/l)","Chl_b_Chl (ug/l)","Chl_c_Chl (ug/l)" from MVCO_Chl_reps';
SQL_query = 'SELECT ALL * from MVCO_CHN';  %get all field from the table MVCO_CHN
e =exec(conn, SQL_query);
%e = exec(conn,'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,Filter_Size,"Chl (ug/l)","Phaeo (ug/l)",quality_flag,Cal_Date FROM MVCO_Chl_reps');

e = fetch(e);
%Create a variable 'MVCO_CHN_reps' which equals the data contained in
%the variable 'e'
MVCO_CHN_reps=e.Data;

%make header
attributes = attr(e);
header_chn = cellstr(strvcat(attributes.fieldName));

close(e)

% Read CHN blanks data from database.  
% % % % % SQL_query = 'SELECT ALL * from CHN_blanks';  %get all field from the table MVCO_CHN
% % % % % e =exec(conn, SQL_query);
% % % % % e = fetch(e);
% % % % % 
% % % % % %make blank varialbe
% % % % % blanks = e.Data;
% % % % % %make blank header
% % % % % attributes = attr(e);
% % % % % header_blanks = cellstr(strvcat(attributes.fieldName));
% % % % % 
% % % % % close(e)
% % % % % 
% Close database connection.
close(conn)
    
clear e conn s exec_str tempstr attributes SQL_*

%do a lot of indexing via header, much easier as categorical
header_chn = categorical(header_chn);
%need vol filt for later calculations. was complicated to isolate in access
%so when MVCO_CHN query is imported it has bad values in sample number and
%amoutn filtered column. Fix this with lines below and get rid of CHN_b and
%vol_filt_b column and rename header columns to remove a. 
dup_ind = find(categorical(MVCO_CHN_reps(:,header_chn == 'Replicate')) == 'b');
repa_ind = find(categorical(MVCO_CHN_reps(:,header_chn == 'Replicate')) == 'a');

if ~isempty(find(cell2mat(MVCO_CHN_reps(dup_ind,header_chn == 'CHN_b')) ~= cell2mat(MVCO_CHN_reps(dup_ind,header_chn == 'CHN_sample_ID'))))
    error('REP B PROBLEM!!! Inconsistent CHN_sample_ID column #s vs CHN_b. NEED TO INVESTIGATE. Could be CHNproc or Sosikdatabase.');
end
if ~isempty(find(cell2mat(MVCO_CHN_reps(repa_ind,header_chn == 'CHN_a')) ~= cell2mat(MVCO_CHN_reps(repa_ind,header_chn == 'CHN_sample_ID'))))
    error('REP A PROBLEM!!! Inconsistent CHN_sample_ID column #s vs CHN_a. NEED TO INVESTIGATE. Could be CHNproc or Sosikdatabase.');
end
clear repa_ind

MVCO_CHN_reps(dup_ind,header_chn == 'CHN_a') = MVCO_CHN_reps(dup_ind,header_chn == 'CHN_b');
MVCO_CHN_reps(dup_ind,header_chn == 'CHN_amt_filt_a') = MVCO_CHN_reps(dup_ind,header_chn == 'CHN_amt_filt_b');
MVCO_CHN_reps = MVCO_CHN_reps(:,header_chn ~= 'CHN_b');
header_chn = header_chn(header_chn ~= 'CHN_b');
MVCO_CHN_reps = MVCO_CHN_reps(:,header_chn ~= 'CHN_amt_filt_b');
header_chn = header_chn(header_chn ~= 'CHN_amt_filt_b');
header_chn(header_chn == 'CHN_amt_filt_a') = {'CHN_amt_filt'};
header_chn(header_chn == 'CHN_a') = {'CHN_sample_ID'};


%time without weird parts of imported date/time variables
matdate         = cell2mat(MVCO_CHN_reps(:,3)); 
mattime         = cell2mat(MVCO_CHN_reps(:,4));
matdate         = datenum([matdate(:,1:10) mattime(:,11:end-2)]); %sample date & time
clear mattime
%temp = datenum(

%wasn't listed in sequential time when pulled in from Access. Sort because often assumed.
[Y,I]=sort(matdate);
matdate = matdate(I);
MVCO_CHN_reps = MVCO_CHN_reps(I,:);

%Create header file with metadata
%creates a 1x35 struct with the metadata information

%Save workspace variables as a .mat file
% save('CHN_data_reps.mat','MVCO_CHN_reps','blanks','header_chn','header_blanks','matdate','blanks_orginaldata','header_blanks_originaldata');
save('CHN_data_reps.mat','MVCO_CHN_reps','header_chn','matdate');
save('\\sosiknas1\Lab_data\MVCO\mvcodata\matlab_files\CHN_data_reps.mat','MVCO_CHN_reps','header_chn','matdate');


% %event = strvcat(MVCO_chl_reps(:,2));
% %lat = cell2mat(MVCO_CHN_reps(:,5)); 
% %lon = cell2mat(MVCO_CHN_reps(:,6));
% depth = cell2mat(MVCO_CHN_reps(:,7));
% nitrogen = cell2mat(MVCO_CHN_reps(:,12));
% carbon = cell2mat(MVCO_CHN_reps(:,13));
% clear datetemp ind count
% 
% %sum date run and date combusted to get a unique number for each blank
% %association and then easy to matchup. leave out for now. can let heidi decide what to do
% blank_sum_combust_run=blanks(:,1)+blanks(:,2);
% unq_blanks = unique(blank_sum_combust_run);
% date_comb=datenum(num2str(cell2mat(MVCO_CHN_reps(:,10))),'yyyymmdd');
% date_run=datenum(num2str(cell2mat(MVCO_CHN_reps(:,11))),'yyyymmdd');
% sample_sum_combust_run = date_comb+date_run;
% blank_c = NaN(length(MVCO_CHN_reps),1);
% blank_n = blank_c;
% % MVCO_CHN_reps(:,17:18)={NaN};
% for count = 1:length(unq_blanks)
%     ind = find(sample_sum_combust_run == unq_blanks(count)); %set separately for ease of keeping in cell format
%     blank_n(ind) = nanmean(blanks(blank_sum_combust_run==unq_blanks(count),3));
%     blank_c(ind) = nanmean(blanks(blank_sum_combust_run==unq_blanks(count),4));
% %     MVCO_CHN_reps(ind,17) = {nanmean(blanks(blank_sum_combust_run==unq_blanks(count),3))};
% %     MVCO_CHN_reps(ind,18) = {nanmean(blanks(blank_sum_combust_run==unq_blanks(count),4))};
% end
% clear ind
% header_chn(17)={'blank_N(umol)'};
% header_chn(18)={'blank_C(umol)'};
% 

%{
 %this is not needed because did above and put at end of matrix MVCO_CHN_reps
%preallocate matrix for blank values matched up to sample values
blank_n = NaN(length(matdate),1);
blank_c = blank_n;
sample_comb_run_dates = [datenum(num2str(cell2mat(MVCO_CHN_reps(:,9))),'yyyymmdd') datenum(num2str(cell2mat(MVCO_CHN_reps(:,10))),'yyyymmdd')];
%matchup blanks and samples
unq_blanks_combust = unique(blanks(:,1));
for count = 1:length(unq_blanks_combust)
    ind = find(blanks(:,1) == unq_blanks_combust(count));
%each unique blank ex)B1 could have multiple run dates if we run in the
%middle of a combusted batch. need to make sure the diff runs get matched
%up with the appropriate run samples
    unq_blanks_run = unique(blanks(ind,2));
    for count2 = 1:length(unq_blanks_run)
        ind1 = find(blanks(:,1) == unq_blanks_combust(count) & blanks(:,2) == unq_blanks_run(count2));
        ind2 = find(sample_comb_run_dates(:,1) == unq_blanks_combust(count) & sample_comb_run_dates(:,2) == unq_blanks_run(count2));
        blank_n(ind2) = nanmean(blanks(ind1,3));
        blank_c(ind2) = nanmean(blanks(ind1,4));
    end
end
clear ind* count* 
%}
% clear blanks_sum* sum* unq*
% save MVCO_CHN_reps


%{
color = 'brgkmcbrgkmcbrgkmc';
figure
for count = 1:length(unq_day), 
    hold on
    ind=find(matdate==unq_day(count)); 
    [y,i] = sort(depth(ind));
    plot(carbon(ind(i)),depth(ind(i)),'.-','color',color(count)); 
%    plot(carbon(ind)-blank_c(ind),depth(ind),'o-','color',color(count)); 
end
title('Carbon in water column at MVCO')
ylabel('Depth'); xlabel('Carbon (umol)');
set(gca,'ydir','reverse')
legend(datestr(unq_day))

figure
for count = 1:length(unq_day), 
    hold on
    ind=find(matdate==unq_day(count)); 
    [y,i] = sort(depth(ind));
    plot(nitrogen(ind(i)),depth(ind(i)),'.-','color',color(count)); 
end
title('Nitrogen in water column at MVCO')
ylabel('Depth'); xlabel('Nitrogen (umol)');
set(gca,'ydir','reverse')
legend(datestr(unq_day))
%}
%if we start quality controlling will have to add a flag column
%{
for i=1:size(quality,2)
    badind = find(quality(:,i) == 3);
    chl(badind,i) = NaN;
end
clear badind
%}
