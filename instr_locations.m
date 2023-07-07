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
% database. Check connection by going to Control Panel > Administrative
% Tools > Data Sources (ODBC)

conn = database('Sosik_Instruments','','password');

% Read data from database.  
% Make the SQL statement easily with querybuilder and paste in here - or select all fields with *
SQL_query = 'SELECT ALL * from Location';  %get all field from the table Location in the Sosik_Instruments database
e =exec(conn, SQL_query);
e = fetch(e);

%Create header file with metadata
%creates a 1x7 struct with the metadata information
attributes = attr(e);
header = cellstr(strvcat(attributes.fieldName));

close(e)

% Close database connection.
close(conn)

    
%Create a variable 'locations' which equals the data contained in
%the variable 'e'
locations=e.Data;
    
clear e conn s exec_str tempstr SQL* attributes

locations(find(strcmp(locations,'null'))) = {'NaN'};
date_spot = find(strcmp(header, 'Date'));
ind = find(~strcmp(locations(:,date_spot),'NaN'));  %get rid of any database enteries without dates because they're useless
locations=locations(ind,:);
date=char(locations(:,date_spot));
date=datenum(date(:,1:10),'yyyy-mm-dd'); %replace the string date in the locations matrix with matlab date

%sort out just the fluorometers from all the instruments list
SN_spot=find(strcmp(header,'Serial_Number'));
local_spot=find(strcmp(header,'Location'));
temp=unique(locations(:,SN_spot));
tick=find(strncmp(temp,'FL',2));
fluor=temp(tick);
clear temp tick ind date_spot
instr_count=NaN(length(date),1);
matday=instr_count;
SN =num2cell(instr_count);
local=SN;
days=NaN(length(date),3);
days_header={'Days Deployed', 'Days Without Service','Total Days Deployed'};
mark_dead=zeros(length(date),1);

dead = {'FLCDS_164', 'FLNTUSB_694', 'FLNTUSB_958','FLNTUSB_961','FLSB_024','FLSB_042', 'FLSB_256'};
%############################### left off editing
swapdatechl=[];
swapchl=[];
count1=1;
for count = 1:length(fluor)
    ind=find(strcmp(locations(:,SN_spot),fluor(count))); %find all the entries for a specific fluorometer
    [b,xi]=sort(date(ind)); %order all the entries by date
    local_temp=locations(ind(xi),local_spot); %order locations by date
    date_temp=date(ind(xi)); %sort date
    RDReD=cell2mat(locations(ind(xi),5:7)); %pull out retrieval/deployment/redeploy info by date
    
    if sum(strncmp(upper(fluor(count)),'FLC',3)) <1
    ind2 = strncmp('MVCO',local_temp(:),4);
    swapdatechl=[swapdatechl; date_temp(ind2)];
    swapchl=[swapchl; repmat(fluor(count),length(date_temp(ind2)),1)];
    end
    
    wo_service=0;
    total_temp=0;
    days_temp=0;
    for i = 1:length(date_temp)
        if i == 1
            temp1 = 0;
            instr_count(count1)=count;
            SN(count1)=fluor(count);
            matday(count1)=date_temp(i);
            local(count1)=local_temp(i);
            days(count1,1)=days_temp;
            days(count1,2)=wo_service;
            days(count1,3)=total_temp;
            count1=count1+1;
        elseif RDReD(i,2)==1 | RDReD(i,3)==1
            if i ~= 1
                temp1=date_temp(i)-date_temp(i-1);
            end%problem with this basic calculation is the wo service dates include days from purchase of fluor to first deployment, which shouldn't really be included in this value
            if sum(strncmp(lower(local_temp(:)),'retired',7) | strncmp(lower(local_temp(:)),'water damage',12) | strncmp(lower(local_temp(i,:)),'lost',4)) > 0
                mark_dead(count1) = 1;
            end
            wo_service=wo_service+temp1;
            instr_count(count1)=count;
            SN(count1)=fluor(count);
            matday(count1)=date_temp(i);
            local(count1)=local_temp(i);
            days(count1,1)=days_temp;
            days(count1,2)=wo_service;
            days(count1,3)=total_temp;
            count1=count1+1;
        elseif RDReD(i,1)==1
            if sum(strncmp(lower(local_temp(:)),'retired',7) | strncmp(lower(local_temp(:)),'water damage',12) | strncmp(lower(local_temp(i,:)),'lost',4)) > 0
                mark_dead(count1) = 1;
            end
            temp2=date_temp(i)-date_temp(i-1);
            days_temp=days_temp+temp2;
            wo_service=wo_service+temp2;
            total_temp=total_temp+temp2;
            instr_count(count1)=count;
            SN(count1)=fluor(count);
            matday(count1)=date_temp(i);
            local(count1)=local_temp(i);
            days(count1,1)=days_temp;
            days(count1,2)=wo_service;
            days(count1,3)=total_temp;
            count1=count1+1;
        elseif strcmp(lower(local_temp(i,:)),'wetlabs')
            if sum(strncmp(lower(local_temp(:)),'retired',7) | strncmp(lower(local_temp(:)),'water damage',12) | strncmp(lower(local_temp(:)),'lost',4)) > 0
                mark_dead(count1) = 1;
            end
            days_temp=0;
            wo_service=0;
            instr_count(count1)=count;
            SN(count1)=fluor(count);
            matday(count1)=date_temp(i);
            local(count1)=local_temp(i);
