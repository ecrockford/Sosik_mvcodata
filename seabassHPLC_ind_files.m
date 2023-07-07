%TCrockford 6Feb2012 
%make a single text file to submit to seabass for all MVCO HPLC data run by
%horn point lab. update file each time new data is added to
%C:\data\mvcdodata\HPLCproc.xls. each time run, create new text file with
%current date. That way can keep track of state of file each time it's
%submitted to seabass.
%
%last updated 5/6/2014 - Taylor - updated datadir when switch from Samwise
%to Queenrose. Couldn't use shared folder name due to fopen/fprintf issues
%
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
%last updated 5/14/14 Taylor
%for loop using strcmp had and if statment that summed spot. sum was always
%1. changed to find and use length
datadir = 'C:\from_Samwise\data\mvcodata';
investigators = 'Heidi_Sosik';
contact = 'hsosik@whoi.edu';
data_type = 'pigment';
data_status = 'final';
calibration_files = 'no_calibration';
documents = 'see_notes';
experiment = 'MVCO';
station = 'NA';

% Set preferences with setdbprefs.
s.DataReturnFormat = 'cellarray';
s.ErrorHandling = 'store';
s.NullNumberRead = '-9999';
s.NullNumberWrite = '-9999';
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
%SQL_query = 'SELECT ALL Event_Number,Event_Number_Niskin,Date,Start_Time_UTC,Latitude,Longitude,Depth,HPLC_a,HPLC_a_amt_filt,HPLC_a.Vx_mL,HPLC_a.Total_Chl_a,HPLC_a.Total_Chl_b,HPLC_a.Total_Chl_c,HPLC_a.Carotene,HPLC_a.But_Fucoxanthin,HPLC_a.Hex_Fucoxanthin,HPLC_a.Alloxanthin,HPLC_a.Diadinoxanthin,HPLC_a.Diatoxanthin,HPLC_a.Fucoxanthin,HPLC_a.Peridinin,HPLC_a.Zeaxanthin,HPLC_a.Monovinyl_Chl_a,HPLC_a.Divinyl_Chl_a,HPLC_a.Chlorophyllide_a,HPLC_a.Monovinyl_Chl_b,HPLC_a.Divinyl_Chl_b,HPLC_a.Chlorophyll_c1,HPLC_a.Chlorophyll_c2,HPLC_a.Chlorophyll_c12,HPLC_a.Chlorophyll_c3,HPLC_a.Lutein,HPLC_a.Neoxanthin,HPLC_a.Violaxanthin,HPLC_a.Pheophytin,HPLC_a.Pheophorbide_a,HPLC_a.Prasinoxanthin,HPLC_a.Gyroxanthin_Diester,HPLC_a.TChl,HPLC_a.PPC,HPLC_a.PSC,HPLC_a.PSP,HPLC_a.TCaro,HPLC_a.TAcc,HPLC_a.Tpig,HPLC_a.DP,HPLC_a.TAcc/Tchla,HPLC_a.PSC/TCaro,HPLC_a.PPC/Tcaro,HPLC_a.TChl/TCaro,HPLC_a.PPC/Tpig,HPLC_a.PSP/TPig,HPLC_a.TChla/TPig,HPLC_a.microplankton,HPLC_a.nanoplankton,HPLC_a.picoplankton,HPLC_a.FL_Chl_a,HPLC_a.FL_Pheo,HPLC_a.Chl_a_Allomer,HPLC_a.Chl_a_Epimer,HPLC_b,HPLC_b_amt_filt,HPLC_b.Vx_mL,HPLC_b.Total_Chl_a,HPLC_b.Total_Chl_b,HPLC_b.Total_Chl_c,HPLC_b.Carotene,HPLC_b.But_Fucoxanthin,HPLC_b.Hex_Fucoxanthin,HPLC_b.Alloxanthin,HPLC_b.Diadinoxanthin,HPLC_b.Diatoxanthin,HPLC_b.Fucoxanthin,HPLC_b.Peridinin,HPLC_b.Zeaxanthin,HPLC_b.Monovinyl_Chl_a,HPLC_b.Divinyl_Chl_a,HPLC_b.Chlorophyllide_a,HPLC_b.Monovinyl_Chl_b,HPLC_b.Divinyl_Chl_b,HPLC_b.Chlorophyll_c1,HPLC_b.Chlorophyll_c2,HPLC_b.Chlorophyll_c12,HPLC_b.Chlorophyll_c3,HPLC_b.Lutein,HPLC_b.Neoxanthin,HPLC_b.Violaxanthin,HPLC_b.Pheophytin,HPLC_b.Pheophorbide_a,HPLC_b.Prasinoxanthin,HPLC_b.Gyroxanthin_Diester,HPLC_b.TChl,HPLC_b.PPC,HPLC_b.PSC,HPLC_b.PSP,HPLC_b.TCaro,HPLC_b.TAcc,HPLC_b.Tpig,HPLC_b.DP,HPLC_b.TAcc/Tchla,HPLC_b.PSC/TCaro,HPLC_b.PPC/Tcaro,HPLC_b.TChl/TCaro,HPLC_b.PPC/Tpig,HPLC_b.PSP/TPig,HPLC_b.TChla/TPig,HPLC_b.microplankton,HPLC_b.nanoplankton,HPLC_b.picoplankton,HPLC_b.FL_Chl_a,HPLC_b.FL_Pheo,HPLC_b.Chl_a_Allomer,HPLC_b.Chl_a_Epimer FROM HPLC_reps';


