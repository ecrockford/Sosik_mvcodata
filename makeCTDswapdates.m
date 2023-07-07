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
conn = database('Sosik_Instruments','','password');

% Read data from database.  
% Make the SQL statement easily with querybuilder and paste in here - or select all fields with *

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
tick=find(strncmp(temp,'37SI',4));
microcat=temp(tick);
clear temp tick ind date_spot

%
instr_count=NaN(length(date),1);
matday=instr_count;
SN =num2cell(instr_count);
local=SN;
days=NaN(length(date),3);
days_header={'Days Deployed', 'Days Without Service','Total Days Deployed'};
mark_dead=zeros(length(date),1);
%}
swapdate=[];
swapctd=[];
count1=1;
for count = 1:length(microcat)
    ind=find(strcmp(locations(:,SN_spot),microcat(count))); %find all the entries for a specific fluorometer
    [b,xi]=sort(date(ind)); %order all the entries by date
    local_temp=locations(ind(xi),local_spot); %order locations by date
    date_temp=date(ind(xi)); %sort date
    RDReD=cell2mat(locations(ind(xi),5:7)); %pull out retrieval/deployment/redeploy info by date
    
    ind2 = find(RDReD(:,2)==1 | RDReD(:,3)==1);
    swapdate=[swapdate; date_temp(ind2)];
    swapctd=[swapctd; repmat(microcat(count),length(ind2),1)];
    
    
    wo_service=0;
    total_temp=0;
    days_temp=0;
%
        for i = 1:length(date_temp)
        if i == 1
            temp1 = 0;
            instr_count(count1)=count;
            SN(count1)=microcat(count);
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
            SN(count1)=microcat(count);
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
            SN(count1)=microcat(count);
            matday(count1)=date_temp(i);
            local(count1)=local_temp(i);
            days(count1,1)=days_temp;
            days(count1,2)=wo_service;
            days(count1,3)=total_temp;
            count1=count1+1;
        elseif strcmp(upper(local_temp(i,:)),'SBE')
            if sum(strncmp(lower(local_temp(:)),'retired',7) | strncmp(lower(local_temp(:)),'water damage',12) | strncmp(lower(local_temp(:)),'lost',4)) > 0
                mark_dead(count1) = 1;
            end
            days_temp=0;
            wo_service=0;
            instr_count(count1)=count;
            SN(count1)=microcat(count);
            matday(count1)=date_temp(i);
            local(count1)=local_temp(i);
%             days(count1,1)=days_temp;
%             days(count1,2)=wo_service;
%             days(count1,3)=total_temp;
            count1=count1+1;
        elseif strncmp(lower(local_temp(i,:)),'retired',7) | strncmp(lower(local_temp(i,:)),'water damage',12) | strncmp(lower(local_temp(i,:)),'lost',4)
            mark_dead(count1) = 1;
            instr_count(count1)=count;
            SN(count1)=microcat(count);
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
            disp(['Skip' microcat(count,:) char(local_temp(i,:))])
        end
        end
end
[swapdate,xi]=sort(swapdate);
swapctd=swapctd(xi);
ind=find(~isnan(matday));
instr_count=instr_count(ind);
SN=SN(ind,:);
matday=matday(ind);
local=local(ind,:);
days=days(ind,:);
mark_dead=mark_dead(ind);
clear count* i temp1 temp2 local_temp date_temp full a b xi ind RDReD SN_spot local_spot wo_service total_temp days_temp

colormat = [ 1 0 1; 1 .8 1; 1 .6 0; .6 .4 0;.4 .4 0; 0 1 0;.2 .6 0; 0 .6 .4; 0 1 1; 0 0 1; 0 0 .4; .8 .6 1; .6 0 1; .2 0 .4; .4 0 0; 0 0 0; .6 .6 .6];

save .\BeamData\CTDswapdates swapdate swapctd
save .\BeamData\CTD_deployment_data locations SN days microcat instr_count local mark_dead matday days_header colormat
