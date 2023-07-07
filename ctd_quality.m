load ctd_data_edited
load ctd_station_data
colormat = [1 0 0; 1 .6 0; 0 1 0; 0 1 1; 1 0 1; 0 0 1; .6 0 1; 0 0 0; 1 1 0; .6 .6 .6];
seasonal_colors = [0 0 1; 0 0 1; .2 .6 0; .2 .6 0; .2 .6 0; 1 0 1; 1 0 1; 1 0 1; 1 .6 0; 1 .6 0; 1 .6 0; 0 0 1];

figure
ind = find(~isnan(all_stations(:,7)) & ~isnan(all_stations_up(:,7)));
plot(all_stations(ind,7),all_stations_up(ind,7),'.')
axis([0 40 0 40])
hold on
fit = polyfit(all_stations(ind,7),all_stations_up(ind,7),1);
fplot(['' num2str(fit(1)) '*x+' num2str(fit(2)) ''],[0 40], 'r')
line([0 40], [0 40])
xlabel('Fluorescence of Downcast (mg/m^3)')
ylabel('Fluorescence of Upcast (mg/m^3)')
title(['Fluor down vs up, red is ' num2str(fit(1)) '*x+' num2str(fit(2)) '' ' , blue is 1:1'])
clear fit ind

ind = find(~isnan(all_stations(:,8)) & ~isnan(all_stations_up(:,8)));
figure
plot(all_stations(ind,8),all_stations_up(ind,8),'.')
hold on
fit = polyfit(all_stations(ind,8),all_stations_up(ind,8),1);
fplot(['' num2str(fit(1)) '*x+' num2str(fit(2)) ''],[0 18], 'r')
line([0 30], [0 30])
axis([0 10 0 10])
xlabel('Turbidity of Downcast (ftu)')
ylabel('Turbidity of Upcast (ftu)')
title(['Turb down vs up, red is ' num2str(fit(1)) '*x+' num2str(fit(2)) '' ' , blue is 1:1'])


figure
for i=1:8
    hold on
    ind = find(all_stations(:,21) == i);
    plot(all_stations(ind,8),all_stations(ind,7),'o','color',colormat(i,:));
    xlabel('Turbidity')
    %xlabel('Depth (m)')
    ylabel('Fluorescence (mg/m^3)');
    title('Turb vs Fluor')
end
legend(i)
clear fit ind names sensors
%################################################
%code needs to be re-written with pre-prepped matrix
bulk_strat = [];
for j=1:size(ctd_down,4)
    for i=1:8
        a = max(ctd_down(:,1,i,j)); 
        a = find(ctd_down(:,1,i,j) == a);
        salt_bot = nanmean(ctd_down(a-3:a,5,i,j));
        depth_bot = nanmean(ctd_down(a-3:a,1,i,j));
        if isnan(salt_bot)
            salt_bot = nanmean(ctd_down(a-7:a-4,5,i,j));
            depth_bot = nanmean(ctd_down(a-7:a-4,1,i,j));
        end
        if isnan(salt_bot)
            salt_bot = nanmean(ctd_down(a-11:a-8,5,i,j));
            depth_bot = nanmean(ctd_down(a-11:a-8,1,i,j));
        end 
        b = min(ctd_down(:,1,i,j)); b = find(ctd_down(:,1,i,j) == b);
        salt_surf = nanmean(ctd_down(b:b+3,5,i,j));
        depth_surf = nanmean(ctd_down(b:b+3,1,i,j));
        if isnan(salt_surf)
            salt_surf = nanmean(ctd_down(b+4:b+7,5,i,j));
            depth_surf = nanmean(ctd_down(b+4:b+7,1,i,j));
        end
        if isnan(salt_surf)
            salt_surf = nanmean(ctd_down(b+8:b+11,5,i,j));
            depth_surf = nanmean(ctd_down(b+8:b+11,1,i,j));
        end
        if isnan(salt_surf)
            salt_surf = nanmean(ctd_down(b+12:b+15,5,i,j));
            depth_surf = nanmean(ctd_down(b+12:b+15,1,i,j));
        end

        strat = (salt_bot-salt_surf)/(depth_bot-depth_surf);
        bulk_strat = [bulk_strat; strat salt_bot salt_surf depth_bot depth_surf ctd_down(1,18:20,i,j) i];
