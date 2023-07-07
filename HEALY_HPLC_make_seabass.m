%TCrockford 2/1/2012
%write HPLC data from excel to a seabass text file for submission. the
%script will re-write over the last existing file, updating the file as new
%data become available. the script uses the HPLCproc excel document. All
%new HPLC data should be added to this file to have one main file with all
%data.
%separate scripts for HEALY vs MVCO data because header lines, events, etc
%are different for each data set.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%*************update cruise and switch function below for each new cruise data set****************
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%this should be updated for each set of cruise HPLC data. the plan is to
%make a separate seabass file for each cruise.
cruise = {'ICESCAPE2010-HEALY1001'; 'ICESCAPE2011-HEALY1101'};

file ='C:\Research Assistant\MVCO\HPLC\HEALY_HPLCproc.xls'
%this is every field contained in the seabass file with the exact field
%label format as it appears in the seabass file. need this to match
%up against 
fields={'station','date','time','lat','lon','depth','sample','hpl_id','Tot_Chl_a','Tot_Chl_b','Tot_Chl_c','alpha-beta-Car','But-fuco','Hex-fuco','Allo','Diadino','Diato','Fuco','Perid','Zea','MV_Chl_a','DV_Chl_a','Chlide_a','MV_Chl_b','DV_Chl_b','Chl_c1','Chl_c2','Chl_c1c2','Chl_c3','Lut','Neo','Viola','Phytin_a','Phide_a','Pras','Gyro','Tchl','PPC','PSC','PSP','Tcar','Tacc','Tpg','DP','Tacc_Tchla','PSC_Tcar','PPC_Tcar','TChl_Tcar','PPC_Tpg','PSP_Tpg','Tchla_Tpg','mPF','nPF','pPF'};
%set some default strings
commentstr='For submission to seabass.';
datadir = 'C:\data\mvcodata\';
investigators = 'Samuel_Laney_&_Heidi_Sosik';
contact = 'slaney@whoi.edu';
experiment = 'ICESCAPE';

for overallcount=1:length(cruise)
if strcmp(cruise,'ICESCAPE2010-HEALY1001');
    processing_center = 'HPLC samples submitted to the Horn Point Laboratory Pigment Analysis Lab (HPL - UMCES)';
    fields_list = 'date,time,lat,lon,depth,sample,hpl_id,Tot_Chl_a,Tot_Chl_b,Tot_Chl_c,alpha-beta-Car,But-fuco,Hex-fuco,Allo,Diadino,Diato,Fuco,Perid,Zea,MV_Chl_a,DV_Chl_a,Chlide_a,MV_Chl_b,DV_Chl_b,Chl_c1,Chl_c2,Chl_c1c2,Chl_c3,Lut,Neo,Viola,Phytin_a,Phide_a,Pras,Gyro,Tchl,PPC,PSC,PSP,Tcar,Tacc,Tpg,DP,Tacc_Tchla,PSC_Tcar,PPC_Tcar,TChl_Tcar,PPC_Tpg,PSP_Tpg,Tchla_Tpg,mPF,nPF,pPF';
else
    processing_center = 'HPLC samples analyzed at the NASA Goddard OBPG HPLC Lab by Crystal Thomas';
    fields_list = 'date,time,lat,lon,depth,sample,hplc_gsfc_id,Tot_Chl_a,Tot_Chl_b,Tot_Chl_c,alpha-beta-Car,But-fuco,Hex-fuco,Allo,Diadino,Diato,Fuco,Perid,Zea,MV_Chl_a,DV_Chl_a,Chlide_a,MV_Chl_b,DV_Chl_b,Chl_c1,Chl_c2,Chl_c1c2,Chl_c3,Lut,Neo,Viola,Phytin_a,Phide_a,Pras,Gyro,Tchl,PPC,PSC,PSP,Tcar,Tacc,Tpg,DP,Tacc_Tchla,PSC_Tcar,PPC_Tcar,TChl_Tcar,PPC_Tpg,PSP_Tpg,Tchla_Tpg,mPF,nPF,pPF';
end
%new seabass file for each cruise. include cruise in filename
    [data,text,raw]=xlsread(file,'Report','a5:bt500');
    bassfile = [cell2mat(cruise(overallcount)) '_HPLC_' datestr(now,'ddmmmyyyy') '.sb'];
%specific a5:bt200 selection excludes the top header information etc in the
%file. the 200th row is an arbitrary length to hopefully include all data
%in the file. the raw matrix is trimmed down to the data length later on.
%be sure that the data matrix is not larger than this else data will be
%left out.
%raw data is used because it is most straightforward to use the find matrix
%later on
%[data,text,raw]=xlsread(file,'Report','a5:bt500');
%only want the header from the text matrix. other text that is not needed 
%is included from the data columns (ex-sample id, station, body of water, etc)
header=text(1,:);
raw=raw(2:size(data,1)+1,:);
clear data text