SQL_query = 'SELECT ALL * from MVCOseabassHPLC';  %get all field from the table HPLC_reps
e =exec(conn, SQL_query);

%e = exec(conn,'SELECT ALL Event_Number,Event_Number_Niskin,Date,Start_Time_UTC,Latitude,Longitude,Depth,HPLC_a,HPLC_a_amt_filt,HPLC_a.Vx_mL,HPLC_a.Total_Chl_a,HPLC_a.Total_Chl_b,HPLC_a.Total_Chl_c,HPLC_a.Carotene,HPLC_a.But_Fucoxanthin,HPLC_a.Hex_Fucoxanthin,HPLC_a.Alloxanthin,HPLC_a.Diadinoxanthin,HPLC_a.Diatoxanthin,HPLC_a.Fucoxanthin,HPLC_a.Peridinin,HPLC_a.Zeaxanthin,HPLC_a.Monovinyl_Chl_a,HPLC_a.Divinyl_Chl_a,HPLC_a.Chlorophyllide_a,HPLC_a.Monovinyl_Chl_b,HPLC_a.Divinyl_Chl_b,HPLC_a.Chlorophyll_c1,HPLC_a.Chlorophyll_c2,HPLC_a.Chlorophyll_c12,HPLC_a.Chlorophyll_c3,HPLC_a.Lutein,HPLC_a.Neoxanthin,HPLC_a.Violaxanthin,HPLC_a.Pheophytin,HPLC_a.Pheophorbide_a,HPLC_a.Prasinoxanthin,HPLC_a.Gyroxanthin_Diester,HPLC_a.TChl,HPLC_a.PPC,HPLC_a.PSC,HPLC_a.PSP,HPLC_a.TCaro,HPLC_a.TAcc,HPLC_a.Tpig,HPLC_a.DP,HPLC_a.TAcc/Tchla,HPLC_a.PSC/TCaro,HPLC_a.PPC/Tcaro,HPLC_a.TChl/TCaro,HPLC_a.PPC/Tpig,HPLC_a.PSP/TPig,HPLC_a.TChla/TPig,HPLC_a.microplankton,HPLC_a.nanoplankton,HPLC_a.picoplankton,HPLC_a.FL_Chl_a,HPLC_a.FL_Pheo,HPLC_a.Chl_a_Allomer,HPLC_a.Chl_a_Epimer,HPLC_b,HPLC_b_amt_filt,HPLC_b.Vx_mL,HPLC_b.Total_Chl_a,HPLC_b.Total_Chl_b,HPLC_b.Total_Chl_c,HPLC_b.Carotene,HPLC_b.But_Fucoxanthin,HPLC_b.Hex_Fucoxanthin,HPLC_b.Alloxanthin,HPLC_b.Diadinoxanthin,HPLC_b.Diatoxanthin,HPLC_b.Fucoxanthin,HPLC_b.Peridinin,HPLC_b.Zeaxanthin,HPLC_b.Monovinyl_Chl_a,HPLC_b.Divinyl_Chl_a,HPLC_b.Chlorophyllide_a,HPLC_b.Monovinyl_Chl_b,HPLC_b.Divinyl_Chl_b,HPLC_b.Chlorophyll_c1,HPLC_b.Chlorophyll_c2,HPLC_b.Chlorophyll_c12,HPLC_b.Chlorophyll_c3,HPLC_b.Lutein,HPLC_b.Neoxanthin,HPLC_b.Violaxanthin,HPLC_b.Pheophytin,HPLC_b.Pheophorbide_a,HPLC_b.Prasinoxanthin,HPLC_b.Gyroxanthin_Diester,HPLC_b.TChl,HPLC_b.PPC,HPLC_b.PSC,HPLC_b.PSP,HPLC_b.TCaro,HPLC_b.TAcc,HPLC_b.Tpig,HPLC_b.DP,HPLC_b.TAcc/Tchla,HPLC_b.PSC/TCaro,HPLC_b.PPC/Tcaro,HPLC_b.TChl/TCaro,HPLC_b.PPC/Tpig,HPLC_b.PSP/TPig,HPLC_b.TChla/TPig,HPLC_b.microplankton,HPLC_b.nanoplankton,HPLC_b.picoplankton,HPLC_b.FL_Chl_a,HPLC_b.FL_Pheo,HPLC_b.Chl_a_Allomer,HPLC_b.Chl_a_Epimer FROM HPLC_reps');

