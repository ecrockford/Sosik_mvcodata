%Last Modified Taylor 8/24/10
load ctd_data_edited.mat
depth = 0:0.25:41; depth=depth';
yi=0:41; yi=yi';


for n=1:length(cruise_dir),fprintf('%2d    %s\n',n,cruise_dir(n).name),end

i=input('Pick the cruise date to plot by entering the number of the count listed above:');
for n=1:8
    lat(n)=ctd_down(1,19,n,i);
    lon(n)=ctd_down(1,20,n,i);
end

% contours perpendicular to shore
if sum(~isnan(lat(1:5))) >1
    %xi=(round(min(lat)*100)/100)-.01:0.01:(round(max(lat)*100)/100)+.01;
    xi=[41.12:0.01:41.34];
    ind=find(~isnan(lat(1:5)));
    lat_temp=griddata(lat(ind),depth,ctd_down(:,3,ind,i),xi,yi);
    lat_salt=griddata(lat(ind),depth,ctd_down(:,5,ind,i),xi,yi);
    lat_dens=griddata(lat(ind),depth,ctd_down(:,6,ind,i),xi,yi);
    lat_fluor=griddata(lat(ind),depth,ctd_down(:,7,ind,i),xi,yi);
    lat_turb=griddata(lat(ind),depth,ctd_down(:,8,ind,i),xi,yi);
end
sub=4;
figure
    subplot(sub,1,1);
    pcolor(xi,yi,lat_fluor),view(2),shading interp;
    hold on
    [C,h]=contour(xi,yi,lat_fluor,'linecolor','k','linewidth',1);
    clabel(C,h,'Rotation',0);
    plot(repmat(lat(1:5),2,1),repmat([0; 40],1,5),'k');
    plot(xi,repmat(40,1,length(xi)),'.');
    set(gca,'ydir','reverse')
    title('Fluor across latitude 1m depth bins, 0.01 deg lat bins')
    xlabel('Latitude (deg N)')
    ylabel('Depth (m)')
    %caxis([cmin cmax])  caxis([0 10])
    %caxis auto
    colorbar

    subplot(sub,1,2);
    pcolor(xi,yi,lat_dens),view(2),shading interp;
    hold on
    [C,h]=contour(xi,yi,lat_dens,'linecolor','k','linewidth',1);
    clabel(C,h,'Rotation',0);
    plot(repmat(lat(1:5),2,1),repmat([0; 40],1,5),'k');
    set(gca,'ydir','reverse')
    title('Density')
    xlabel('Latitude (deg N)')
    ylabel('Depth (m)')
    colorbar
    
    subplot(sub,1,3);
    pcolor(xi,yi,lat_turb),view(2),shading interp
    hold on
    [C,h]=contour(xi,yi,lat_turb,'linecolor','k','linewidth',1);
    clabel(C,h,'Rotation',0);
    plot(repmat(lat(1:5),2,1),repmat([0; 40],1,5),'k');
    set(gca,'ydir','reverse')
    title('Turbidity (ftu)')
    xlabel('Latitude (deg N)')
    ylabel('Depth (m)')
    colorbar

    subplot(sub,1,4);
    pcolor(xi,yi,lat_temp),view(2),shading interp
%    colormap(copper);
    hold on
    [C,h]=contour(xi,yi,lat_temp,'linecolor','k','linewidth',1);
    clabel(C,h,'Rotation',0);
    plot(repmat(lat(1:5),2,1),repmat([0; 40],1,5),'k');
    set(gca,'ydir','reverse')
    title('Temperature (deg C)')
    xlabel('Latitude (deg N)')
    ylabel('Depth (m)')
    colorbar



% contours parallel to shore
%*** new yi because no station really gets over ~17m 
yi=0:20; yi=yi';
if sum(~isnan(lon(4:8))) >1
    xi=[-70.69:0.01:-70.41];
    %xi=(round(min(lon)*100)/100)-.01:0.01:(round(max(lon)*100)/100)+.01;
    ind=find(~isnan(lon(4:8)));
    %inds returned as 1:5 not 4:8 of lon matrix. Referencing ind below +3
    %to all ind to get correct location in matrix.
    lon_temp=griddata(lon(ind+3),depth,ctd_down(:,3,ind+3,i),xi,yi);
    lon_salt=griddata(lon(ind+3),depth,ctd_down(:,5,ind+3,i),xi,yi);
    lon_dens=griddata(lon(ind+3),depth,ctd_down(:,6,ind+3,i),xi,yi);
    lon_fluor=griddata(lon(ind+3),depth,ctd_down(:,7,ind+3,i),xi,yi);
    lon_turb=griddata(lon(ind+3),depth,ctd_down(:,8,ind+3,i),xi,yi);
end
    figure
    subplot(sub,1,1);
    subone=pcolor(xi,yi,lon_fluor),view(2),shading interp;
    hold on
    [C,h]=contour(xi,yi,lon_fluor,'linecolor','k','linewidth',1);
    clabel(C,h,'Rotation',0);
    plot(repmat(lon(4:8),2,1),repmat([0; 20],1,5),'k');
    plot(xi,repmat(20,1,length(xi)),'.');
    set(gca,'ydir','reverse')
    title('Fluor across latitude 1m depth bins, 0.01 deg lat bins')
    xlabel('Longitude (deg W)')
    ylabel('Depth (m)')
    %caxis([cmin cmax])
    %caxis auto
    colorbar

    subplot(sub,1,2);
    subtwo=pcolor(xi,yi,lon_dens),view(2),shading interp;
    hold on
    [C,h]=contour(xi,yi,lon_dens,'linecolor','k','linewidth',1);
    clabel(C,h,'Rotation',0);
    plot(repmat(lon(4:8),2,1),repmat([0; 20],1,5),'k');
    set(gca,'ydir','reverse')
    title('Density')
    xlabel('Longitude (deg W)')
    ylabel('Depth (m)')
    colorbar
    
    subplot(sub,1,3);
    subthree=pcolor(xi,yi,lon_turb),view(2),shading interp
    hold on
    [C,h]=contour(xi,yi,lon_turb,'linecolor','k','linewidth',1);
    clabel(C,h,'Rotation',0);
    plot(repmat(lon(4:8),2,1),repmat([0; 20],1,5),'k');
    set(gca,'ydir','reverse')
    title('Turbidity (ftu)')
    xlabel('Longitude (deg W)')
    ylabel('Depth (m)')
    colorbar
        
    subplot(sub,1,4);
    subthree=pcolor(xi,yi,lon_temp),view(2),shading interp
    hold on
    [C,h]=contour(xi,yi,lon_temp,'linecolor','k','linewidth',1);
    clabel(C,h,'Rotation',0);
    plot(repmat(lon(4:8),2,1),repmat([0; 20],1,5),'k');
    set(gca,'ydir','reverse')
    title('Temperature (deg C)')
    xlabel('Longitude (deg W)')
    ylabel('Depth (m)')
    colorbar
