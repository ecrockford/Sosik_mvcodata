load ctd_data3.mat
%load ctd_data_edited.mat
%Last Modified Taylor 8/24/10
%currently plots fluorometer data
depth = 0:0.25:41; depth=depth';
yi=0:41; yi=yi';
date=NaN(size(ctd_down,4),1);
for ind=1:size(ctd_down,4)
    date(ind)=ctd_down(1,18,4,ind);
end
year=str2num(datestr(date,'yyyy'));
xi=[41.12:0.01:41.34];

%subplot for lat = perpendicular to shore
%************** this temp 'for' loop creates 1 figure for each year of data
%collected. all cruise dates are subplotted on each figure for each year.
%the colorbar scaling DOES NOT have standardized limits for max and min
for temp=2007:max(year)
    count=find(year == temp);
%for each year go through each cruise date and look to see if there is more
%than one cast going perpendicular to shore. if >1 can create a contour
%plot and a 1 gets put in the 'enough' matrix
    enough=zeros(length(count),1);
        for i=1:length(count)
            if sum(~isnan(ctd_down(1,18,1:5,count(i)))) > 1
                enough(i)=1;
            end
        end
    count2=find(enough == 1);
%using the enough matrix you now know the sum is equal to the number of
%contour plats you can creat for that year
    numb_figs=sum(enough);
    if numb_figs ~= 0
%need to grid format the data into a full matrix to create a contour plot
        for i=1:numb_figs
%find where in the 5 stations perpendicular to shore data actually exists
            for n=1:5
                lat(n)=ctd_down(1,19,n,count(count2(i)));
            end
            ind=find(~isnan(lat));
%create 'gridded data' matrix with griddata, lat/depth/fluor
            lat_fluor=griddata(lat(ind),depth,ctd_down(:,7,ind,count(count2(i))),xi,yi);
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
            pcolor(xi,yi,lat_fluor),view(2),shading interp;
            hold on
%insert contour plot on top of color plot to see some values
            [C,h]=contour(xi,yi,lat_fluor,'linecolor','k','linewidth',1);
            clabel(C,h,'Rotation',0);
            % set(h,'levelstep',2)    <- used to decrease number of contour
            % lines when extreme high peaks of chl, set contour step level
            % to 2, so contour lines at 0,2,4,6,etc until max is reached
%plot actual station lat locations to know where real data resides in
%interp plot
            plot(repmat(lat(1:5),2,1),repmat([0; 40],1,5),'k'); 
%plot latitudes that the 5 stations have been interpreted to with the
%griddata function above
            plot(xi,repmat(40,1,length(xi)),'.');
            set(gca,'ydir','reverse')
%            title(['Fluor  ',datestr(date(count(count2(i))),'mm/dd/yy')])
            title(['Fluor, max = ' num2str(max(max(lat_fluor))) ',  ' datestr(date(count(count2(i))),'mm/dd/yy')])
            %use this title when change colorbar from auto so you know max
            xlabel('Latitude (deg N)')
            ylabel('Depth (m)')
            colorbar
            if max(max(lat_fluor)) > 7
                set(h,'levelstep',2)
            elseif max(max(lat_fluor)) >4 & max(max(lat_fluor)) <= 7
                set(h,'levelstep',1)
            elseif max(max(lat_fluor)) >1.2 & max(max(lat_fluor)) <= 4
                set(h,'levelstep',0.5)
            elseif max(max(lat_fluor)) < 1.2
                set(h,'levelstep',0.2)
            end
            caxis([0 7])
        end
    end
end
%##########################################################################
%subplot for lon = parallel to shore
%for commented notes and explinations see loop above same exact code
%besides latitudes used. cross-shelf above, along-shore below
xi=[-70.69:0.01:-70.41];
for temp=2007:2009
    count=find(year == temp);
    enough=zeros(length(count),1);
    for i=1:length(count)
        if sum(~isnan(ctd_down(1,18,4:8,count(i)))) > 1
            enough(i)=1;
        end
    end
    count2=find(enough == 1);
    numb_figs=sum(enough);
    if numb_figs ~= 0
        for i=1:numb_figs
            for n=1:5
                lon(n)=ctd_down(1,20,n+3,count(count2(i)));
            end
            ind=find(~isnan(lon));
            lon_fluor=griddata(lon(ind),depth,ctd_down(:,7,ind+3,count(count2(i))),xi,yi);
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
            pcolor(xi,yi,lon_fluor),view(2),shading interp;
            hold on
            [C,h]=contour(xi,yi,lon_fluor,'linecolor','k','linewidth',1);
            clabel(C,h,'Rotation',0);
            plot(repmat(lon(1:5),2,1),repmat([0; 20],1,5),'k');
            plot(xi,repmat(20,1,length(xi)),'.');
            set(gca,'ydir','reverse','Ylim',[0 20])
            %title(['Fluor  ',datestr(date(count(count2(i))),'mm/dd/yy')])
            title(['Fluor, max = ' num2str(max(max(lon_fluor))) ',  ' datestr(date(count(count2(i))),'mm/dd/yy')])
            %use this title when change colorbar from auto so you know max
            xlabel('Longitude (deg W)')
            ylabel('Depth (m)')
            colorbar
            caxis([0 7])
            if max(max(lon_fluor)) > 7
                set(h,'levelstep',2)
            elseif max(max(lon_fluor)) >4 & max(max(lon_fluor)) <= 7
                set(h,'levelstep',1)
            elseif max(max(lon_fluor)) >1.2 & max(max(lon_fluor)) <= 4
                set(h,'levelstep',0.5)
            elseif max(max(lon_fluor)) < 1.2
                set(h,'levelstep',0.2)
            end
        end
    end
end