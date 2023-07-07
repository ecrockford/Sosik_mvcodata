load ctd_station_data
load chl_stations
colormat = [1 0 0; .6 0 0; 1 .2 0; 1 0 1; 1 .4 1; 1 .8 1; 1 .6 0; .6 .4 0; 1 1 0; 0 1 0; .4 .4 0; .2 .6 0; 0 .6 .4; 0 1 1; 0 0 1; 0 0 .4; .8 .6 1; .6 0 1; .2 0 .4; .4 0 0; 0 0 0; .6 .6 .6];

cast_date = datenum(datestr(all_stations(:,18),'yyyy-mm-dd'));
unqcast_day = unique(cast_date);
figure
chl_vs_fluor = [];
for i=1:8
for j=1:length(unqcast_day)
    match_date = find(matday == unqcast_day(j));
    if ~isempty(match_date)
        chl_temp = find(matday == unqcast_day(j) & chl_station == i);
        for k=1:length(chl_temp)
            %find the matching station, date, and depth in the cast data  
            %for each extracted chl
            %color coding groups each cruise date for 1 color just to see
            %grouping of day's values
            subplot(2,4,i)
            ind = find(all_stations(:,21) == i & cast_date == unqcast_day(j) & all_stations(:,1) == depth(chl_temp(k)));
            hold on
            plot(nanmean(all_stations(ind-2:ind+2,7)),avg_chl(chl_temp(k)),'.','color',colormat(j,:))
            chl_vs_fluor = [chl_vs_fluor; nanmean(all_stations(ind-2:ind+2,7)) avg_chl(chl_temp(k)) unqcast_day(j) i depth(chl_temp(k))];
        end
    end
end
ind = find(chl_vs_fluor(:,4) == i & ~isnan(chl_vs_fluor(:,1)) & ~isnan(chl_vs_fluor(:,2)));
fit = polyfit(chl_vs_fluor(ind,1),chl_vs_fluor(ind,2),1);
fplot(['' num2str(fit(1)) '*x+' num2str(fit(2)) ''],[0 10], 'r')
title([station_title(i,:) ' , red is ' num2str(fit(1)) '*x+' num2str(fit(2))])
line([0 10], [0 10])
xlabel('Fluor (mg/m^3)')
ylabel('Chl (ug/L)')
end
header_chl_vs_fluor = {'avg cast fluor 5 depths' 'avg extracted chl' 'date' 'station no' 'depth'};
clear badind chl_temp fit i ind j k match_date names sensors
save chl_vs_fluor header_chl_vs_fluor chl_vs_fluor

figure
plot(chl_vs_fluor(:,1),chl_vs_fluor(:,2),'.')
hold on
line([0 15], [0 15])
xlabel('Avg Cast Fluor from 5 readings (mg/m^3')
ylabel('Avg Extracted Chl (ug/L)')
ind = find(~isnan(chl_vs_fluor(:,1)) & ~isnan(chl_vs_fluor(:,2)));
fit = polyfit(chl_vs_fluor(ind,1),chl_vs_fluor(ind,2),1);
fplot(['' num2str(fit(1)) '*x+' num2str(fit(2)) ''],[0 15], 'r')
title(['Cast Fluor down vs Chl Samples, red is ' num2str(fit(1)) '*x+' num2str(fit(2)) '' ' , blue is 1:1'])


%How to average ignoring NaN's = nanmean(chl(:,[1:3]),2) the 2 is for the
%horizontal direction to average, w/o 2 the default would be down a column
seasonal_colors = [0 0 1; 0 0 1; .2 .6 0; .2 .6 0; .2 .6 0; 1 0 1; 1 0 1; 1 0 1; 1 .6 0; 1 .6 0; 1 .6 0; 0 0 1];
%Compare up and down casts for fluorescence. Each new figure is a station,
%and every cast date is a new subplot
for i=1:8
    station = find(all_stations(:,21) == i);
    date=unique(all_stations(station,18));
    figure
    for k=1:length(date)
        month = str2num(datestr(date(k),'mm'));
        match_date = datenum(datestr(date(k),'yyyy-mm-dd'));
        chl_point = find(chl_station == i & matday(:) == match_date);
        ind = find(all_stations(:,18) == date(k)); %don't need to match with station # because date(k) is time specific as well and all stations have unique time for each cruise date
        subplot(2,length(date)/2,k)
        hold on
        plot(all_stations(ind,7),all_stations(ind,1),'color',seasonal_colors(month,:),'LineWidth',2)
        ind = find(all_stations_up(:,18) == date(k));
        plot(all_stations_up(ind,7),all_stations_up(ind,1),':', 'color',seasonal_colors(month,:),'LineWidth',2)
        plot(chl(chl_point,1),depth(chl_point),'r.')
        plot(chl(chl_point,2),depth(chl_point),'r+')
        plot(chl(chl_point,3),depth(chl_point),'r*')
        title([station_title(i,1:2) ' ' datestr(date(k),'mm/dd/yyyy')]);
        set(gca,'Ydir','reverse')
        xlabel('Fluorescence (mg/m^3)')
        ylabel('Depth (m)')
    end
    legend('Down', 'Up', 'Chl a', 'Chl b', 'Chl c')
end
clear i k date station month match)date chl_point ind 