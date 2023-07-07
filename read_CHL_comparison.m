load CHL_comparison_data

CHL_comparison = CHL_comparison_data;

HPLC_label = strvcat(CHL_comparison(:,11)); 
temp = strmatch('HS046', HPLC_label);  %bad replicate
CHL_comparison(temp,:) = [];

datetemp = char(CHL_comparison(:,3)); datetemp = datetemp(:,1:11);
datetemp2 = char(CHL_comparison(:,4)); datetemp2 = datetemp2(:,12:19);
matdate = datenum([datetemp, datetemp2], 'yyyy-mm-dd HH:MM:SS');
clear datetemp*
matday = floor(matdate);
unqday = unique(matday);

event = strvcat(CHL_comparison(:,2));

lat = cell2mat(CHL_comparison(:,5)); 
lon = cell2mat(CHL_comparison(:,6));
depth = cell2mat(CHL_comparison(:,7));
filter_size = cell2mat(CHL_comparison(:,8));
fl_chl = cell2mat(CHL_comparison(:,9:10));
fl_phaeo = cell2mat(CHL_comparison(:,18:19));
HPLC_label = strvcat(CHL_comparison(:,11));

HPLC_chl_fl = cell2mat(CHL_comparison(:,12));
HPLC_chl = cell2mat(CHL_comparison(:,13));
HPLC_pheo = cell2mat(CHL_comparison(:,20:21));

ind = find(depth <= 5 & lat > 41.31 & lat < 41.335 & lon < -70.55 & lon > -70.58);

unq_cal_date = unique(CHL_comparison(:,16));
temp = datenum(unq_cal_date,'yyyy-mm-dd');
unq_cal_date = unq_cal_date(find(temp > datenum('1-0-2004')));
%unq_cal_date_num = datenum(unq_cal_date,'yyyy-mm-dd');

%return
   
%HPLC_matdate = matdate(ind);
%HPLC_chl = HPLC_chl(ind);
%save CHLforRu HPLC_chl HPLC_matdate  -append


plot(fl_chl(:,1), fl_chl(:,2), '.')
hold on
line([0 8], [0 8])
fit = polyfit(fl_chl(:,1), fl_chl(:,2),1);
fplot(['' num2str(fit(1)) '*x+' num2str(fit(2)) ''],[0 8], 'r')
ylabel('Fl - replicate a'), xlabel('Fl - replicate b')


figure
colorstr = 'bgrcmky';
for count = 1:length(unq_cal_date),
    ind = strmatch(unq_cal_date(count), CHL_comparison(:,16));
    plot(ind, fl_chl(ind,1)./HPLC_chl(ind), ['.' colorstr(count)])
    %plot(ind, (fl_chl(ind,1)+fl_phaeo(ind,1))./(HPLC_chl(ind)+HPLC_pheo(ind,1)+HPLC_pheo(ind,2)), ['.' colorstr(count)])
    hold on
    ind = strmatch(unq_cal_date(count), CHL_comparison(:,17));
    plot(ind, fl_chl(ind,2)./HPLC_chl(ind), ['+' colorstr(count)])
    %plot(ind, (fl_chl(ind,2)+fl_phaeo(ind,2))./(HPLC_chl(ind)+HPLC_pheo(ind,1)+HPLC_pheo(ind,2)), ['+' colorstr(count)])
end;
line([0 260], [1 1])
ylabel('Ratio Fl Chl : HPLC Chl'), xlabel('Sample Count')
ind = strmatch('HS030', CHL_comparison(:,11));
line([ind ind], [0 10])
ind = strmatch('HS052', CHL_comparison(:,11));
line([ind ind], [0 10])
ind = strmatch('HS151', CHL_comparison(:,11));
line([ind ind], [0 10])
ind = strmatch('M316', CHL_comparison(:,11));
line([ind ind], [0 10],'color', 'r')
ind = strmatch('M318', CHL_comparison(:,11));
line([ind ind], [0 10], 'color', 'r')
ind = strmatch('HS285', CHL_comparison(:,11));
line([ind ind], [0 10])
ind = strmatch('HS285', CHL_comparison(:,11));
line([ind ind], [0 10])