e = fetch(e);

%Create header file with metadata
%creates a 1x113 struct with the metadata information
attributes = attr(e);
header_seabass_hplc = cellstr(strvcat(attributes.fieldName));

close(e)

%Create a variable 'HPLC_reps' which equals the data contained in
%the variable 'e'
HPLC=e.Data;

% Close database connection.
%close(conn)
clear e

SQL_query = 'SELECT ALL * from Event';  %get all field from the table MVCO_Chl_reps
e =exec(conn, SQL_query);
%e = exec(conn,'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,Filter_Size,"Chl (ug/l)","Phaeo (ug/l)",quality_flag,Cal_Date FROM MVCO_Chl_reps');

e = fetch(e);

attributes = attr(e);
header_event = cellstr(strvcat(attributes.fieldName));

close(e);

event = e.Data;

% Close database connection.
close(conn);

clear e conn s exec_str tempstr attributes ind SQL_query


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%PAIR DOWN HPLC DATA%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%get just MVCO samples that have data
ind     = find(strncmp(HPLC(:,1),'MV',2));
HPLC    = HPLC(ind,:);
ind     = find(~strcmp(HPLC(:,4),'null'));
HPLC    = HPLC(ind,:);

%still have hpl duplicate runs. need to get rid of. Do not average, only
%use original run
%hpl OR gfsc id # - new lab different id field but not differentiated in our database
ind         = find(strcmp(header_seabass_hplc,'hpl_id'));
hpl_id      = HPLC(:,ind);
temp        = char(hpl_id);
temp        = temp(:,4:end);
temp        = str2num(temp);
ind         = find(temp - floor(temp) == 0);
HPLC        = HPLC(ind,:);
hpl_id      = hpl_id(ind);
clear temp

ind         = find(strcmp(header_seabass_hplc, 'Event_Number'));
event_num   = cell2mat(HPLC(:,ind));
unqevent = unique(HPLC(:,ind));
ind         = find(strcmp(header_seabass_hplc, 'Start_Date'));
datetemp   = cell2mat(HPLC(:,ind)); datetemp = datetemp(:,1:11);
ind         = find(strcmp(header_seabass_hplc, 'Start_Time_UTC'));
datetemp2 = cell2mat(HPLC(:,ind)); datetemp2 = datetemp2(:,12:19);
matdate    = datenum([datetemp, datetemp2], 'yyyy-mm-dd HH:MM:SS');
clear datetemp*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%matday = floor(matdate);
%unqday = unique(matday);
%clear datetemp unqday
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%use event log lat/lon below
%{
ind         = find(strcmp(header_seabass_hplc,'Latitude'));
lat         = cell2mat(HPLC(:,ind)); 
ind         = find(strcmp(header_seabass_hplc,'Longitude'));
lon         = cell2mat(HPLC(:,ind));
%}
ind         = find(strcmp(header_seabass_hplc,'Depth'));
depth      = cell2mat(HPLC(:,ind));
%we include our HS# in case we have an inquiry from outside our lab- easier for us to look up information about using our database
ind         = find(strcmp(header_seabass_hplc,'HPLC_Name'));
HSno       = HPLC(:,ind);
%we decide quality of value after comparing to fluor chl, any sampling issues, etc.
ind         = find(strcmp(header_seabass_hplc,'quality'));
quality     = cell2mat(HPLC(:,ind));

