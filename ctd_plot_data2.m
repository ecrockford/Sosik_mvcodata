%Made by Taylor 2/25/10. First plots ctd cast station locations on lat/lon grid.
% The last column (21) is the station number. Third attempts
%to plot some variables organized by station.

load ctd_data_edited
load ctd_station_data

figure
colormat = [0 0 1; 1 0 0; 0 .75 0; 0 0 0; 1 1 0; 1 .2 1; 1 .5 0; .5 0 .8; 0 1 1];
for j = 1:8
    for i = 1:size(ctd_down,4)
        hold on
        plot(ctd_down(1,20,j,i),ctd_down(1,19,j,i),'.','color',colormat(j,:))
        plot(ctd_up(1,20,j,i),ctd_up(1,19,j,i),'+','color',colormat(j,:))
        ylabel('Latitude (deg N)');
        xlabel('Longitude (deg W)');
        title('Locations of 8 MVCO stations with CTD casts');
     end
       %legend('st1', 'st1 up', 'st2', 'st2 up', 'st3', 'st3 up', 'st4', 'st4 up', 'st5', 'st5 up', 'st6', 'st6  up', 'st7', 'st7 up', 'st8', 'st8 up')
end



%###################################
%Each figure represents a single station and all of the temperature
%profiles ever taken for the station. 
%** Right now only plotting the down direction
colormat = [1 0 0; .6 0 0; 1 .2 0; 1 0 1; 1 .4 1; 1 .8 1; 1 .6 0; .6 .4 0; 1 1 0; 0 1 0; .4 .4 0; .2 .6 0; 0 .6 .4; 0 1 1; 0 0 1; 0 0 .4; .8 .6 1; .6 0 1; .2 0 .4; .4 0 0; 0 0 0; .6 .6 .6];

%colormat key [1 red; 2 brick; 2.1 red-oragne; 3 pink; 3.1 med-light pink; 4 light pink; 5 orange; 6 gold; 
%7 yellow; 8 green; 9 olive; 10 dark green; 11 blue/green; 12 light 
%blue; 13 blue; 14 navy; 15 light purple; 16 purple; 17 egglplant
%18 brown; 19 black; 20 gray; ]

%Subplot of density, fluorescence, turbidity for each station. plots all
%the casts color coded by date for each station. not very helpful because
%it is difficult to tease out individual casts because it is so busy.
for i=1:8
    date_for_legend = [];
    figure
    for k=1:size(ctd_down,4)
        subplot(1,3,1)
        hold on
        plot(ctd_down(:,6,i,k),ctd_down(:,1,i,k),'color',colormat(k,:),'linewidth',2)
%        plot(ctd_up(:,6,i,k),ctd_up(:,1,i,k),':','color',colormat(k,:))
        title(station_title(i,:));
        if ~isnan(ctd_down(1,18,i,k))
           date_for_legend = [date_for_legend; datestr(unique(ctd_down(1,18,i,k)),'mm/dd/yy')];
%        elseif isnan(ctd_down(1,18,i,k))
%           date_for_legend = [date_for_legend; 'No Cast!']
        end
        set(gca,'Ydir','reverse')
        xlabel('Density (kg/m^3)')
        ylabel('Depth (m)')
        
        subplot(1,3,2)
        hold on
        plot(ctd_down(:,7,i,k),ctd_down(:,1,i,k),'color',colormat(k,:),'linewidth',2)
        title(station_title(i,:));
        set(gca,'Ydir','reverse')
        xlabel('Fluorescence (mg/m^3)')
        ylabel('Depth (m)')

        subplot(1,3,3)
        hold on
        plot(ctd_down(:,8,i,k),ctd_down(:,1,i,k),'color',colormat(k,:),'linewidth',2)
        title(station_title(i,:));
        set(gca,'Ydir','reverse')
        xlabel('Turbidity (ftu)')
        ylabel('Depth (m)')
    end
    
        legend(date_for_legend(:,:))
end

%###################################
seasonal_colors = [0 0 1; 0 0 1; .2 .6 0; .2 .6 0; .2 .6 0; 1 0 1; 1 0 1; 1 0 1; 1 .6 0; 1 .6 0; 1 .6 0; 0 0 1];
station_title = ['S1'; 'S2'; 'S3'; 'S4'; 'S5'; 'S6'; 'S7'; 'S8'];
%Compare up and down casts for fluorescence/depth; fluor/density;
%turbidity/depth. Uncomment plots/axis labels you want. Each new figure is a station,
%and every cast date is a new subplot
for i=1:8
    station = find(all_stations(:,21) == i);
    date=unique(all_stations(station,18));
    figure
    for k=1:length(date)
        month = str2num(datestr(date(k),'mm'));
        ind = find(all_stations(:,18) == date(k));
        subplot(2,length(date)/2,k)
        hold on
%        plot(all_stations(ind,7),all_stations(ind,1),'color',seasonal_colors(month,:),'LineWidth',2)
        plot(all_stations(ind,6),all_stations(ind,1),'color',seasonal_colors(month,:),'LineWidth',2)
