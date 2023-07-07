%load MVCO_chl
load chl_data_reps
load setlatlon

datetemp = char(MVCO_chl_reps(:,3)); datetemp = datetemp(:,1:11);
datetemp2 = char(MVCO_chl_reps(:,4)); datetemp2 = datetemp2(:,12:19);
matdate = datenum([datetemp, datetemp2], 'yyyy-mm-dd HH:MM:SS');
clear datetemp*
matday = floor(matdate);
unqday = unique(matday);
clear datetemp unqday

event = strvcat(MVCO_chl_reps(:,2));
lat = cell2mat(MVCO_chl_reps(:,5)); 
lon = cell2mat(MVCO_chl_reps(:,6));
depth = cell2mat(MVCO_chl_reps(:,7));
chl = cell2mat(MVCO_chl_reps(:,8:14));
phaeo = cell2mat(MVCO_chl_reps(:,15:21));
quality = cell2mat(MVCO_chl_reps(:,22:28));
caldate = NaN(length(lat), 7);
for count = 1:7,
    datetemp = char(MVCO_chl_reps(:,count+28)); ind = setdiff(1:length(lat), strmatch('null', datetemp));
    caldate(ind,count) = datenum(datetemp(ind,:), 'yyyy-mm-dd HH:MM:SS');
end;
clear datetemp ind count

rep_titles = {'whole a', 'whole b', 'whole c', '<10um a', '<10um b', '<80um a', '<80um b'};
avg_title = {'whole', '<10um', '<80um'};
station = {'st1'; 'st2'; 'st3'; 'st4'; 'st5'; 'st6'; 'st7'; 'st8'};
station = char(station)

badind = find(max(quality(:,1:3)')' == 3);

%defined locations of the 8 MVCO cruise locations
%for actual coordinates see mat file or ctd_make_setlatlon.m
st1 = find(lat > setcoord(1,2) & lat < setcoord(1,3) & lon < setcoord(1,4) & lon > setcoord(1,5));
st2 = find(lat > setcoord(2,2) && lat < setcoord(2,3) && lon < setcoord(2,4) && lon > setcoord(2,5));
st3 = find(lat > setcoord(3,2) && lat < setcoord(3,3) && lon < setcoord(3,4) && lon > setcoord(3,5));
st4 = find(lat > setcoord(4,2) && lat < setcoord(4,3) && lon < setcoord(4,4) && lon > setcoord(4,5));
st5 = find(lat > setcoord(5,2) && lat < setcoord(5,3) && lon < setcoord(5,4) && lon > setcoord(5,5));
st6 = find(lat > setcoord(6,2) && lat < setcoord(6,3) && lon < setcoord(6,4) && lon > setcoord(6,5));
st7 = find(lat > setcoord(7,2) && lat < setcoord(7,3) && lon < setcoord(7,4) && lon > setcoord(7,5));
st8 = find(lat > setcoord(8,2) && lat < setcoord(8,3) && lon < setcoord(8,4) && lon > setcoord(8,5));

%plot all chlorophyll values according to depth and color code for 8
%different stations
figure
plot(depth(st1,:),chl(st1,:),'b.')
hold on
plot(depth(st2,:),chl(st2,:),'r.')
plot(depth(st3,:),chl(st3,:),'y.')
plot(depth(st4,:),chl(st4,:),'c.')
plot(depth(st5,:),chl(st5,:),'g.')
plot(depth(st6,:),chl(st6,:),'m.')
plot(depth(st7,:),chl(st7,:),'k.')
plot(depth(st8,:),chl(st8,:),'b+')
ylabel('Chl (ug l^-1)');
xlabel('Depth (m)');
title('Chl vs Depth by station');

figure
plot(lon(st1,:),lat(st1,:),'b.')
hold on
plot(lon(st2,:),lat(st2,:),'r.')
plot(lon(st3,:),lat(st3,:),'y.')
plot(lon(st4,:),lat(st4,:),'c.')
plot(lon(st5,:),lat(st5,:),'g.')
plot(lon(st6,:),lat(st6,:),'m.')
plot(lon(st7,:),lat(st7,:),'k.')
plot(lon(st8,:),lat(st8,:),'b+')
ylabel('Latitude (deg N)');
xlabel('Longitude (deg W)');
title('Locations of 8 MVCO stations');
legend('st1', 'st2', 'st3', 'st4', 'st5', 'st6', 'st7', 'st8')

figure
colormat = [1 1 0; 1 0 0; 0 0 1; 0 1 1; 1 0 1; .5 .5 .5; 0 .5 .5; .5 .5 0; .5 0 .5; .5 1 0; .5 .25 1; 1 .5 0; 1 0 .75; 1 0 .25];
%station_symbol = {'b.'; 'r.'; 'y.'; 'c.'; 'g.'; 'm.'; 'k.'; 'b+'};
%station_symbol = char(station_symbol)
for i = 1:length(station)
    subplot(8,1,i);
    plot(depth(station(i,:),:),chl(station(i,:),:),'.','color', colormat(i,:)) %station_symbol(:,i))
    ylabel('Chl (ug l^-1)');
    xlabel('Depth (m)');
    title('Chl vs Depth by station');
end




figure
%unq_lat_lon = unique(ind*)
%for count = 1:length(unq_lat_lon),
%    plot(ind, '.','color', colormat(count,:)); end;


%%%%%%%%%%
%
%
%

cruise1 = find(matday == 733183);
cruise2 = find(matday == 733200);
cruise3 = find(matday == 733279);
cruise4 = find(matday == 733312);
cruise5 = find(matday == 733326);
cruise6 = find(matday == 733423);
cruise7 = find(matday == 733480);
cruise8 = find(matday == 733551);
cruise9 = find(matday == 733586);
cruise10 = find(matday == 733606);
cruise11 = find(matday == 733662);
cruise12 = find(matday == 733674);
cruise13 = find(matday == 733725);

cruisedates = [733183 733200 733279 733312 733326 733423 733480 733551 733586 733606 733662 733674 733725]; cruisedates = cruisedates'


figure
plot(chl(cruise1(:,1),5:6),'.')


cruisedates = [733183, 733200, 733279, 733312, 733326, 733423, 733480, 733551, 733586, 733606, 733662, 733674, 733725]


%trying to plot <10um chl samples organized by cruise date, plotted
%squetioally by station along the x axis
figure
colormat = [1 1 0; 1 0 0; 0 0 1; 0 1 1; 1 0 1; .5 .5 .5; 0 .5 .5; .5 .5 0; .5 0 .5; .5 1 0; .5 .25 1; 1 .5 0; 1 0 .25];
temp = [];
cruisedates = [733183, 733200, 733279, 733312, 733326, 733423, 733480, 733551, 733586, 733606, 733662, 733674, 733725]; cruisedates = cruisedates'
for count = 1:length(cruisedates),
    ind = strmatch(cruisedates(count), matday(:,1));
    plot(ind,chl(ind,4),  '.','color', colormat(count,:))
    if ~isempty(ind), temp = [temp cruisedates(count)]; end;
    hold on
    ind = strmatch(cruisedates(count), matday(:,1));
    plot(ind,chl(ind,5),  '+','color', colormat(count,:))
    if ~isempty(ind), temp = [temp cruisedates(count)]; end;
end;
legend(datestr(temp'))
ylabel('10um Chl')
xlabel('cruise station')