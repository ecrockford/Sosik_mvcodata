load mvco_specdb
start = datenum(2008, 01, 01);
last = datenum(2008, 12, 31);
ind = find(mvcodata(:,5) == 443 & ~isnan(mvcodata(:,4)) & mvcodata(:,9) >= start & mvcodata(:,9) <= last & mvcodata(:,6) <= 4);
[st1 st2 st3 st4 st5 st6 st7 st8 year month day yyyymmdd jday] = textread('/home/etc48/data/SEAWIFS/SEAWIFS1998_L1A_to_L3/qcflat/weekly/adg_443_qaa/station_avgs.txt','%f%f%f%f%f%f%f%f%f%f%f%f%f', 'headerlines',1);
newdate = datenum(year, month, day);
matr=[st1 st2 st3 st4 st5 st6 st7 st8 year month day yyyymmdd jday newdate];
data = mvcodata(ind,:);
ind2=find(data(:,7) >= 41.22);
inshore = data(ind2,:);
ind2=find(data(:,7) < 41.22);
offshore = data(ind2,:);
clear st1 st2 st3 st4 st5 st6 st7 st8 year month day yyyymmdd jday newdate ind2 start last

for i = 0:4
    figure
    plot(inshore(:,
    
unq=unique(inshore(:,9));
avg_in=[];
for i = 1:length(unq)
    ind = find(inshore(:,9) == unq(i));
    avg = mean(inshore(ind,:),1);
    temp = [avg(:,1:6) unq(i)];
    avg_in = [temp; avg_in];
end

unq=unique(offshore(:,9));
avg_off=[];
for i = 1:length(unq)
    ind = find(offshore(:,9) == unq(i));
    avg = mean(offshore(ind,:),1);
    temp = [avg(:,1:6) unq(i)];
    avg_off = [temp; avg_off];
end

unq=unique(data(:,9));
avg_data=[];
for i = 1:length(unq)
    ind = find(data(:,9) == unq(i));
    avg = mean(data(ind,:),1);
    temp = [avg(:,1:6) unq(i)];
    avg_data = [temp; avg_data];
end

figure
plot(avg_in(:,7),avg_in(:,1),'.-');
hold on
plot(inshore(:,9),inshore(:,1),'.r');
plot(avg_off(:,7),avg_off(:,1),'.-g');
plot(offshore(:,9),offshore(:,1),'.c');
ylabel('Ap'), xlabel('Date')
title('MVCO spectra samples')

figure
plot(avg_in(:,7),avg_in(:,4),'.-');
hold on
plot(inshore(:,9),inshore(:,4),'.r');
plot(avg_off(:,7),avg_off(:,4),'.-g');
plot(offshore(:,9),offshore(:,4),'.c');
ylabel('Acdom'), xlabel('Date')
title('MVCO spectra samples')

figure
plot(avg_data(:,7),(avg_data(:,4)+avg_data(:,3)),'.-k');
hold on
plot(avg_in(:,7),(avg_in(:,4)+avg_in(:,3)),'.');
plot(avg_off(:,7),(avg_off(:,4)+avg_off(:,3)),'.c');
ylabel('Acdom + Ad'), xlabel('Date')
title('MVCO spectra samples')

for j = 1:8
    ii=find(matr(:,j) >= -10)
    figure
    plot(matr(ii, 14), matr(ii, j),'.')
    hold on
    plot(mvcodata(ind,9), mvcodata(ind,4), '.-r')
end


ind = find(mvcodata(:,5) == 443 & ~isnan(mvcodata(:,4)) & mvcodata(:,9) >= start & mvcodata(:,9) <= last & mvcodata(:,6) <= 4) & mvcodata(:,7) >= 41.25;
inshore = mvcodata(ind,:);
ind = find(mvcodata(:,5) == 443 & ~isnan(mvcodata(:,4)) & mvcodata(:,9) >= start & mvcodata(:,9) <= last & mvcodata(:,6) <= 4) & mvcodata(:,7) <= 41.25;
offshore = mvcodata(ind,:);
unq_dates = unique(mvcodata(:,9))
for i = 1:length(unq_dates)
    avg_inshore = mean(inshore(unq_dates(i),4))
    avg_offshore = mean(offshore(unq_dates(i),4))
    