%date converted from year and year day yyyymmdd
ind = find(strcmp(header, 'Year of Sample'));
year = cell2mat(raw(:,ind));
ind = find(strcmp(header, 'Sequential Day of Year'));
jday = cell2mat(raw(:,ind));
switchdate=datenum(year(:),1,1) + jday(:)-1;
matdate=datestr(switchdate,'yyyymmdd');
clear jday year
    switch cell2mat(cruise(overallcount))
        case 'ICESCAPE2010-HEALY1001'
            ind=find(switchdate <= datenum('20100719','yyyymmdd'));
        case 'ICESCAPE2011-HEALY1101'
            ind=find(switchdate > datenum('20110625','yyyymmdd') & switchdate < datenum('20110729','yyyymmdd'));
        otherwise error('adjust switch statement and add new cruise')
    end
raw          = raw(ind,:);
matdate     = matdate(ind,:);
switchdate  = switchdate(ind);
startdate    = datestr(min(switchdate),'yyyymmdd');
enddate     = datestr(max(switchdate),'yyyymmdd');
    
%time is a separate field from date. needs : in format so use is as a char.
%start/end time not included in header because that seems more applicable
%for a single day and not for start/end day time
ind = find(strcmp(header, 'GMT Time'));
temptime = cell2mat(raw(:,ind));

%if the timestamp is before 1000 it will only have 3 digits that are
%carried over from the excel file. need string format hh:mm:ss so add 0 to
%start of string
for count = 1:length(temptime)
    stamp=num2str(temptime(count));
    if length(stamp) <4
        stamp=[repmat('0',1,4-length(stamp)) stamp];
    end
    time(count)=mat2cell([stamp(1:2) ':' stamp(3:4) ':00']);
end
clear count temptime stamp

ind = find(strcmp(header, 'Latitude'));
lat = raw(:,ind);
ind = find(strcmp(header, 'Longitude'));
lon = raw(:,ind);
ind = find(strcmp(header, 'Depth (meters)'));
depth = raw(:,ind);

%HS number from our in-house labeling system in case we have an inquiry
%from an outside source about a specific sample
ind = find(strcmp(header, 'Sequential Sample Number'));
HSno = raw(:,ind);

%data gets h.p.l. # when it is run. xx-xxx.5 is they duplicate run of same sample
%Oct 2012 - Horn point lab moved to goddard so this hplc# still exists, now
%it's call "GSFC lab sample code"
ind = find(strcmp(header, 'Horn Point Lab sample code'));
hpl_id = raw(:,ind);
clear ind

%HEALY1001 samples taken between stations so NA
%HLY1101 didn't have any notes about stations so still NA
%station=repmat('NA', length(lat),1);
%Oct2012 - REMOVE STATION FIELD BECAUSE NO DATA

%not sure if this is the most sensible way to organize data fields
%cell array of entire field at top of this script  finds the column in the
%excel file. this ensure no mixup of pigments in case column locations in 
%data file change.
data=[];
for count=1:length(fields(9:end))
    spot=strcmp(fields(count+8),header);
    if sum(spot)==1
        temp=cell2mat(raw(:,spot));
        ind=find(isnan(temp));
        temp(ind)=-9999;
    else
        temp=repmat(-9999,length(lat),1);
    end
    data=[data temp];
end
clear spot temp ind