% need to find duplicates. one of last columns is hplc_b from bottle table.
% compare that to HSno from HPLCproc.xl and find where they match and that
% is a duplicate
ind       = find(strcmp(header_seabass_hplc,'HPLC_b'));
HSdup     = HPLC(:,ind);
replicate = ones(length(HPLC),1);
replicate(strcmp(HSno,HSdup)) = 2;
clear ind HSdup

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%PAIR DOWN EVENT DATA%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%get just MVCO samples that have data
tind = find(strncmp(event(:,1), 'MVCO',4));
event = event(tind,:);
event_num2 = strvcat(event(:,1));
lat = cell2mat(event(:,10)); 
lon = cell2mat(event(:,11));
wind_speed = cell2mat(event(:,15));
cloud_percent = cell2mat(event(:,14));
water_depth = cell2mat(event(:,12));
wave_height = cell2mat(event(:,17));
secchi_depth = -9999;

%format time in matday and then separate samples into those processed at
%horn point lab and those processed at goddard NFSC. need to make 2
%separate files. it matters in header information regarding where they wree
%processed and also field id (hpl_id or hplc_gsfc_id)
%separate samples by finding dates greater than or less than dividing date (date below)
processing_lab_change_date = datenum('08/12/2010','mm/dd/yyyy');

pig_fields={'Tot_Chl_a','Tot_Chl_b',...
    'Tot_Chl_c','alpha-beta-Car','But-fuco','Hex-fuco','Allo','Diadino','Diato','Fuco','Perid',...
    'Zea','MV_Chl_a','DV_Chl_a','Chlide_a','MV_Chl_b','DV_Chl_b','Chl_c1','Chl_c2',...
    'Chl_c1c2','Chl_c3','Lut','Neo','Viola','Phytin_a','Phide_a','Pras','Gyro','Tchl','PPC',...
    'PSC','PSP','Tcar','Tacc','Tpg','DP','Tacc_Tchla','PSC_Tcar','PPC_Tcar','TChl_Tcar',...
    'PPC_Tpg','PSP_Tpg','Tchla_Tpg','mPF','nPF','pPF'};

%create and organize matrix of appropriate types of pigment values 
%loop thourhg fields variable set before for loop
%fill empty values with -9999 (instead of NaN) because that's what NASA wants
data = repmat(-9999,length(depth),length(pig_fields));
for count = 1:length(pig_fields)
    spot = find(strcmp(header_seabass_hplc,pig_fields(count)));
    if length(spot)==1
        temp = cell2mat(HPLC(:,spot));
        data(:,count) = temp;
    end
end
clear spot temp ind


%any value below 0.001 is considered below detection limit and therefore
%should change to -111 for sebass files
% 
%revised 'sept 13,2016 Goddard has yet again changed something. BDL changed
%from -111 to -8888
% 
ind = find(data < 0.001 & data ~= -9999);
data(ind) = -8888;

for eventcount = 1:length(unqevent), %each unique event = different cast or bucket MV_###
    ind = find(strcmp(event_num, unqevent(eventcount)));  %hplc matrix rows
    event_table_row = find(strcmp(event(:,1), unqevent(eventcount)));    %eventlog row
    cruise = ['MVCO_' datestr(matdate(ind(1)), 'mmddyy')];
if matdate(ind(1)) < processing_lab_change_date
    bassfile = ['hplc_' datestr(matdate(ind(1)),'yyyymmdd_HHMM') '.sb'];
    processing_center = 'HPLC samples submitted to the Horn Point Laboratory Pigment Analysis Lab (HPL - UMCES)';
    fields_list = 'depth,number,sample,hpl_id,Tot_Chl_a,Tot_Chl_b,Tot_Chl_c,alpha-beta-Car,But-fuco,Hex-fuco,Allo,Diadino,Diato,Fuco,Perid,Zea,MV_Chl_a,DV_Chl_a,Chlide_a,MV_Chl_b,DV_Chl_b,Chl_c1,Chl_c2,Chl_c1c2,Chl_c3,Lut,Neo,Viola,Phytin_a,Phide_a,Pras,Gyro,Tchl,PPC,PSC,PSP,Tcar,Tacc,Tpg,DP,Tacc_Tchla,PSC_Tcar,PPC_Tcar,TChl_Tcar,PPC_Tpg,PSP_Tpg,Tchla_Tpg,mPF,nPF,pPF,quality';