%             days(count1,1)=days_temp;
%             days(count1,2)=wo_service;
%             days(count1,3)=total_temp;
            count1=count1+1;
        elseif strncmp(lower(local_temp(i,:)),'retired',7) | strncmp(lower(local_temp(i,:)),'water damage',12) | strncmp(lower(local_temp(i,:)),'lost',4)
            mark_dead(count1) = 1;
            instr_count(count1)=count;
            SN(count1)=fluor(count);
            matday(count1)=date_temp(i);
            local(count1)=local_temp(i);
            temp2=date_temp(i)-date_temp(i-1);
            days_temp=days_temp+temp2;
            wo_service=wo_service+temp2;
            total_temp=total_temp+temp2;
            days(count1,1)=days_temp;
            days(count1,2)=wo_service;
            days(count1,3)=total_temp;
            count1=count1+1;
        else
            disp(['Skip' fluor(count,:) char(local_temp(i,:))])
        end
    end
end
[swapdatechl,xi]=sort(swapdatechl);
swapchl=swapchl(xi);
ind=find(~isnan(matday));
instr_count=instr_count(ind);
SN=SN(ind,:);
matday=matday(ind);
local=local(ind,:);
days=days(ind,:);
mark_dead=mark_dead(ind);

clear count* i temp1 temp2 local_temp date_temp full a b xi ind RDReD SN_spot local_spot wo_service total_temp days_temp

colormat = [ 1 0 1; 1 .8 1; 1 .6 0; .6 .4 0;.4 .4 0; 0 1 0;.2 .6 0; 0 .6 .4; 0 1 1; 0 0 1; 0 0 .4; .8 .6 1; .6 0 1; .2 0 .4; .4 0 0; 0 0 0; .6 .6 .6];

save .\BeamData\CHLswapdates swapdatechl swapchl
save instr_deployment_data locations SN days fluor instr_count local mark_dead matday days_header colormat
%colormat key [  3 pink; 4 light pink; 5 orange; 6gold;9 olive;  
% 8 green; 10 dark green; 11 blue/green; 12 light 
%blue; 13 blue; 14 navy; 15 light purple; 16 purple; 17 egglplant
%18 brown; 19 black; 20 gray; ]
%extra colors: 1 red;1 0 0;7 yellow;1 1 0; 
%2 brick;.6 0 0;
