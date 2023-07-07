%last edited 17Sept2013 updated documents & cal file headers after working
%with Chris Proctor (christopher.w.proctor@nasa.gov) from NASA
%
%last run 9/17/2013 submitted through end of 2012
%set some default strings
commentstr='For submission to seabass.';
datadir = 'C:\data\mvcodata\spectra\';
investigators = 'Heidi_Sosik';
contact = 'hsosik@whoi.edu';
data_type = 'scan';
data_status = 'preliminary';
%doc & cal hardwired into script below ~line 228
%documents = 'see_notes_and_calibration_files';
%calibration_files = 'MVCO_spec_protocol.doc';
experiment = 'MVCO';
station = 'NA';
apfiltarea=pi*1.05^2;
cdomblnk=0;  %0 = don't subtract cdom blank
chlinc = 0;
%Spectra file names all contained in bottle table in access


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
SQL_query = 'SELECT ALL * from Event';
e =exec(conn, SQL_query);
%e = exec(conn,'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,Filter_Size,"Chl (ug/l)","Phaeo (ug/l)",quality_flag,Cal_Date FROM MVCO_Chl_reps');

e = fetch(e);

attributes = attr(e);
header_event = cellstr(strvcat(attributes.fieldName));

close(e);
%Create a variable 'event' which equals the data contained in
%the variable 'e'
event=e.data;

clear e

SQL_query = 'SELECT ALL Event_Number,Event_Number_Niskin,Date,Depth,ap_a,Ap_a_filename,Ad_a_filename,ap_b,Ap_b_filename,Ad_b_filename,Acdom_a_filename,acdom_a,acdom_b,Acdom_b_filename FROM Bottle';  %get all field from the table MVCO_Chl_reps
e =exec(conn, SQL_query);
%e = exec(conn,'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,Filter_Size,"Chl (ug/l)","Phaeo (ug/l)",quality_flag,Cal_Date FROM MVCO_Chl_reps');

e = fetch(e);

attributes = attr(e);
header_bottle = cellstr(strvcat(attributes.fieldName));

close(e);
% Close database connection.
close(conn);


bottle = e.data;
clear e conn s

%replace 'null' with 'NaN'
bottle(find(strcmp(bottle,'null'))) = {'NaN'};
ind = find(strcmp(header_bottle, 'Event_Number'));
event_num = bottle(:,ind);
ind = find(strcmp(header_bottle, 'Ap_a_filename'));
ap_file_a = bottle(:,ind);
ind = find(strcmp(header_bottle, 'Ap_b_filename'));
ap_file_b = bottle(:,ind);
ind = find(strcmp(header_bottle, 'Acdom_a_filename'));
acdom_file_a = bottle(:,ind);
ind = find(strcmp(header_bottle, 'Acdom_b_filename'));
acdom_file_b = bottle(:,ind);

%find where spec files exist - file names as opposed to -9999, don't need
%to check if Ad exists because Ad always paired with Ap
spec_check = sum(strcmp([ap_file_a ap_file_b acdom_file_a acdom_file_b], '-9999'),2);
%just MVCO events with ANY spec data from bottle table
tind = find(strncmp(event_num, 'MVCO',4) & spec_check < 4);
event_num = event_num(tind,:);
bottle = bottle(tind,:);
ind = find(strcmp(header_bottle, 'Event_Number_Niskin'));
event_num_niskin = bottle(:,ind);
ind = find(strcmp(header_bottle, 'ap_a'));
ap_vol_a = cell2mat(bottle(:,ind));
ind = find(strcmp(header_bottle, 'ap_b'));
ap_vol_b = cell2mat(bottle(:,ind));
ind = find(strcmp(header_bottle, 'Ap_a_filename'));
ap_file_a = bottle(:,ind);
ind = find(strcmp(header_bottle, 'Ap_b_filename'));
ap_file_b = bottle(:,ind);
ind = find(strcmp(header_bottle, 'Ad_a_filename'));
ad_file_a = bottle(:,ind);
ind = find(strcmp(header_bottle, 'Ad_b_filename'));
ad_file_b = bottle(:,ind);
ind = find(strcmp(header_bottle, 'Acdom_a_filename'));
acdom_file_a = bottle(:,ind);
ind = find(strcmp(header_bottle, 'Acdom_b_filename'));
acdom_file_b = bottle(:,ind);
ind = find(strcmp(header_bottle, 'Depth'));
measurement_depth = cell2mat(bottle(:,ind));

% get some info from the Event table
ind = find(strcmp(header_event, 'Event_Number'));
event_num2 = event(:,ind);
ind = find(strcmp(header_event, 'Latitude'));
lat = cell2mat(event(:,ind));
ind = find(strcmp(header_event, 'Longitude'));
lon = cell2mat(event(:,ind));
ind = find(strcmp(header_event, 'Water_Depth_m'));
water_depth = cell2mat(event(:,ind));
ind = find(strcmp(header_event, 'Start_Date'));
datetemp = char(event(:,ind)); datetemp = datetemp(:,1:11);
ind = find(strcmp(header_event, 'Start_Time_UTC'));
datetemp2 = char(event(:,ind)); datetemp2 = datetemp2(:,12:19);
matdate = datenum([datetemp, datetemp2], 'yyyy-mm-dd HH:MM:SS');
clear datetemp*
%matday = floor(matdate);
%unqday = unique(matday);
%clear datetemp unqday

