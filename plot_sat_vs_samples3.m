load mvco_specdb
ddm = mvcodata(:,3)+mvcodata(:,4);
mvcodata=[mvcodata(:,1:4) ddm mvcodata(:,5:9)];
textfile = ({'ap', 'aph', 'ad', 'ag' , 'ddm', 'wvln', 'depth', 'lat', 'lon', 'matdate'});
start = datenum(2008, 01, 01);
last = datenum(2008, 12, 31);
ind = find(mvcodata(:,6) == 443 & ~isnan(mvcodata(:,4)) & mvcodata(:,10) >= start & mvcodata(:,10) <= last & mvcodata(:,7) <= 4);
data=mvcodata(ind,:);
ind1 = find(data(:,8) <= 41.34 & data(:,8) >= 41.24);
ind2 = find(data(:,8) < 41.24 & data(:,8) >= 41.14);
[box1 box2 box3 cover1 cover2 cover3 year month day yyyymmdd jday] = textread('H:\taylor_made\output_files\A1998_adg_443_qaa_region_month_avgs_25cover.txt','%f%f%f%f%f%f%f%f%f%f%f', 'headerlines',1);
sat_header = ({'box1', 'box2', 'box3', 'cover1', 'cover2', 'cover3', 'year', 'month', 'day', 'yyyymmdd', 'jday', 'matdate'});
newdate = datenum(year, month, day);
sat=[box1 box2 box3 cover1 cover2 cover3 year month day yyyymmdd jday newdate];
clear box1 box2 box3 cover1 cover2 cover3 year month day yyyymmdd jday newdate start last ddm

figure
%plot the 3 different box averages across time
plot(sat(:,12),sat(:,1))
hold on
plot(sat(:,12),sat(:,2),'r')
plot(sat(:,12),sat(:,3),'g')


figure
%'box1' for in shore samples between 41.34-41.24
plot(sat(:,12),sat(:,1))
hold on
plot(data(ind1,10),data(ind1,4),'.');
plot(data(ind1,10),data(ind1,3),'+');
plot(data(ind1,10),data(ind1,5),'o');
unq_date = unique(data(ind1,10));
for i = 1:length(unq_date)
    event = find(data(ind1,10) == unq_date(i));
    avg1(i,:)= [mean(data(event,5)) unq_date(i)];
end
plot(avg1(:,2), avg1(:,1), 'mx');
plot(avg1(:,2), avg1(:,1), 'm-');

figure
%'box2' for in shore samples between 41.24-41.14
plot(sat(:,12),sat(:,2),'r')
hold on
plot(data(ind2,10),data(ind2,4),'.r');
plot(data(ind2,10),data(ind2,3),'+r');
plot(data(ind2,10),data(ind2,5),'or');
unq_date = unique(data(ind2,10));
for i = 1:length(unq_date)
    event = find(data(ind2,10) == unq_date(i));
    x = data(event,5);
    avg2(i,:)= [mean(x) unq_date(i)];
end
clear x
plot(avg2(:,2), avg2(:,1), 'mx')
plot(avg2(:,2), avg2(:,1), 'm-')



%box(*,0) = [41.34, 41.24, -70.65, -70.45]
%box(*,1) = [41.24, 41.14, -70.65, -70.45]
%box(*,2) = [41.14, 41.04, -70.65, -70.45]