else
    bassfile = ['hplc_' datestr(matdate(ind(1)),'yyyymmdd_HHMM') '.sb'];
    processing_center = 'HPLC samples analyzed at the NASA Goddard OBPG HPLC Lab by Crystal Thomas';
    fields_list = 'depth,number,sample,hplc_gsfc_id,Tot_Chl_a,Tot_Chl_b,Tot_Chl_c,alpha-beta-Car,But-fuco,Hex-fuco,Allo,Diadino,Diato,Fuco,Perid,Zea,MV_Chl_a,DV_Chl_a,Chlide_a,MV_Chl_b,DV_Chl_b,Chl_c1,Chl_c2,Chl_c1c2,Chl_c3,Lut,Neo,Viola,Phytin_a,Phide_a,Pras,Gyro,Tchl,PPC,PSC,PSP,Tcar,Tacc,Tpg,DP,Tacc_Tchla,PSC_Tcar,PPC_Tcar,TChl_Tcar,PPC_Tpg,PSP_Tpg,Tchla_Tpg,mPF,nPF,pPF,quality';
end

disp(bassfile)
%{
%tease out data from horn point lab or gfsc as needed
HPLC       = fullHPLC(ind,:);
%Make station labeling matrix for matching up all the different types of
%data (including ctd casts)
%recalculate dates with newly reduced HPLC list
ind         = find(strcmp(header_seabass_hplc, 'Start_Date'));
datetemp   = cell2mat(HPLC(:,ind)); datetemp = datetemp(:,1:11);
ind         = find(strcmp(header_seabass_hplc, 'Start_Time_UTC'));
datetemp2 = cell2mat(HPLC(:,ind)); datetemp2 = datetemp2(:,12:19);
matdate    = datenum([datetemp, datetemp2], 'yyyy-mm-dd HH:MM:SS');
ind         = find(strcmp(header_seabass_hplc,'Latitude'));
lat         = cell2mat(HPLC(:,ind)); 
ind         = find(strcmp(header_seabass_hplc,'Longitude'));
lon         = cell2mat(HPLC(:,ind));
ind         = find(strcmp(header_seabass_hplc,'Depth'));
depth      = cell2mat(HPLC(:,ind));
%we include our HS# in case we have an inquiry from outside our lab- easier for us to look up information about using our database
ind         = find(strcmp(header_seabass_hplc,'HPLC_Name'));
HSno       = HPLC(:,ind);
%hpl OR gfsc id # - new lab different id field but not differentiated in our database
ind         = find(strcmp(header_seabass_hplc,'hpl_id'));
hpl_id      = HPLC(:,ind);
%we decide quality of value after comparing to fluor chl, any sampling issues, etc.
ind         = find(strcmp(header_seabass_hplc,'quality'));
quality     = cell2mat(HPLC(:,ind));
%}