%        plot(bulk_strat(1,j,i),max(ctd_down(:,7,i,j)),'*','color',colormat(i,:));
%        hold on
%        plot(bulk_strat(1,j,i),mean(ctd_down(b:b+3,7,i,j)),'.','color',colormat(i,:));
%        plot(bulk_strat(1,j,i),mean(ctd_down(a-3:a,7,i,j)),'+','color',colormat(i,:));
    end 
end
header_strat = {'bulk stratification' 'bottom salinity' 'surface salinity' 'bottom depth' 'surface depth' 'date' 'lat' 'lon' 'station no'};
legend('S1','S2','S3','S4','S5','S6','S7','S8','max','bottom','surface')
line([0 0], [0 35])
clear a b salt_* depth_* strat i j
save ctd_stratification bulk_strat header_strat
%###########################################
 load chl_stations


figure
for i=1:8
    station = find(bulk_strat(:,9) == i);
    subplot(2,4,i)
    for j=1:length(station)
        date = bulk_strat(station,6);
        if ~isnan(date(j))
            ind = find(bulk_strat(:,6) == date(j));
            month = str2num(datestr(date(j),'mm'));
            match_date = datenum(datestr(date(j),'yyyy-mm-dd'));
            chl_point = find(chl_station == i & matday == match_date);
            chl_temp = avg_chl(chl_point);
            if ~isempty(chl_temp)
            hold on
%            plot(bulk_strat(ind,1),max(chl_temp(:)),'*','color',seasonal_colors(month,:));
            plot(bulk_strat(ind,1),chl_temp(1),'o','color',seasonal_colors(month,:));
            plot(bulk_strat(ind,1),chl_temp(end),'+','color',seasonal_colors(month,:));
            end
        end
    end
    xlabel('Bulk Stratification - (bot salt - surf salt)/(bot depth - surf depth)')
    ylabel('Extracted Chlorophyll (ug/L)')
    title(station_title(i,:))
    set(gca,'ylim',[0 ceil(max(max(chl(:,:))))])
%    axis([floor(min(bulk_strat(:,1))*100)/100 max(bulk_strat(:,1)) 0 ceil(max(max(chl(:,:))))])
    line([0 0], [0 10],'color','k')
end
legend('bottom chl','surface chl')%'max chl',
clear i j date station ind month mathc_date chl_point chl_temp
%###########################################
    figure

for i=1:8
    station = find(bulk_strat(:,9) == i);
    subplot(2,4,i)
    for j=1:length(station)
        date = bulk_strat(station,6);
        if ~isnan(date(j))
        ind = find(bulk_strat(:,6) == date(j));
        month = str2num(datestr(date(j),'mm'));
        a = max(ctd_down(:,1,i,j)); a = find(ctd_down(:,1,i,j) == a);
        b = min(ctd_down(:,1,i,j)); b = find(ctd_down(:,1,i,j) == b);
        plot(bulk_strat(ind,1),max(ctd_down(:,7,i,j)),'*','color',seasonal_colors(month,:));
        hold on
        plot(bulk_strat(ind,1),mean(ctd_down(b:b+3,7,i,j)),'.','color',seasonal_colors(month,:));
        plot(bulk_strat(ind,1),mean(ctd_down(a-3:a,7,i,j)),'+','color',seasonal_colors(month,:));
        end
        xlabel('Bulk Stratification - (bot salt - surf salt)/(bot depth - surf depth)')
        ylabel('Fluorescence (mg/m^3)')
        title(station_title(i,:))
        axis auto
        line([0 0], [0 10])
    end
end
legend('max','surface','bottom')
clear i j date station ind month a b 

figure
for i = 1:8
    station = find(bulk_strat(:,9) == i);
    hold on
    plot(bulk_strat(station,6),bulk_strat(station,1),'-','color',colormat(i,:),'linewidth',2)
    ylabel('Bulk Stratification')
    xlabel('Date')
    datetick('x','mmmyy')
end
legend(station_title(:,:))