%        plot(all_stations(ind,8),all_stations(ind,1),'color',seasonal_colors(month,:),'LineWidth',2)

        ind = find(all_stations_up(:,18) == date(k));

%        plot(all_stations_up(ind,7),all_stations_up(ind,1),':', 'color',seasonal_colors(month,:),'LineWidth',2)
        plot(all_stations_up(ind,6),all_stations_up(ind,1),':', 'color',seasonal_colors(month,:),'LineWidth',2)
%        plot(all_stations_up(ind,8),all_stations_up(ind,1),':', 'color',seasonal_colors(month,:),'LineWidth',2)

        title([station_title(i,:) ' ' datestr(date(k),'mm/dd/yyyy')]);
        set(gca,'Ydir','reverse')
        set(gca,'fontsize',8)
%        xlim([0 max(all_stations(ind,7))+2])
%        xlim([0 max(all_stations(ind,8))+2])

        xlabel('Fluorescence (mg/m^3)')
%        xlabel('Turbidity (ftu)')
%        ylabel('Depth (m)')
        ylabel('Density (kg/m^3)','fontsize',8)
    end
    legend('Down', 'Up')
end


%####################################
for n=1:length(cruise_dir),fprintf('%2d    %s\n',n,cruise_dir(n).name),end

k=input('Pick the cruise date to plot by entering the number of the count listed above:');

colormat = [1 0 0; 1 .6 0; 0 1 0; 0 1 1; 1 0 1; 0 0 1; .6 0 1; 0 0 0; 1 1 0; .6 .6 .6];
station_title = ['S1'; 'S2'; 'S3'; 'S4'; 'S5'; 'S6'; 'S7'; 'S8'];
%for k=1:size(ctd_down,4)
        max_dens = ceil(max(max([max(ctd_down(:,6,:,k)) max(ctd_up(:,6,:,k))])));
        min_dens = floor(min(min([min(ctd_down(:,6,:,k)) min(ctd_up(:,6,:,k))])));
        max_fluor = ceil(max(max([max(ctd_down(:,7,:,k)) max(ctd_up(:,7,:,k))])));
        max_turb = ceil(max(max([max(ctd_down(:,8,:,k)) max(ctd_up(:,8,:,k))])));
        max_temp = ceil(max(max([max(ctd_down(:,3,:,k)) max(ctd_up(:,3,:,k))])));
        min_temp = floor(min(min([min(ctd_down(:,3,:,k)) min(ctd_up(:,3,:,k))])));
        max_salt = ceil(max(max([max(ctd_down(:,5,:,k)) max(ctd_up(:,5,:,k))])));
        min_salt = floor(min(min([min(ctd_down(:,5,:,k)) min(ctd_up(:,5,:,k))])));
    figure
    for i=1:8
        subplot(2,3,1)
        hold on
        plot(ctd_down(:,6,i,k),ctd_down(:,1,i,k),'color',colormat(i,:),'linewidth',2)
        set(gca,'Ydir','reverse')
        axis([min_dens max_dens 0 42])
        xlabel('Density (kg/m^3)')
        ylabel('Depth (m)')
        
        subplot(2,3,2)
        hold on
        plot(ctd_down(:,3,i,k),ctd_down(:,1,i,k),'color',colormat(i,:),'linewidth',2)
        set(gca,'Ydir','reverse')
        axis([min_temp max_temp 0 42])
        xlabel('Temperature (deg C)')
        ylabel('Depth (m)')

        subplot(2,3,3)
        hold on
        plot(ctd_down(:,5,i,k),ctd_down(:,1,i,k),'color',colormat(i,:),'linewidth',2)
        set(gca,'Ydir','reverse')
        axis([min_salt max_salt 0 42])
        xlabel('Salinity (psu)')
        ylabel('Depth (m)')
        
        subplot(2,3,4)
        hold on
        plot(ctd_down(:,7,i,k),ctd_down(:,1,i,k),'color',colormat(i,:),'linewidth',2)
        set(gca,'Ydir','reverse')
        axis([0 max_fluor 0 42])
        xlabel('Fluorescence (mg/m^3)')
        ylabel('Depth (m)')

        subplot(2,3,5)
        hold on
        plot(ctd_down(:,8,i,k),ctd_down(:,1,i,k),'color',colormat(i,:),'linewidth',2)
%if statement to fix legend so the color corresponds to the correct station        
        if isnan(ctd_down(1,18,i,k))
            plot(ctd_down(20,6,4,k),0,'color',colormat(i,:));
        end
        set(gca,'Ydir','reverse')
        axis([0 max_turb 0 42])
        xlabel('Turbidity (ftu)')
        ylabel('Depth (m)')
    end
    legend(station_title(:,:))
    if ~isnan(ctd_down(1,18,i,k))
       title(datestr(ctd_down(1,18,4,k),'mm/dd/yyyy'));
    end

%end

