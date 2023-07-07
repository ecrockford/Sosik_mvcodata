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

%SQL_query = 'SELECT ALL * from Bottle';  %get all field from Bottle table
SQL_query = 'SELECT ALL Event_Number_Niskin, ap_a from Bottle';  %get field from Bottle table
e =exec(conn, SQL_query);
%e = exec(conn,'SELECT ALL Event_Number,Event_Number_Niskin,Start_Date,Start_Time_UTC,Latitude,Longitude,Depth,Filter_Size,"Chl (ug/l)","Phaeo (ug/l)",quality_flag,Cal_Date FROM MVCO_Chl_reps');

e = fetch(e);

attributes = attr(e);
header_event = cellstr(strvcat(attributes.fieldName));

close(e);

data = e.data;
bottle = data(:,1);
ap_vol = data(:,2);
%keyboard
clear data
tind = find(strncmp(ap_vol(:,1), 'null',4));
ap_vol(tind) = {'NaN'};
ap_vol = str2num(char(ap_vol));

%just MVCO events
tind = find(strncmp(bottle(:,1), 'MVCO',4));
bottle = bottle(tind,:);
ap_vol = ap_vol(tind);
[bottle, sind] = sort(bottle); %put in alphabetical order - make sure do same on column 2 in bottle table before paste
ap_vol = ap_vol(sind);
temp = char(bottle);
event_num = str2num(temp(:,6:8));
niskin_num = temp(:,10:11);


tind = find(temp(:,9) == 'b' | temp(:,9) == 'c');
niskin_num(tind,1) = '9';
niskin_num(tind,2) = '9';
niskin_num = str2num(niskin_num);

excelfile = 'mvcoproc.xls';

for count = 1:length(bottle),
    if ~isnan(ap_vol(count)),
        chan2=ddeinit('excel',['[',excelfile,']',num2str(event_num(count))]);
        niskin=ddereq(chan2,'r6c1:r11c1');
        ind = find(niskin == niskin_num(count));
%        temp=ddereq(chan2,'r6c14:r11c14');
%        qualityflag(count) = temp(ind(1));
        temp=ddereq(chan2,'r6c13:r11c13');
        apvol_fromexcel(count,1) = temp(ind(1));
      %  for rep2=1:1, %length(niskin)
        acdomfiletemp=ddereq(chan2,['r',num2str(5+ind(1)),'c3'],[1 1]); asfile{count,1}=acdomfiletemp(1:end-1);
            %acdomblankfiletemp=ddereq(chan2,['r',num2str(5+rep2),'c4'],[1 1]); acdomblankfiletemp=acdomblankfile(1:end-1);
        apfiletemp=ddereq(chan2,['r',num2str(5+ind(1)),'c5'],[1 1]); apfile{count,1}=apfiletemp(1:end-1);
        adfiletemp=ddereq(chan2,['r',num2str(5+ind(1)),'c6'],[1 1]); adfile{count,1}=adfiletemp(1:end-1);
      %  end;
        if length(ind) > 1,
            acdomfiletemp=ddereq(chan2,['r',num2str(5+ind(2)),'c3'],[1 1]); asfile2{count,1}=acdomfiletemp(1:end-1);
            %acdomblankfiletemp=ddereq(chan2,['r',num2str(5+rep2),'c4'],[1 1]); acdomblankfiletemp=acdomblankfile(1:end-1);
            apfiletemp=ddereq(chan2,['r',num2str(5+ind(2)),'c5'],[1 1]); apfile2{count,1}=apfiletemp(1:end-1);
            adfiletemp=ddereq(chan2,['r',num2str(5+ind(2)),'c6'],[1 1]); adfile2{count,1}=adfiletemp(1:end-1);        
 %           temp=ddereq(chan2,'r6c14:r11c14');
 %           qualityflag2(count) = temp(ind(2));
            temp=ddereq(chan2,'r6c13:r11c13');
            apvol_fromexcel2(count,1) = temp(ind(2));
        else
            apfile2{count,1} = '-9999';
            adfile2{count,1} = '-9999';
            asfile2{count,1} = '-9999';
  %          qualityflag2(count) = -9999;
            apvol_fromexcel2(count,1) = NaN;
       end;
       if length(ind) > 2,
           keyboard
           disp('case with more than 2 reps!!!')
       end;
    else
        apfile{count,1} = '-9999';
        adfile{count,1} = '-9999';
        asfile{count,1} = '-9999';
        apfile2{count,1} = '-9999';
        adfile2{count,1} = '-9999';
        asfile2{count,1} = '-9999';
   %     qualityflag(count) = -9999;
   %     qualityflag2(count) = -9999;
        apvol_fromexcel(count,1) = NaN;
        apvol_fromexcel2(count,1) = NaN;
    end;
end;

%check for mis match between access and excel for ap volume
temp = find(ap_vol - apvol_fromexcel);
temp2 = find(~isnan(ap_vol(temp)));
[ap_vol(temp(temp2)) apvol_fromexcel(temp(temp2))]
bottle(temp(temp2))