disp(bassfile)
% Write results to SEABASS file
%very specific header format required for seabass files. cannot be any
%spaces in lines excep for commented lines beginning with !
fid=fopen(['C:\Research Assistant\MVCO\HPLC\',bassfile],'W');
fprintf(fid,'/begin_header\n');
fprintf(fid,'/investigators=%-s\n',investigators);
fprintf(fid,'/affiliations=WHOI\n');
fprintf(fid,'/contact=%-s\n',contact);
fprintf(fid,'/experiment=%-s\n',experiment);
fprintf(fid,'/cruise=%-s\n',cell2mat(cruise(overallcount)));
fprintf(fid,'/station=NA\n'); 
fprintf(fid,'/data_file_name=%-s\n',bassfile);
fprintf(fid,'/documents=default_readme.txt\n');
fprintf(fid,'/calibration_files=missing_calibration.txt\n'); 
fprintf(fid,'/data_type=pigment\n'); 
fprintf(fid,'/data_status=final\n');
%fprintf(fid,'/parameters=......\n');
    
fprintf(fid,'/start_date=%-s\n',startdate);
fprintf(fid,'/end_date=%-s\n',enddate);
fprintf(fid,'/start_time=00:00:00[GMT]\n');
fprintf(fid,'/end_time=23:59:59[GMT]\n');
fprintf(fid,'/north_latitude=%-3.4f[DEG]\n',max(cell2mat(lat)));
fprintf(fid,'/south_latitude=%-3.4f[DEG]\n',min(cell2mat(lat)));
fprintf(fid,'/east_longitude=%-3.4f[DEG]\n',max(cell2mat(lon)));
fprintf(fid,'/west_longitude=%-3.4f[DEG]\n',min(cell2mat(lon)));
fprintf(fid,'/water_depth=NA\n'); %%-5.0f\n
%measurement depth
fprintf(fid,'/secchi_depth=NA\n'); %%-5.0f
fprintf(fid,'/cloud_percent=NA\n'); %%-5.0f
fprintf(fid,'/wind_speed=NA\n'); %%-5.0f\n
fprintf(fid,'/wave_height=NA\n'); %%-5.0f\n
fprintf(fid,'!\n');
%fprintf(fid,'! HPLC samples submitted to the Horn Point Laboratory Pigment Analysis Lab (HPL - UMCES)\n');
%processing center now specified after Crystal moved from hpl to gfsc
fprintf(fid,'! %-s\n',processing_center);
fprintf(fid,'!\n');
fprintf(fid,'! Samples were collected under vacuum (~5 psi) and filtered through 25mm Whatman GF/F filters and stored at -80 degrees C and then liquid nitrogen prior to analysis\n');
fprintf(fid,'!\n');
fprintf(fid,'! For submission to seabass.\n');
fprintf(fid,'!\n');
fprintf(fid,'/missing=-9999\n');
fprintf(fid,'/delimiter=space\n');
%fprintf(fid,'/fields=date,time,lat,lon,depth,sample,hpl_id,Tot_Chl_a,Tot_Chl_b,Tot_Chl_c,alpha-beta-Car,But-fuco,Hex-fuco,Allo,Diadino,Diato,Fuco,Perid,Zea,MV_Chl_a,DV_Chl_a,Chlide_a,MV_Chl_b,DV_Chl_b,Chl_c1,Chl_c2,Chl_c1c2,Chl_c3,Lut,Neo,Viola,Phytin_a,Phide_a,Pras,Gyro,Tchl,PPC,PSC,PSP,Tcar,Tacc,Tpg,DP,Tacc_Tchla,PSC_Tcar,PPC_Tcar,TChl_Tcar,PPC_Tpg,PSP_Tpg,Tchla_Tpg,mPF,nPF,pPF\n');
fprintf(fid,'/fields=%-s\n',fields_list);
fprintf(fid,'/units=yyyymmdd,hh:mm:ss,degrees,degrees,m,none,none,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,mg/m^3,none,none,none,none,none,none,none,none,none,none\n');
fprintf(fid,'/end_header\n');

%write all the fields to the seabass text file line by line. i tried to
%just add the entire matrix all at once (ex-56x46 matrix with event,
%matdate etc as long 56x1 columns at the beginning) but very ugly things
%happened. below is very unellegant except it gets the job done and it's
%only 1 file so whatever. 

%you cannot use cells with fprintf everything is converted from the raw
%cell data to either char or double
for count = 1:length(lat),
        fprintf(fid,'%-8s %-8s %-3.4i %-3.4i %-3.1f %-5s %s %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f %2.3f \n'...
            , matdate(count,:), cell2mat(time(count)), cell2mat(lat(count)), cell2mat(lon(count)), cell2mat(depth(count)),...
            cell2mat(HSno(count)), cell2mat(hpl_id(count)), data(count,1), data(count,2), data(count,3), data(count,4), data(count,5),...
            data(count,6), data(count,7), data(count,8), data(count,9), data(count,10), data(count,11), data(count,12), data(count,13),...
            data(count,14), data(count,15), data(count,16), data(count,17), data(count,18), data(count,19), data(count,20), data(count,21), data(count,22),...
            data(count,23), data(count,24), data(count,25), data(count,26), data(count,27), data(count,28), data(count,29), data(count,30), data(count,31),...
            data(count,32), data(count,33), data(count,34), data(count,35), data(count,36), data(count,37), data(count,38), data(count,39), data(count,40),...
            data(count,41), data(count,42), data(count,43), data(count,44), data(count,45), data(count,46));
end
fclose(fid);


[status,message,messageid] = copyfile(['C:\Research Assistant\MVCO\HPLC\' bassfile], ['C:\data\mvcodata\seabass\' bassfile])
end

