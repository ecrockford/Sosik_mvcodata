%contour plots of lat/lon transects for nutrients to compare to ctd cast
%contour plots of chl
yi=0:41; yi=yi';

load nut_data_reps
NO2=nanmean(cell2mat(MVCO_nut_reps(:,8:10)),2);
NH4=nanmean(cell2mat(MVCO_nut_reps(:,11:13)),2);
SIO2=nanmean(cell2mat(MVCO_nut_reps(:,14:16)),2);
PO43=nanmean(cell2mat(MVCO_nut_reps(:,17:19)),2);
avgnut=[NO2 NH4 SIO2 PO43];
clear NO2 NH4 SIO2 PO43
alllat=cell2mat(MVCO_nut_reps(:,5));
alllon=cell2mat(MVCO_nut_reps(:,6));
depth=cell2mat(MVCO_nut_reps(:,7));

matday_nut=char(MVCO_nut_reps(:,3));
matday_nut=datenum(matday_nut(:,1:10),'yyyy-mm-dd');
unq_day=unique(matday_nut);
year=str2num(datestr(unq_day,'yyyy'));
%subplot for lat = perpendicular to shore
%************** this temp 'for' loop creates 1 figure for each year of data
%collected. all cruise dates are subplotted on each figure for each year.
%the colorbar scaling DOES NOT have standardized limits for max and min

answer=input('Choose which nutrient you wouldd like to plot: NO2 NH4 SIO2 PO43    answer= ','s');
switch upper(answer)
    case {'NO2'}
        type=1; name='NO2';
    case {'NH4'}
        type=2; name='NH4';
    case {'SIO2'}
        type=3; name='SIO2';
    case {'PO43'} 
        type=4; name='PO43';
    otherwise
        error('The nutrient you have entered does not exist. Check to make sure you have entered your selection correctly.')
end

xi=[41.12:0.01:41.34];
for useyear=2007:max(year)
    count=find(year == useyear);
    useday=[];
    for i=1:length(count)
        temp=find(matday_nut==unq_day(count(i)));
        if length(find(unique(station4nut(temp)) < 6)) > 1 && length(unique(depth(temp))) > 1
            useday=[useday;unq_day(count(i))];
        end
    end
    numb_figs=length(useday);
    if numb_figs ~= 0
    for i=1:numb_figs
%find where in the 5 stations perpendicular to shore data actually exists
%for the given date
        ind=find(matday_nut==useday(i) & station4nut < 6);
%need to grid format the data into a full matrix to create a contour plot
        lat_nut=griddata(alllat(ind),depth(ind),avgnut(ind,type),xi,yi);
%two if statements to keep 4 plots to a figure
        if i==1 || i == 5 || i == 9
            figure
        end
        if i < 5
            a=i;
        elseif i > 4 && i < 9
            a=i-4;
        elseif i > 8
            a=i-8;
        end
        subplot(2,2,a)
        pcolor(xi,yi,lat_nut),view(2),shading interp;
        hold on
%insert contour plot on top of color plot to see some values
        [C,h]=contour(xi,yi,lat_nut,'linecolor','k','linewidth',1);
        clabel(C,h,'Rotation',0);
%        caxis([0 5])
%too high - washes out almost all plots caxis([0 max(avgnut(:,1))])
        caxis([0 max(avgnut(:,type))])
% set(h,'levelstep',2)    <- used to decrease number of contour
% lines when extreme high peaks of chl, set contour step level
% to 2, so contour lines at 0,2,4,6,etc until max is reached
        if max(avgnut(ind,type)) < 1.2
             set(h,'levelstep',0.2)
%            elseif max(max(lat_fluor)) >4 & max(max(lat_fluor)) <= 7
%                set(h,'levelstep',1)
%            elseif max(max(lat_fluor)) >1.2 & max(max(lat_fluor)) <= 4
%                set(h,'levelstep',0.5)
        end
%plot actual station lat locations to know where real data resides in
%interp plot - black vertical line
        plot(repmat(unique(alllat(ind))',2,1),repmat([0; 40],1,length(unique(alllat(ind)))),'k'); 
%plot latitudes that the 5 stations have been interpreted to with the
%griddata function above
        plot(xi,repmat(40,1,length(xi)),'.');
        set(gca,'ydir','reverse')
%use this title when change colorbar from auto so you know max
        title([name ' max = ' num2str(max(avgnut(ind,type))) ',  ' datestr(useday(i),'mm/dd/yy')])
        xlabel('Latitude (deg N)')
        ylabel('Depth (m)')
        colorbar
    end
    end
end
clear lat_nut
%##########################################################################
%subplot for lon = parallel to shore
%for commented notes and explinations see loop above same exact code
%besides latitudes used. cross-shelf above, along-shore below
yi=0:20; yi=yi';
xi=[-70.69:0.01:-70.41];
for useyear=2007:max(year)
    count=find(year == useyear);
    useday=[];
    for i=1:length(count)
        temp=find(matday_nut==unq_day(count(i)));
        if length(find(unique(station4nut(temp)) > 3)) > 1 && length(unique(depth(temp))) > 1
            useday=[useday; unq_day(count(i))];
        end
    end
    numb_figs=length(useday);
    if numb_figs ~= 0
    for i=1:numb_figs
        ind=find(matday_nut==useday(i) & station4nut > 3);
        lon_nut=griddata(alllon(ind),depth(ind),avgnut(ind,type),xi,yi);
        if i==1 || i == 5 || i == 9
            figure
        end
        if i < 5
            a=i;
        elseif i > 4 && i < 9
            a=i-4;
        elseif i > 8
            a=i-8;
        end
        subplot(2,2,a)
        pcolor(xi,yi,lon_nut),view(2),shading interp;
        hold on
        [C,h]=contour(xi,yi,lon_nut,'linecolor','k','linewidth',1);
        clabel(C,h,'Rotation',0);
        plot(repmat(unique(alllon(ind))',2,1),repmat([0; 40],1,length(unique(alllon(ind)))),'k'); 
        plot(xi,repmat(40,1,length(xi)),'.');
        set(gca,'ydir','reverse')
        title([name 'max = ' num2str(max(avgnut(ind,type))) ',  ' datestr(useday(i),'mm/dd/yy')])
        xlabel('Longitude (deg W)')
        ylabel('Depth (m)')
        colorbar
        if max(avgnut(ind,type)) < 1.2
             set(h,'levelstep',0.2)
%            elseif max(max(lat_fluor)) >4 & max(max(lat_fluor)) <= 7
%                set(h,'levelstep',1)
%            elseif max(max(lat_fluor)) >1.2 & max(max(lat_fluor)) <= 4
%                set(h,'levelstep',0.5)
        end
        caxis([0 max(avgnut(:,type))])
    end
    end
end

clear numb_figs ind* useyear temp* a count useday xi yi h C 
