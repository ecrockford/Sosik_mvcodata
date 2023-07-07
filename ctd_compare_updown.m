%Written by Taylor. Completely copies the 8 plot figure from
%ctd_plot_stations.m This script only plots one station's data from a specific
%cruise date. 
%***** must load mat file then before running this file paste date to
%figure out what to set k equal to


%#######################################################################
%***** change i to the station you want to look at then past:
i = 7

load ctd_station_data
colormat = [1 0 0; 1 0 1; 1 .8 1; 1 .6 0; 1 1 0; 0 1 0; .2 .6 0; 0 1 1; 0 0 1; 0 0 .4; .8 .6 1; .6 0 1; .2 0 .4; .4 0 0; 0 0 0; .6 .6 .6];
station_title = ['Station 1'; 'Station 2'; 'Station 3'; 'Station 4'; 'Station 5'; 'Station 6'; 'Station 7'; 'Station 8'];
station = find(all_stations(:,21) == i);
date=unique(all_stations(station,18));
datestr(date)
%################### STOP PASTE #################
%Look at listed dates for this specific station and set k equal to the
%corresponding date and past the rest
    if i == 6
        k = 3;
    elseif i ==4
        k = 5;
    elseif i ==1
        k = 0;
    elseif i == 7
        k = 4;
    elseif i == 8
        k = 4;
    elseif i == 2
        k = 4;
    else k =4;
    end

k = 2
for i = 1:8
    station = find(all_stations(:,21) == i);
    date=unique(all_stations(station,18));
    

figure


ind = find(all_stations(:,18) == date(k));
ind2 = find(all_stations_up(:,18) == date(k));

        subplot(2,4,1)
        hold on
        plot(all_stations(ind,6),all_stations(ind,1),'LineWidth',2)
        plot(all_stations_up(ind2,6),all_stations_up(ind2,1),'r','LineWidth',2)
        title(station_title(i,:));
        legend(datestr(date(k)))
        set(gca,'Ydir','reverse')
        xlabel('Density (kg/m^3)')
        ylabel('Depth (m)')

        subplot(2,4,2)
        hold on
        plot(all_stations(ind,3),all_stations(ind,1),'LineWidth',2)
        plot(all_stations_up(ind2,3),all_stations_up(ind2,1),'r','LineWidth',2)
        title(station_title(i,:));
        set(gca,'Ydir','reverse')
        xlabel('Temperature (deg C)')
        ylabel('Depth (m)')

        subplot(2,4,3)
        hold on
        plot(all_stations(ind,5),all_stations(ind,1),'LineWidth',2)
        plot(all_stations_up(ind2,5),all_stations_up(ind2,1),'r','LineWidth',2)
        title(station_title(i,:));
        set(gca,'Ydir','reverse')
        xlabel('Salinity (psu)')
        ylabel('Depth (m)')

        
        subplot(2,4,4)
        hold on
        plot(all_stations(ind,7),all_stations(ind,1),'LineWidth',2)
        plot(all_stations_up(ind2,7),all_stations_up(ind2,1),'r','LineWidth',2)
        title(station_title(i,:));
        set(gca,'Ydir','reverse')
        xlabel('Fluorescence (mg/m^3)')
        ylabel('Depth (m)')

        subplot(2,4,5)
        hold on
        plot(all_stations(ind,8),all_stations(ind,1),'LineWidth',2)
        plot(all_stations_up(ind2,8),all_stations_up(ind2,1),'r','LineWidth',2)
        title(station_title(i,:));
        set(gca,'Ydir','reverse')
        xlabel('Turbidity (ftu)')
        ylabel('Depth (m)')
        
        subplot(2,4,6)
        hold on
        plot(all_stations(ind,9),all_stations(ind,1),'LineWidth',2)
        plot(all_stations_up(ind2,9),all_stations_up(ind2,1),'r','LineWidth',2)
        title(station_title(i,:));
        set(gca,'Ydir','reverse')
        xlabel('Beam Attenuation (1/m)')
        ylabel('Depth (m)')
        
        subplot(2,4,7)
        hold on
        plot(all_stations(ind,11),all_stations(ind,1),'LineWidth',2)
        plot(all_stations_up(ind2,11),all_stations_up(ind2,1),'r','LineWidth',2)
        title(station_title(i,:));
        set(gca,'Ydir','reverse')
        xlabel('PAR')
        ylabel('Depth (m)')
        
        subplot(2,4,8)
        hold on
        plot(all_stations(ind,10),all_stations(ind,1),'LineWidth',2)
        plot(all_stations_up(ind2,10),all_stations_up(ind2,1),'r','LineWidth',2)
        title(station_title(i,:));
        set(gca,'Ydir','reverse')
        xlabel('Oxygen Conc (mg/l)')
        ylabel('Depth (m)')
end