%station4hplc = NaN(length(HPLC),1);
% Write results to SEABASS file
%very specific header format required for seabass files. cannot be any
%spaces in lines excep for commented lines beginning with !
%any missing values labeled with -9999
fid=fopen([datadir,'\seabass\HPLC\',bassfile],'w');
fprintf(fid,'/begin_header\n');
fprintf(fid,'/data_file_name=%-s\n',bassfile);
fprintf(fid,'/affiliations=WHOI\n');
fprintf(fid,'/investigators=%-s\n',investigators);
fprintf(fid,'/experiment=%-s\n',experiment);
fprintf(fid,'/cruise=%-s\n',cruise);
fprintf(fid,'/station=%-s\n',station);
fprintf(fid,'/contact=%-s\n',contact);
fprintf(fid,'/data_type=%-s\n', data_type);
fprintf(fid,'/data_status=%-s\n',data_status);
fprintf(fid,'/documents=%s\n',documents);
fprintf(fid,'/calibration_files=%-s\n',calibration_files);
fprintf(fid,'/north_latitude=%-3.4f[DEG]\n',lat(event_table_row));
fprintf(fid,'/south_latitude=%-3.4f[DEG]\n',lat(event_table_row));
fprintf(fid,'/east_longitude=%-3.4f[DEG]\n',lon(event_table_row));
fprintf(fid,'/west_longitude=%-3.4f[DEG]\n',lon(event_table_row));
fprintf(fid,'/start_date=%-8s\n',datestr(matdate(ind(1)),'yyyymmdd'));
fprintf(fid,'/end_date=%-8s\n',datestr(matdate(ind(1)),'yyyymmdd'));
fprintf(fid,'/start_time=%-8s[GMT]\n',datestr(matdate(ind(1)),'HH:MM:SS'));
fprintf(fid,'/end_time=%-8s[GMT]\n',datestr(matdate(ind(1)),'HH:MM:SS'));
fprintf(fid,'/wind_speed=%-.0f\n',wind_speed(event_table_row));
fprintf(fid,'/wave_height=%-.0f\n',wave_height(event_table_row));
fprintf(fid,'/secchi_depth=%-.0f\n',secchi_depth);
fprintf(fid,'/water_depth=%-.1f\n',water_depth(event_table_row));
fprintf(fid,'/cloud_percent=%-.0f\n',cloud_percent(event_table_row));
%processing center now specified after Crystal moved from hpl to gfsc
fprintf(fid,'!\n');
fprintf(fid,'! %-s\n',processing_center);
fprintf(fid,'!\n');
fprintf(fid,'! Samples were collected under vacuum (~5 psi) and filtered through 25mm Whatman GF/F filters and stored in liquid nitrogen prior to analysis\n');
fprintf(fid,'!\n');
fprintf(fid,'! Analyst-specific quality control 1 = no suspicion; 2 = some question, high replicate variability; 3 = very suspicious\n');
fprintf(fid,'!\n');
fprintf(fid,'! Measurements below detection limit are assigned the value -111\n');
fprintf(fid,'! limit of detection = 0.001 mg/m^3\n');
fprintf(fid,'!\n');
fprintf(fid,'/missing=-9999\n');
fprintf(fid,'/below_detection_limit=-8888\n');
fprintf(fid,'/delimiter=space\n');
%fprintf(fid,'/fields=station,date,time,lat,lon,depth,sample,hpl_id,Tot_Chl_a,Tot_Chl_b,Tot_Chl_c,alpha-beta-Car,But-fuco,Hex-fuco,Allo,Diadino,Diato,Fuco,Perid,Zea,MV_Chl_a,DV_Chl_a,Chlide_a,MV_Chl_b,DV_Chl_b,Chl_c1,Chl_c2,Chl_c1c2,Chl_c3,Lut,Neo,Viola,Phytin_a,Phide_a,Pras,Gyro,Tchl,PPC,PSC,PSP,Tcar,Tacc,Tpg,DP,Tacc_Tchla,PSC_Tcar,PPC_Tcar,TChl_Tcar,PPC_Tpg,PSP_Tpg,Tchla_Tpg,mPF,nPF,pPF,quality\n');
fprintf(fid,'/fields=%-s\n',fields_list);
fprintf(fid,'/units=m,none,none,none,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,none,none,none,none,none,none,none,none,none,none,none\n');
fprintf(fid,'/end_header\n');

%write all the fields to the seabass text file line by line. i tried to
%just add the entire matrix all at once (ex-56x46 matrix with event,
%matdate etc as long 56x1 columns at the beginning) but very ugly things
%happened. below is very unellegant except it gets the job done and it's
%only 1 file so whatever. 

%you cannot use cells with fprintf everything is converted from the raw
%cell data to either char(%s) or double(%f)
for count = 1:length(ind),
        fprintf(fid,'%-3.1f %0.0f %-5s %s %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %1f\n'...
            ,depth(ind(count)), replicate(ind(count)), cell2mat(HSno(ind(count))), cell2mat(hpl_id(ind(count))), data(ind(count),1), data(ind(count),2), data(ind(count),3), data(ind(count),4),...
            data(ind(count),5),data(ind(count),6), data(ind(count),7), data(ind(count),8), data(ind(count),9), data(ind(count),10), data(ind(count),11), data(ind(count),12), data(ind(count),13),...
            data(ind(count),14), data(ind(count),15), data(ind(count),16), data(ind(count),17), data(ind(count),18), data(ind(count),19), data(ind(count),20), data(ind(count),21), data(ind(count),22),...
            data(ind(count),23), data(ind(count),24), data(ind(count),25), data(ind(count),26), data(ind(count),27), data(ind(count),28), data(ind(count),29), data(ind(count),30), data(ind(count),31),...
            data(ind(count),32), data(ind(count),33), data(ind(count),34), data(ind(count),35), data(ind(count),36), data(ind(count),37), data(ind(count),38), data(ind(count),39), data(ind(count),40),...
            data(ind(count),41), data(ind(count),42), data(ind(count),43), data(ind(count),44), data(ind(count),45), data(ind(count),46), quality(ind(count)));
end
fclose(fid);
end