%tind = find(strncmp(event(:,1), 'MVCO',4));
%MVCO_event = event(tind,:);

ind = find(strcmp(header_event, 'Wind_Speed_kts'));
wind_speed = cell2mat(event(:,ind)); %str2num(strvcat(event(:,ind)));
ind = find(strcmp(header_event, 'Cloud_Percent'));
cloud_percent = cell2mat(event(:,ind)); %str2num(strvcat(event(:,ind)));
ind = find(strcmp(header_event, 'Wave_Height_m'));
wave_height = cell2mat(event(:,ind)); %str2num(strvcat(event(:,ind)));
secchi_depth = -9999;

%find cases with ANY spec files, just check for ap and acdom
%spec_check = find(sum(strcmp([ap_file_a ap_file_b acdom_file_a acdom_file_b], '-9999'),2)<4);
acdomblankfilename = '-9999';


for count = 1:length(event_num_niskin), %length(event_num_niskin), % loop over every MVCO entry in the bottle table
    disp(event_num_niskin(count))
    event_table_row = find(strcmp(event_num2,event_num(count)));  %find the event # in the event table
    for rep = 1:2,
        if rep == 1,
            apfilename = [datadir char(ap_file_a(count)) '.sp']; apfilename_simple = char(ap_file_a(count));
            adfilename = [datadir char(ad_file_a(count)) '.sp']; adfilename_simple = char(ad_file_a(count));
            acdomfilename = [datadir char(acdom_file_a(count)) '.sp']; acdomfilename_simple = char(acdom_file_a(count));
            volfilt = ap_vol_a(count);
        else
            apfilename = [datadir char(ap_file_b(count)) '.sp']; apfilename_simple = char(ap_file_b(count));
            adfilename = [datadir char(ad_file_b(count)) '.sp']; adfilename_simple = char(ad_file_b(count));
            acdomfilename = [datadir char(acdom_file_b(count)) '.sp']; acdomfilename_simple = char(acdom_file_b(count));
            volfilt = ap_vol_b(count);
        end;
        %reset missing files to '-9999' only (no extension, no directory)
        if strcmp(apfilename(end-7:end), '-9999.sp'),
            apfilename = '-9999';
        end;
        if strcmp(adfilename(end-7:end), '-9999.sp'),
            adfilename = '-9999';
        end;
        if strcmp(acdomfilename(end-7:end), '-9999.sp'),
            acdomfilename = '-9999';
        end;

        if ~strcmp(apfilename,'-9999') | ~strcmp(acdomfilename,'-9999') | ~strcmp(adfilename,'-9999'),  %only make a seabass file if at least one file exists
            %set "datadir" up at top
            %process acdom if exists
            if ~strcmp(acdomfilename,'-9999'),
                [wvlncdom,acdom]=acdomspecproc(acdomfilename,acdomblankfilename,660,670);
                goodcdom=find(wvlncdom>=300 & wvlncdom<=850);
            end;
            %process ap/ap if one exists
            if (~strcmp(apfilename,'-9999') | ~strcmp(adfilename,'-9999'))
                [wvln,ap,aph,ad]=apspecproc(apfilename,adfilename,volfilt*1e-6,apfiltarea*1e-4,780,800);
                good=find(wvln>=300 & wvln<=850);  %wavelengths to output
            end;

            %write a seabass file

            %bassfile = naming scheme of files
            cruise = ['MVCO_' datestr(matdate(event_table_row), 'mmddyy')];

            bassfile = ['spec_' datestr(matdate(event_table_row),'yyyymmdd_HHMM') '_' num2str(rep) '_' repmat('0',1,3-size(num2str(round(measurement_depth(count))),2)) num2str(round(measurement_depth(count))) 'm.sb'];
            disp(bassfile)

            %put -9999 in vectors for cases with missing spectra
            %note: don't think this handles case with ad, but no ap...
            if exist('ap','var') & ~exist('acdom','var')
                acdom=repmat(-9999,length(ap),1);
                goodcdom=[1:length(good)]';
            elseif exist('acdom','var') & ~exist('ap','var')
                ap=repmat(-9999,length(acdom),1);
                ad=repmat(-9999,length(acdom),1);
                aph=repmat(-9999,length(acdom),1);
                good=goodcdom;
                wvln=wvlncdom;
            end

            fid=fopen([datadir,'seabass\',bassfile],'W');
            fprintf(fid,'/begin_header\n');
            fprintf(fid,'/data_file_name=%-20s\n',bassfile);
            fprintf(fid,'/affiliations=WHOI\n');
            fprintf(fid,'/investigators=%-20s\n',investigators);
            fprintf(fid,'/experiment=%-20s\n',experiment);
            fprintf(fid,'/cruise=%-20s\n',cruise);
            fprintf(fid,'/station=%-20s\n',station);
            fprintf(fid,'/contact=%-s\n',contact);
            fprintf(fid,'/data_type=scan\n');
            fprintf(fid,'/data_status=preliminary\n');
%we almost always put preliminary but it could be easier to submit spec
%files regardless of if they're done and then resubmit the whole chunk
%with data status update
%            fprintf(fid,'/data_status=update\n');  %'final' is also an option
            fprintf(fid,'/documents=see_notes_and_calibration_files\n');
            fprintf(fid,'/calibration_files=MVCO_spec_protocol.doc\n');
            fprintf(fid,'/north_latitude=%-3.4f[DEG]\n',lat(event_table_row));
            fprintf(fid,'/south_latitude=%-3.4f[DEG]\n',lat(event_table_row));
            fprintf(fid,'/east_longitude=%-3.4f[DEG]\n',lon(event_table_row));
            fprintf(fid,'/west_longitude=%-3.4f[DEG]\n',lon(event_table_row));
            fprintf(fid,'/start_date=%-8s\n',datestr(matdate(event_table_row),'yyyymmdd'));
            fprintf(fid,'/end_date=%-8s\n',datestr(matdate(event_table_row),'yyyymmdd'));
            fprintf(fid,'/start_time=%-8s[GMT]\n',datestr(matdate(event_table_row),'HH:MM:SS'));
            fprintf(fid,'/end_time=%-8s[GMT]\n',datestr(matdate(event_table_row),'HH:MM:SS'));
            fprintf(fid,'/wind_speed=%-5.0f\n',wind_speed(event_table_row));
            fprintf(fid,'/wave_height=%-5.0f\n',wave_height(event_table_row));
            fprintf(fid,'/secchi_depth=%-5.0f\n',secchi_depth);
            fprintf(fid,'/measurement_depth=%-5.0f\n',measurement_depth(count));
            fprintf(fid,'/water_depth=%-5.0f\n',water_depth(event_table_row));
            fprintf(fid,'/cloud_percent=%-5.0f\n',cloud_percent(event_table_row));
            fprintf(fid,'!\n');
            fprintf(fid,'! spectrophotometer: Perkin Elmer Lambda 18;\n');
            fprintf(fid,'! serial number: 75009\n');
            fprintf(fid,'! Data are from 850 to 300 nm.\n');
            fprintf(fid,'! All have a 1 nm step.\n');
            fprintf(fid,'! Beta pathlength amplification factor algorithm from\n');
            fprintf(fid,'! Mitchell, B.G., Ocean Optics X, p.137-148, 1990\n');
            fprintf(fid,'!\n');
            fprintf(fid,'! Raw File Names: %-s, %-s, %s\n',acdomfilename_simple,apfilename_simple,adfilename_simple);
            fprintf(fid,'!\n');
            if ~isnan(volfilt),
                fprintf(fid,'! Volume filtered: %-5.0f ml\n',volfilt)  %fix this later to get rid of ans = 28
            end;

            if ~strcmp(acdomblankfilename,'-9999.sp') & cdomblnk
                fprintf(fid,'! acdom blank file: %s\n',acdomblankfile);
            end
            for comrep=1:size(commentstr,1)
                fprintf(fid,'! %-s\n',commentstr(comrep,:));
            end
            fprintf(fid,'!\n');
            fprintf(fid,'/missing=-9999\n');
            fprintf(fid,'/delimiter=space\n');
            if ~chlinc
                fprintf(fid,'/fields=wavelength,ag,ap,ad,aph\n');
                fprintf(fid,'/units=nm,1/m,1/m,1/m,1/m\n');
            else
                fprintf(fid,'/fields=wavelength,ag,ap,ad,aph,a*ph\n');
                fprintf(fid,'/units=nm,1/m,1/m,1/m,1/m,m^2/mg\n');
            end
            fprintf(fid,'/end_header\n');
            if ~chlinc
                for rep3=1:length(good)
                    fprintf(fid,'%-3.0f %-5.6f %-5.6f %-5.6f %-5.6f\n',wvln(good(rep3)),acdom(goodcdom(rep3)),ap(good(rep3)),ad(good(rep3)),aph(good(rep3)));
                end
            else
                for rep3=1:length(good)
                    fprintf(fid,'%-3.0f %-5.6f %-5.6f %-5.6f %-5.6f %-5.6f\n',wvln(good(rep3)),acdom(goodcdom(rep3)),ap(good(rep3)),ad(good(rep3)),aph(good(rep3)),aphstar(good(rep3)));
                end
            end
            fclose(fid);
%            save S_acdom440_values.mat slope440 all_acdom440 all_acdom443 all_acdom490 all_acdom412 matedate
            clear ap aph ad acdom wvln wvlncdom good goodcdom

        end;  %    if apfilename ~= '-9999' | acdomfilename ~= '-9999',
    end;  %for count = 1:length(event_num_niskin), % loop over every MVCO entry in the bottle table
end;