figure
colorstr = 'bgrcmky';
for count = 1:length(unq_cal_date),
    ind = strmatch(unq_cal_date(count), CHL_comparison(:,16));
    plot(matdate(ind), fl_chl(ind,1), ['.' colorstr(count)])
    hold on
    ind = strmatch(unq_cal_date(count), CHL_comparison(:,17));
    plot(matdate(ind), fl_chl(ind,2), ['+' colorstr(count)])
end;
ylabel('Fl Chl'), xlabel('Sample Date')

figure
colorstr = 'bgrcmky';
for count = 1:length(unq_cal_date),
    ind = strmatch(unq_cal_date(count), CHL_comparison(:,16));
    ind2 = find(depth(ind) < 5); ind = ind(ind2);
    plot(ind, fl_chl(ind,1)./HPLC_chl(ind), ['.' colorstr(count)])
    hold on
    ind = strmatch(unq_cal_date(count), CHL_comparison(:,17));
    ind2 = find(depth(ind) < 5); ind = ind(ind2);
    plot(ind, fl_chl(ind,2)./HPLC_chl(ind), ['+' colorstr(count)])
end;
ylabel('Ratio [Fl Chl : HPLC Chl} <5m depth'), xlabel('Sample Count')

figure
plot(fl_chl(:,1)./HPLC_chl, '.')
hold on
plot(fl_chl((1:26),1)./HPLC_chl(1:26), 'ro')
line([0 260], [1 1])
plot(fl_chl(:,2)./HPLC_chl, 'g^', 'markersize', 3)
ylabel('Ratio Fl Chl : HPLC Chl'), xlabel('Sample Count')
ind = strmatch('HS030', CHL_comparison(:,11));
line([ind ind], [0 10])
ind = strmatch('HS052', CHL_comparison(:,11));
line([ind ind], [0 10])
ind = strmatch('HS151', CHL_comparison(:,11));
line([ind ind], [0 10])
ind = strmatch('M316', CHL_comparison(:,11));
line([ind ind], [0 10],'color', 'r')
ind = strmatch('M318', CHL_comparison(:,11));
line([ind ind], [0 10], 'color', 'r')
ind = strmatch('HS285', CHL_comparison(:,11));
line([ind ind], [0 10])
ind = strmatch('HS285', CHL_comparison(:,11));
line([ind ind], [0 10])
ind = strmatch('MVCO_038', CHL_comparison(:,1));
line([ind ind], [0 10],'color', 'g', 'linestyle', '--')
ind = strmatch('MVCO_045', CHL_comparison(:,1));
line([ind ind], [0 10],'color', 'g', 'linestyle', '--')
ind = strmatch('MVCO_092', CHL_comparison(:,1));
line([ind ind], [0 10], 'color', 'g', 'linestyle', '--')

figure
errorbar(HPLC_chl, nanmean(fl_chl(:,1:2),2), (fl_chl(:,1)-fl_chl(:,2))/2, '.')
%error bar = replicate range on fluorometric
hold on
line([0 10], [0 10])
th = text(HPLC_chl,nanmean(fl_chl(:,1:2),2), HPLC_label, 'fontsize', 8);
ylabel('Fluorometric Chl, mean and range'), xlabel('HPLC TChl')
figure
errorbar(nanmean(fl_chl(:,1:2),2), (fl_chl(:,1)-fl_chl(:,2))/2, '.')
ylabel('Fluorometric Chl, mean and range'), xlabel('Sample Count')

%HPLC_label(23:26,:)
%HS027
%HS028
%HS029
%HS030

%HS009  %7
%HS069  %66

ind = find(depth <= 5 & lat > 41.31 & lat < 41.335 & lon < -70.55 & lon > -70.58);