load mvco_specdb
start = datenum(2008, 01, 01);
last = datenum(2008, 12, 31);
ind = find(mvcodata(:,5) == 443 & ~isnan(mvcodata(:,4)) & mvcodata(:,9) >= start & mvcodata(:,9) <= last & mvcodata(:,6) <= 4);
[st1 st2 st3 st4 st5 st6 st7 st8 year month day yyyymmdd jday] = textread('/home/etc48/data/SEAWIFS/SEAWIFS1998_L1A_to_L3/qcflat/weekly/adg_443_qaa/station_avgs.txt','%f%f%f%f%f%f%f%f%f%f%f%f%f', 'headerlines',1);
newdate = datenum(year, month, day);
matr=[st1 st2 st3 st4 st5 st6 st7 st8 year month day yyyymmdd jday newdate]

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
    